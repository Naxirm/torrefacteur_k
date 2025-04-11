import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final int deeVee;
  final int goldGrains;
  final String farmId;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.deeVee,
    required this.goldGrains,
    required this.farmId,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String farmId;
    if (data['farmId'] is DocumentReference) {
      farmId = (data['farmId'] as DocumentReference).id;
    } else {
      farmId = data['farmId'] ?? '';
    }

    return AppUser(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      deeVee: data['deeVee'] ?? 0,
      goldGrains: data['goldGrains'] ?? 0,
      farmId: farmId,
    );
  }
}
