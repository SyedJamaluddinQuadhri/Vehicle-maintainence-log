import 'package:cloud_firestore/cloud_firestore.dart';

class FuelRecord {
  final String id;
  final String vehicleId;
  final double liters;
  final double pricePerLiter;
  final double totalCost;
  final int mileage;
  final DateTime fillDate;
  final String? stationName;
  final DateTime createdAt;

  FuelRecord({
    required this.id,
    required this.vehicleId,
    required this.liters,
    required this.pricePerLiter,
    required this.totalCost,
    required this.mileage,
    required this.fillDate,
    this.stationName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'liters': liters,
      'pricePerLiter': pricePerLiter,
      'totalCost': totalCost,
      'mileage': mileage,
      'fillDate': Timestamp.fromDate(fillDate),
      'stationName': stationName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FuelRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FuelRecord(
      id: doc.id,
      vehicleId: data['vehicleId'] ?? '',
      liters: (data['liters'] ?? 0).toDouble(),
      pricePerLiter: (data['pricePerLiter'] ?? 0).toDouble(),
      totalCost: (data['totalCost'] ?? 0).toDouble(),
      mileage: data['mileage'] ?? 0,
      fillDate: (data['fillDate'] as Timestamp).toDate(),
      stationName: data['stationName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
