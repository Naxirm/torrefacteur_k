import 'package:cloud_firestore/cloud_firestore.dart';

class DataInitService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initializeAllData() async {
    await _initializeCoffeeTypes();
  }

  Future<void> _initializeCoffeeTypes() async {
    final types = [
      {
        'name': 'Rubisca',
        'growthTime': 1,
        'cost': 2,
        'weight': 0.632,
        'taste': 15,
        'bitterness': 54,
        'content': 35,
        'smell': 19,
      },
      {
        'name': 'Arbrista',
        'growthTime': 4,
        'cost': 6,
        'weight': 0.274,
        'taste': 87,
        'bitterness': 4,
        'content': 35,
        'smell': 59,
      },
      {
        'name': 'Roupetta',
        'growthTime': 2,
        'cost': 3,
        'weight': 0.461,
        'taste': 35,
        'bitterness': 41,
        'content': 75,
        'smell': 67,
      },
      {
        'name': 'Tourista',
        'growthTime': 1,
        'cost': 1,
        'weight': 0.961,
        'taste': 3,
        'bitterness': 91,
        'content': 74,
        'smell': 6,
      },
      {
        'name': 'Goldoria',
        'growthTime': 3,
        'cost': 2,
        'weight': 0.473,
        'taste': 39,
        'bitterness': 9,
        'content': 7,
        'smell': 87,
      },
    ];

    final batch = _db.batch();
    final typesRef = _db.collection('coffeeTypes');

    final snapshot = await typesRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    for (final type in types) {
      batch.set(typesRef.doc(), type);
    }

    await batch.commit();
  }
}
