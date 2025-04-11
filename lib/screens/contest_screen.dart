import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_torrefacteur_k/models/user_model.dart';
import 'package:new_torrefacteur_k/services/firestore_service.dart';

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  _ContestScreenState createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Concours CMTM'),
        iconTheme: const IconThemeData(
          color: Color(0xFFE6B17E),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Le Concours du Meilleur Torréfacteur du Monde a lieu chaque heure à la 19ème minute',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitToContest(context, user.id),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 22.0, horizontal: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18)),
                child: const Text('Soumettre mon assemblage'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitToContest(BuildContext context, String userId) async {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    try {
      final blend = await firestore.getUserCurrentBlend(userId);
      if (blend == null) {
        throw Exception('Aucun assemblage disponible');
      }

      if (blend.totalWeight < 1000) {
        throw Exception(
            'L\'assemblage doit faire au moins 1kg (${blend.totalWeight}g)');
      }

      await firestore.submitToContest(userId, blend.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Inscription au CMTM réussie!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Erreur: ${e.toString()}')),
      );
    }
  }
}
