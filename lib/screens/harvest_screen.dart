import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_torrefacteur_k/models/coffee_model.dart';
import 'package:new_torrefacteur_k/models/user_model.dart';
import 'package:new_torrefacteur_k/services/firestore_service.dart';

class HarvestScreen extends StatefulWidget {
  const HarvestScreen({super.key});

  @override
  _HarvestScreenState createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Récolter le Kafé'),
        iconTheme: const IconThemeData(
          color: Color(0xFFE6B17E),
        ),
      ),
      body: FutureBuilder<List<CoffeePlant>>(
        future: firestore.getAllUserPlants(user.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final plants = snapshot.data!;

          final Map<String, List<CoffeePlant>> groupedByType = {};
          for (var plant in plants) {
            if (groupedByType.containsKey(plant.type.id)) {
              groupedByType[plant.type.id]!.add(plant);
            } else {
              groupedByType[plant.type.id] = [plant];
            }
          }

          return ListView(
            children: groupedByType.entries.map((entry) {
              final plantsOfType = entry.value;

              List<Widget> plantWidgets = [];
              for (final plant in plantsOfType) {
                final timeLeft = plant.harvestTime.difference(DateTime.now());
                final isReady = timeLeft.isNegative;
                final timeLeftStr = isReady
                    ? 'Prêt depuis ${-timeLeft.inMinutes} min'
                    : 'Prêt dans ${timeLeft.inMinutes} min et ${timeLeft.inSeconds % 60} sec';

                plantWidgets.add(
                  ListTile(
                    title: Text(
                      plant.type.name,
                      style: const TextStyle(color: Color(0xFFE6B17E)),
                    ),
                    subtitle: Text(
                      timeLeftStr,
                      style:
                          TextStyle(color: isReady ? Colors.red : Colors.green),
                    ),
                    trailing: ElevatedButton(
                      onPressed: isReady
                          ? () async {
                              try {
                                await firestore.harvestPlant(plant.id, user.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text('Récolte réussie!')),
                                );
                                setState(() {});
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text('Erreur: ${e.toString()}')),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isReady ? Colors.green : Colors.grey,
                      ),
                      child: Text(isReady ? 'Récolter' : 'Pas prêt',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Type de kafé: ${plantsOfType.first.type.name}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  ...plantWidgets,
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
