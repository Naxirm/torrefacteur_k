import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_torrefacteur_k/models/blend_model.dart';
import 'package:new_torrefacteur_k/models/coffee_model.dart';
import 'package:new_torrefacteur_k/models/field_model.dart';
import 'package:new_torrefacteur_k/models/user_model.dart';

class NotEnoughDeeVeeException implements Exception {
  final String message;
  NotEnoughDeeVeeException(
      [this.message = 'Pas assez de DeeVee pour planter ce café.']);

  @override
  String toString() => message;
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    await _db.collection('users').doc(userId).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'deeVee': 10,
      'goldGrains': 0,
    });
    await createInitialFarm(userId);
  }

  Future<AppUser?> getUserFromFirestore(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Field>> getUserFields(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      final farmRef = userDoc['farmId'] as DocumentReference;

      final farmDoc = await farmRef.get();
      final fieldRefs = (farmDoc['fields'] as List<dynamic>)
          .map((e) => e as DocumentReference)
          .toList();

      final fields = await Future.wait(
        fieldRefs.map((ref) async {
          final fieldDoc = await ref.get();
          return Field.fromFirestore(fieldDoc);
        }).toList(),
      );

      return fields;
    } catch (e) {
      return [];
    }
  }

  Future<void> addFieldToFarm(String userId, String specialty) async {
    const fieldCost = 15;

    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final userData = userDoc.data();

    if (userData == null) throw Exception('User not found');

    final currentDeeVee = userData['deeVee'] ?? 0;
    if (currentDeeVee < fieldCost) {
      throw NotEnoughDeeVeeException(
          'Pas assez de DeeVee pour acheter un champ.');
    }

    final farmRef = userData['farmId'] as DocumentReference?;
    if (farmRef == null) throw Exception('Farm not found for the user');

    final fieldRef = _db.collection('fields').doc();
    await fieldRef.set({
      'capacity': 4,
      'farmId': farmRef,
      'specialty': specialty,
      'plants': [],
    });

    await farmRef.update({
      'fields': FieldValue.arrayUnion([fieldRef]),
    });

    await deductDeeVee(userId, fieldCost);
  }

  Future<void> createInitialFarm(String userId) async {
    try {
      final random = Random();
      final farmRef = _db.collection('farms').doc();
      final specialties = ['RendementX2', 'Temps/2', 'Neutre'];
      final specialty = specialties[random.nextInt(3)];

      await farmRef.set({
        'name': 'Ma première exploitation',
        'fields': [],
      });

      final fieldRef = _db.collection('fields').doc();
      await fieldRef.set({
        'capacity': 4,
        'farmId': farmRef,
        'specialty': specialty,
        'plants': [],
      });

      await farmRef.update({
        'fields': FieldValue.arrayUnion([fieldRef]),
      });

      await _db.collection('users').doc(userId).update({
        'farmId': farmRef,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CoffeeType>> getCoffeeTypes() async {
    final snapshot = await _db.collection('coffeeTypes').get();
    return snapshot.docs.map((doc) => CoffeeType.fromFirestore(doc)).toList();
  }

  Future<List<CoffeePlant>> getAllUserPlants(String userId) async {
    try {
      final snapshot = await _db
          .collection('coffeePlants')
          .where('userId', isEqualTo: _db.collection('users').doc(userId))
          .get();

      final types = await getCoffeeTypes();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final typeRef = data['type'] as DocumentReference;
        final coffeeType = types.firstWhere((t) => t.id == typeRef.id,
            orElse: () => CoffeeType.empty());

        return CoffeePlant(
          id: doc.id,
          type: coffeeType,
          fieldId: (data['fieldId'] as DocumentReference).id,
          plantingTime: (data['plantingTime'] as Timestamp).toDate(),
          harvestTime: (data['harvestTime'] as Timestamp).toDate(),
          userId: (data['userId'] as DocumentReference).id,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DriedCoffee>> getUserDriedCoffee(String userId) async {
    try {
      final snapshot = await _db
          .collection('driedCoffee')
          .where('userId', isEqualTo: _db.collection('users').doc(userId))
          .get();

      final types = await getCoffeeTypes();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final typeRef = data['type'] as DocumentReference;
        final type = types.firstWhere((t) => t.id == typeRef.id);

        return DriedCoffee(
          id: doc.id,
          type: type,
          weight: data['weight']?.toDouble() ?? 0.0,
          userId: userId,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> plantCoffee({
    required String userId,
    required String fieldId,
    required String coffeeTypeId,
    required int quantity,
  }) async {
    final fieldRef = _db.collection('fields').doc(fieldId);
    final fieldDoc = await fieldRef.get();
    final fieldData = fieldDoc.data() as Map<String, dynamic>;
    final plants =
        fieldData.containsKey('plants') ? fieldData['plants'] as List : [];
    final currentPlants = plants.length;

    if (currentPlants + quantity > 4) {
      throw Exception('Capacité du champ dépassée');
    }

    final coffeeType =
        await _db.collection('coffeeTypes').doc(coffeeTypeId).get();
    final cost = coffeeType['cost'] * quantity;

    final userDoc = await _db.collection('users').doc(userId).get();
    final currentDeeVee = userDoc['deeVee'] ?? 0;

    if (currentDeeVee < cost) {
      throw NotEnoughDeeVeeException();
    }

    await deductDeeVee(userId, cost);

    final now = DateTime.now();
    for (int i = 0; i < quantity; i++) {
      final plantRef = _db.collection('coffeePlants').doc();
      await plantRef.set({
        'type': _db.collection('coffeeTypes').doc(coffeeTypeId),
        'plantingTime': now,
        'harvestTime': now.add(Duration(minutes: coffeeType['growthTime'])),
        'fieldId': fieldRef,
        'userId': _db.collection('users').doc(userId),
      });

      await fieldRef.update({
        'plants': FieldValue.arrayUnion([plantRef]),
      });
    }
  }

  Future<List<CoffeePlant>> getUserPlantsReadyForHarvest(String userId) async {
    try {
      final snapshot = await _db
          .collection('coffeePlants')
          .where('userId', isEqualTo: _db.collection('users').doc(userId))
          .get();

      final types = await getCoffeeTypes();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final typeRef = data['type'] as DocumentReference;
        final coffeeType = types.firstWhere((t) => t.id == typeRef.id,
            orElse: () => CoffeeType.empty());

        return CoffeePlant(
          id: doc.id,
          type: coffeeType,
          fieldId: (data['fieldId'] as DocumentReference).id,
          plantingTime: (data['plantingTime'] as Timestamp).toDate(),
          harvestTime: (data['harvestTime'] as Timestamp).toDate(),
          userId: (data['userId'] as DocumentReference).id,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> harvestPlant(String plantId, String userId) async {
    final plantRef = _db.collection('coffeePlants').doc(plantId);
    final plantDoc = await plantRef.get();

    if (!plantDoc.exists) throw Exception('Plant not found');

    final typeRef = plantDoc['type'] as DocumentReference;
    final typeDoc = await typeRef.get();
    final fieldRef = plantDoc['fieldId'] as DocumentReference;
    final fieldDoc = await fieldRef.get();

    final harvestTime = (plantDoc['harvestTime'] as Timestamp).toDate();
    final now = DateTime.now();

    double penalty = 0;

    final timePassed = now.difference(harvestTime).inMinutes;
    var growthTime = typeDoc['growthTime'];

    if (timePassed > growthTime * 5) {
      penalty = 0.8;
    } else if (timePassed > growthTime * 3) {
      penalty = 0.5;
    } else if (timePassed > growthTime) {
      penalty = 0.2;
    }

    double specialtyMultiplier = 1;

    if (fieldDoc['specialty'] == 'RendementX2') {
      specialtyMultiplier = 2;
    } else if (fieldDoc['specialty'] == 'Temps/2') {
      growthTime = (growthTime / 2).round();
    }

    double initialWeight =
        typeDoc['weight'] * (1 - penalty) * specialtyMultiplier;

    double driedWeight = initialWeight * (1 - 0.0458);

    await _db.collection('driedCoffee').add({
      'type': _db.collection('coffeeTypes').doc(typeRef.id),
      'weight': driedWeight,
      'userId': _db.collection('users').doc(userId),
    });

    await _db.collection('users').doc(userId).update({
      'deeVee': FieldValue.increment(typeDoc['cost'] * 2),
    });

    await plantRef.delete();
    await fieldRef.update({
      'plants': FieldValue.arrayRemove([plantRef]),
    });
  }

  Future<void> createBlend({
    required String userId,
    required Map<String, double> components,
    required double totalWeight,
    required double taste,
    required double bitterness,
    required double content,
    required double smell,
    required double weight,
  }) async {
    await _db.collection('blends').add({
      'userId': _db.collection('users').doc(userId),
      'components': components,
      'totalWeight': totalWeight,
      'taste': taste,
      'bitterness': bitterness,
      'content': content,
      'smell': smell,
      'submitted': false,
      'createdAt': DateTime.now(),
    });
  }

  Future<Blend?> getUserCurrentBlend(String userId) async {
    final snapshot = await _db
        .collection('blends')
        .where('userId', isEqualTo: _db.collection('users').doc(userId))
        .where('submitted', isEqualTo: false)
        .limit(1)
        .get();

    return snapshot.docs.isEmpty
        ? null
        : Blend.fromFirestore(snapshot.docs.first);
  }

  Future<void> deleteDriedCoffeeUsed(
      String userId, Map<String, int> components) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final entry in components.entries) {
      final snapshot = await _db
          .collection('driedCoffee')
          .where('userId', isEqualTo: _db.doc('users/$userId'))
          .where('type', isEqualTo: _db.doc('coffeeTypes/${entry.key}'))
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }

  Future<void> submitToContest(String userId, String blendId) async {
    await _db.collection('blends').doc(blendId).update({
      'submitted': true,
      'submissionDate': DateTime.now(),
    });
  }

  Future<void> deductDeeVee(String userId, int weight) async {
    await _db.collection('users').doc(userId).update({
      'deeVee': FieldValue.increment(-weight),
    });
  }

  Stream<AppUser> streamUser(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => AppUser.fromFirestore(doc));
  }
}
