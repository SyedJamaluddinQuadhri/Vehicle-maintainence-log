import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String userId;
  final String name;
  final String type; // car, bike, truck
  final String brand;
  final String model;
  final String registrationNumber;
  final int year;
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.brand,
    required this.model,
    required this.registrationNumber,
    required this.year,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'brand': brand,
      'model': model,
      'registrationNumber': registrationNumber,
      'year': year,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      year: data['year'] ?? 2020,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
