import 'package:cloud_firestore/cloud_firestore.dart';

class Field {
  final String id;
  final int capacity;
  final String farmId;
  final String specialty;

  Field({
    required this.id,
    required this.capacity,
    required this.farmId,
    required this.specialty,
  });

  factory Field.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Field(
      id: doc.id,
      capacity: data['capacity'] ?? 4,
      farmId: (data['farmId'] as DocumentReference).id,
      specialty: data['specialty'] ?? 'Neutre',
    );
  }
}
