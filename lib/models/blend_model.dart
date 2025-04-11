import 'package:cloud_firestore/cloud_firestore.dart';

class Blend {
  final String id;
  final String userId;
  final Map<String, double> components;
  final double totalWeight;
  final double taste;
  final double bitterness;
  final double content;
  final double smell;
  final bool submitted;
  final DateTime? submissionDate;

  Blend({
    required this.id,
    required this.userId,
    required this.components,
    required this.totalWeight,
    required this.taste,
    required this.bitterness,
    required this.content,
    required this.smell,
    required this.submitted,
    this.submissionDate,
  });

  factory Blend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Blend(
      id: doc.id,
      userId: (data['userId'] as DocumentReference).id,
      components: Map<String, double>.from(data['components']),
      totalWeight: data['totalWeight'].toDouble(),
      taste: data['taste'].toDouble(),
      bitterness: data['bitterness'].toDouble(),
      content: data['content'].toDouble(),
      smell: data['smell'].toDouble(),
      submitted: data['submitted'],
      submissionDate: data['submissionDate']?.toDate(),
    );
  }
}
