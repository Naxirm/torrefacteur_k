import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_torrefacteur_k/models/coffee_model.dart';
import 'package:new_torrefacteur_k/models/field_model.dart';
import 'package:new_torrefacteur_k/models/user_model.dart';
import 'package:new_torrefacteur_k/services/firestore_service.dart';

class GatoGauge extends StatelessWidget {
  final int taste;
  final int bitterness;
  final int content;
  final int smell;

  const GatoGauge({
    super.key,
    required this.taste,
    required this.bitterness,
    required this.content,
    required this.smell,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildGaugeRow('Goût', taste, Colors.brown),
        _buildGaugeRow('Amertume', bitterness, Colors.redAccent),
        _buildGaugeRow('Teneur', content, Colors.green),
        _buildGaugeRow('Odeur', smell, Colors.orange),
      ],
    );
  }

  Widget _buildGaugeRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              color: color,
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(width: 8),
          Text(value.toStringAsFixed(1)),
        ],
      ),
    );
  }
}

class PlantingScreen extends StatefulWidget {
  const PlantingScreen({super.key});

  @override
  State<PlantingScreen> createState() => _PlantingScreenState();
}

class _PlantingScreenState extends State<PlantingScreen> {
  String? _selectedCoffeeType;
  int _quantity = 1;
  String? _selectedField;
  late Future<List<dynamic>> _initialDataFuture;

  @override
  void initState() {
    super.initState();
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final user = Provider.of<AppUser?>(context, listen: false);
    _initialDataFuture = Future.wait([
      firestore.getCoffeeTypes(),
      firestore.getUserFields(user!.id),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planter du Kafé'),
        iconTheme: const IconThemeData(
          color: Color(0xFFE6B17E),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _initialDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.length != 2) {
            return const Center(child: Text('Aucune donnée disponible'));
          }

          final coffeeTypes = snapshot.data![0] as List<CoffeeType>;
          final fields = snapshot.data![1] as List<Field>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sélectionnez un champ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedField,
                  decoration: InputDecoration(
                    labelText: 'Champ',
                    labelStyle: const TextStyle(color: Color(0xFFE6B17E)),
                    filled: true,
                    fillColor: const Color(0xFF4A2F24),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFBC8B67), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFBC8B67), width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFBC8B67), width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                  ),
                  dropdownColor: const Color(0xFF4A2F24),
                  style: const TextStyle(color: Color(0xFFE6B17E)),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xFFE6B17E)),
                  items: fields.map((field) {
                    return DropdownMenuItem<String>(
                      value: field.id,
                      child: Text(
                        'Champ ${fields.indexOf(field) + 1} - Spécificité: ${field.specialty}',
                        style: const TextStyle(color: Color(0xFFE6B17E)),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedField = value),
                ),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sélectionnez un type de Kafé',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.8,
                  children: coffeeTypes.map((type) {
                    final isSelected = _selectedCoffeeType == type.id;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCoffeeType = type.id),
                      child: Card(
                        color: const Color(0xFF4A2F24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFE6B17E)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFE6B17E),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              GatoGauge(
                                taste: type.taste,
                                bitterness: type.bitterness,
                                content: type.content,
                                smell: type.smell,
                              ),
                              Text(
                                'Coût: ${type.cost.toStringAsFixed(0)} Deevee${type.cost > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFE6B17E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Quantité:'),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                    ),
                    Container(
                      width: 30,
                      alignment: Alignment.center,
                      child: Text('$_quantity'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_quantity < 4) {
                          setState(() => _quantity++);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedCoffeeType == null ||
                            _selectedField == null
                        ? null
                        : () async {
                            try {
                              await firestore.plantCoffee(
                                userId: user.id,
                                fieldId: _selectedField!,
                                coffeeTypeId: _selectedCoffeeType!,
                                quantity: _quantity,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Plantation réussie!'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: ${e.toString()}'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6B17E),
                        foregroundColor: const Color(0xFF2C1810),
                        padding: const EdgeInsets.symmetric(
                            vertical: 22.0, horizontal: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 18)),
                    child: const Text('Planter'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
