import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_torrefacteur_k/models/user_model.dart';
import 'package:new_torrefacteur_k/models/field_model.dart';
import 'package:new_torrefacteur_k/services/firestore_service.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});

  @override
  _FieldsScreenState createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  late List<String> forSaleSpecialties;
  final List<String> specialtiesOptions = ['RendementX2', 'Temps/2', 'Neutre'];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _generateForSaleSpecialties();
  }

  // Cette méthode génère 4 spécialités aléatoires à chaque accès à l'écran
  void _generateForSaleSpecialties() {
    forSaleSpecialties = List.generate(
      4,
      (_) => specialtiesOptions[random.nextInt(specialtiesOptions.length)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final user = Provider.of<AppUser?>(context);
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes champs'),
        iconTheme: const IconThemeData(color: Color(0xFFE6B17E)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section des champs déjà acquis
              const Text(
                'Champs existants :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Field>>(
                future: firestoreService.getUserFields(user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Erreur de chargement des champs.');
                  }
                  final userFields = snapshot.data ?? [];
                  if (userFields.isEmpty) {
                    return const Text('Aucun champ trouvé.');
                  }
                  return ListView.separated(
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.grey),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userFields.length,
                    itemBuilder: (context, index) {
                      final field = userFields[index];
                      // Pour l'affichage, on peut utiliser l'ID tronqué comme nom (ou adapter si le modèle change)
                      final fieldName = 'Champ ${field.id.substring(0, 6)}';
                      return ListTile(
                        title: Text(fieldName,
                            style: const TextStyle(color: Color(0xFFE6B17E))),
                        subtitle: Text('Spécialité : ${field.specialty}',
                            style: const TextStyle(color: Color(0xFFE6B17E))),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              // Section "Acheter un champ"
              const Text(
                'Acheter un champ (15 DeeVee)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: forSaleSpecialties.length,
                itemBuilder: (context, index) {
                  final saleSpecialty = forSaleSpecialties[index];
                  return Card(
                    color: const Color(0xFF4A2C20),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        'Champ à vendre ${index + 1}',
                        style: const TextStyle(color: Color(0xFFE6B17E)),
                      ),
                      subtitle: Text(
                        'Spécialité : $saleSpecialty',
                        style: const TextStyle(color: Color(0xFFE6B17E)),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6B17E),
                          foregroundColor: const Color(0xFF2C1810),
                        ),
                        onPressed: () async {
                          try {
                            await firestoreService.addFieldToFarm(
                                user.id, saleSpecialty);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Champ acheté avec succès!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            setState(() {
                              _generateForSaleSpecialties();
                            });
                          } on NotEnoughDeeVeeException catch (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Tu n’as pas assez de DeeVee pour acheter ce champ.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Acheter'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
