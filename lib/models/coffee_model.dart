import 'package:cloud_firestore/cloud_firestore.dart';

class CoffeeType {
  final String id;
  final String name;
  final int growthTime;
  final int cost;
  final double weight;
  final int taste;
  final int bitterness;
  final int content;
  final int smell;
  final String avatarUrl;

  CoffeeType({
    required this.id,
    required this.name,
    required this.growthTime,
    required this.cost,
    required this.weight,
    required this.taste,
    required this.bitterness,
    required this.content,
    required this.smell,
    required this.avatarUrl,
  });

  factory CoffeeType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoffeeType(
      id: doc.id,
      name: data['name'],
      growthTime: data['growthTime'],
      cost: data['cost'],
      weight: data['weight'].toDouble(),
      taste: data['taste'],
      bitterness: data['bitterness'],
      content: data['content'],
      smell: data['smell'],
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }

  factory CoffeeType.empty() => CoffeeType(
        id: '',
        name: 'Inconnu',
        growthTime: 0,
        cost: 0,
        weight: 0,
        taste: 0,
        bitterness: 0,
        content: 0,
        smell: 0,
        avatarUrl: '',
      );
}

class CoffeePlant {
  final String id;
  final CoffeeType type;
  final DateTime plantingTime;
  final DateTime harvestTime;
  final String fieldId;
  final String userId;

  CoffeePlant({
    required this.id,
    required this.type,
    required this.plantingTime,
    required this.harvestTime,
    required this.fieldId,
    required this.userId,
  });
}

class DriedCoffee {
  final String id;
  final CoffeeType type;
  final double weight; // en grammes
  final String userId;

  DriedCoffee({
    required this.id,
    required this.type,
    required this.weight,
    required this.userId,
  });

  factory DriedCoffee.fromFirestore(DocumentSnapshot doc, CoffeeType type) {
    final data = doc.data() as Map<String, dynamic>;
    return DriedCoffee(
      id: doc.id,
      type: type,
      weight: data['weight'].toDouble(),
      userId: data['userId'],
    );
  }
}
