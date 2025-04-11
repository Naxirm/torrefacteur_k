import 'package:flutter/material.dart';
import 'package:new_torrefacteur_k/screens/fields_screen.dart';
import 'package:provider/provider.dart';
import 'package:new_torrefacteur_k/models/user_model.dart';
import 'package:new_torrefacteur_k/screens/planting_screen.dart';
import 'package:new_torrefacteur_k/screens/harvest_screen.dart';
import 'package:new_torrefacteur_k/screens/blend_screen.dart';
import 'package:new_torrefacteur_k/screens/contest_screen.dart';
import 'package:new_torrefacteur_k/services/auth_service.dart';
import 'package:new_torrefacteur_k/services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<bool> hasReadyPlants(BuildContext context, String userId) async {
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final readyPlants = await firestore.getUserPlantsReadyForHarvest(userId);
    return readyPlants.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<AppUser?>(
      stream: authService.appUser,
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = userSnapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Le Torréfacteur K'),
            iconTheme: const IconThemeData(color: Color(0xFFE6B17E)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => authService.signOut(),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour ${user.firstName} ${user.lastName}'),
                Text('DeeVee: ${user.deeVee}'),
                Text('Grains d\'or: ${user.goldGrains}'),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<bool>(
                    future: hasReadyPlants(context, user.id),
                    builder: (context, readyPlantsSnapshot) {
                      return GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        children: [
                          _buildActionCard(
                            context,
                            Icons.eco,
                            'Planter',
                            const Color(0xFFBF9004),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PlantingScreen()),
                            ),
                            enabled: true,
                          ),
                          _buildActionCard(
                            context,
                            Icons.agriculture,
                            'Récolter',
                            const Color(0xFFBF9004),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HarvestScreen()),
                            ),
                            enabled: true,
                          ),
                          _buildActionCard(
                            context,
                            Icons.blender,
                            'Assemblages',
                            const Color(0xFFBF9004),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BlendScreen()),
                            ),
                            enabled: true,
                          ),
                          _buildActionCard(
                            context,
                            Icons.emoji_events,
                            'CMTM',
                            const Color(0xFFBF9004),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ContestScreen()),
                            ),
                            enabled: true,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6B17E),
                      foregroundColor: const Color(0xFF2C1810),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FieldsScreen()),
                      );
                    },
                    child: const Text(
                      'Mes champs',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap, {
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: const Color(0xFF4A2C20),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 10),
              Text(title,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFFE6B17E))),
            ],
          ),
        ),
      ),
    );
  }
}
