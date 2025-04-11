import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_torrefacteur_k/models/coffee_model.dart';
import 'package:new_torrefacteur_k/models/user_model.dart';
import 'package:new_torrefacteur_k/services/firestore_service.dart';

class BlendScreen extends StatefulWidget {
  const BlendScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BlendScreenState createState() => _BlendScreenState();
}

class _BlendScreenState extends State<BlendScreen> {
  final ValueNotifier<Map<String, int>> _blendComponentsNotifier =
      ValueNotifier({});
  final ValueNotifier<double> _totalWeightNotifier = ValueNotifier(0.0);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un assemblage'),
        iconTheme: const IconThemeData(color: Color(0xFFE6B17E)),
      ),
      body: DefaultTextStyle(
        style: const TextStyle(color: Color(0xFFE6B17E)),
        child: FutureBuilder<List<DriedCoffee>>(
          future: Provider.of<FirestoreService>(context)
              .getUserDriedCoffee(user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun café séché disponible.'));
            }

            final driedCoffee = snapshot.data!;

            // Regrouper par type et sommer les poids
            final Map<String, DriedCoffee> uniqueTypes = {};
            for (final coffee in driedCoffee) {
              if (uniqueTypes.containsKey(coffee.type.id)) {
                final existing = uniqueTypes[coffee.type.id]!;
                uniqueTypes[coffee.type.id] = DriedCoffee(
                  id: existing.id,
                  userId: existing.userId,
                  type: coffee.type,
                  weight: existing.weight + coffee.weight,
                );
              } else {
                uniqueTypes[coffee.type.id] = coffee;
              }
            }
            final filteredCoffee = uniqueTypes.values.toList();
            final Map<String, CoffeeType> coffeeTypes = {
              for (var c in filteredCoffee) c.type.id: c.type
            };

            return Column(
              children: [
                Expanded(
                  child: ValueListenableBuilder<Map<String, int>>(
                    valueListenable: _blendComponentsNotifier,
                    builder: (context, blendComponents, _) {
                      return ListView.builder(
                        itemCount: filteredCoffee.length,
                        itemBuilder: (context, index) {
                          final coffee = filteredCoffee[index];
                          final unitWeight =
                              coffee.type.weight * 1000; // Poids en grammes
                          final selectedAmount =
                              blendComponents[coffee.type.id] ?? 0;

                          return ListTile(
                            title: Text(
                              coffee.type.name,
                              style: const TextStyle(color: Color(0xFFE6B17E)),
                            ),
                            subtitle: Text(
                              '${coffee.type.weight.toStringAsFixed(3)} kg dispo — '
                              '${unitWeight.toStringAsFixed(0)} g/unité',
                              style: const TextStyle(color: Color(0xFFE6B17E)),
                            ),
                            trailing: SizedBox(
                              width: 140,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    color: const Color(0xFFE6B17E),
                                    onPressed: selectedAmount > 0
                                        ? () {
                                            final updated =
                                                Map<String, int>.from(
                                                    blendComponents);
                                            updated[coffee.type.id] =
                                                selectedAmount - 1;
                                            if (updated[coffee.type.id]! <= 0) {
                                              updated.remove(coffee.type.id);
                                            }
                                            _blendComponentsNotifier.value =
                                                updated;
                                            _totalWeightNotifier.value -=
                                                unitWeight;
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '$selectedAmount', // Affiche la quantité en unités
                                    style: const TextStyle(
                                        color: Color(0xFFE6B17E)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: const Color(0xFFE6B17E),
                                    onPressed: (coffee.weight * 1000 -
                                                selectedAmount * unitWeight) >
                                            0
                                        ? () {
                                            final updated =
                                                Map<String, int>.from(
                                                    blendComponents);
                                            updated[coffee.type.id] =
                                                selectedAmount + 1;
                                            _blendComponentsNotifier.value =
                                                updated;
                                            _totalWeightNotifier.value +=
                                                unitWeight;
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Composition actuelle
                ValueListenableBuilder<Map<String, int>>(
                  valueListenable: _blendComponentsNotifier,
                  builder: (context, blendComponents, _) {
                    if (blendComponents.isEmpty) return const SizedBox.shrink();

                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Composition actuelle :',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...blendComponents.entries.map((entry) {
                          final type = coffeeTypes[entry.key]!;
                          final units = entry.value;
                          final totalWeight = units * (type.weight * 1000);
                          final percentage =
                              (totalWeight / _totalWeightNotifier.value * 100)
                                  .toStringAsFixed(1);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(type.name),
                                Text('$percentage %'),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),
                ValueListenableBuilder<double>(
                  valueListenable: _totalWeightNotifier,
                  builder: (context, total, _) {
                    return Text(
                      'Poids total: ${(total / 1000).toStringAsFixed(2)} kg',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    );
                  },
                ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: _totalWeightNotifier,
                      builder: (context, total, _) {
                        return ElevatedButton(
                          onPressed: total < 1000
                              ? null
                              : () async {
                                  final blendComponents =
                                      _blendComponentsNotifier.value;
                                  try {
                                    double taste = 0;
                                    double bitterness = 0;
                                    double weight = 0;
                                    double smell = 0;
                                    double content = 0;

                                    for (final entry
                                        in blendComponents.entries) {
                                      final type = coffeeTypes[entry.key]!;
                                      final ratio = entry.value /
                                          _totalWeightNotifier.value;

                                      taste += type.taste * ratio;
                                      bitterness += type.bitterness * ratio;
                                      weight += type.weight * ratio;
                                      smell += type.smell * ratio;
                                      content += type.content * ratio;
                                    }

                                    await Provider.of<FirestoreService>(context,
                                            listen: false)
                                        .createBlend(
                                      userId: user.id,
                                      components: blendComponents.map(
                                          (key, value) => MapEntry(
                                              key,
                                              value
                                                  .toDouble())), // Conversion en double
                                      totalWeight: total,
                                      taste: taste,
                                      bitterness: bitterness,
                                      weight: weight,
                                      smell: smell,
                                      content: content,
                                    );

                                    // ignore: use_build_context_synchronously
                                    await Provider.of<FirestoreService>(context,
                                            listen: false)
                                        .deleteDriedCoffeeUsed(
                                            user.id, blendComponents);

                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Assemblage créé avec succès!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                  } catch (e) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(e.toString())),
                                    );
                                  }
                                },
                          child: const Text('Créer l\'assemblage (min 1kg)'),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    ValueListenableBuilder<Map<String, int>>(
                      valueListenable: _blendComponentsNotifier,
                      builder: (context, blendComponents, _) {
                        return TextButton(
                          onPressed: blendComponents.isNotEmpty
                              ? () {
                                  _blendComponentsNotifier.value = {};
                                  _totalWeightNotifier.value = 0;
                                }
                              : null,
                          child: const Text('Réinitialiser'),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
