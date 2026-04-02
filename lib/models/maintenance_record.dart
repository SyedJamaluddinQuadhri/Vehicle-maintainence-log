import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceRecord {
  final String id;
  final String vehicleId;
  final String serviceType; // Oil Change, Tire Rotation, etc.
  final String description;
  final double cost;
  final int mileage;
  final DateTime serviceDate;
  final String? serviceCenterName;
  final DateTime createdAt;

  MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.description,
    required this.cost,
    required this.mileage,
    required this.serviceDate,
    this.serviceCenterName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'description': description,
      'cost': cost,
      'mileage': mileage,
      'serviceDate': Timestamp.fromDate(serviceDate),
      'serviceCenterName': serviceCenterName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MaintenanceRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MaintenanceRecord(
      id: doc.id,
      vehicleId: data['vehicleId'] ?? '',
      serviceType: data['serviceType'] ?? '',
      description: data['description'] ?? '',
      cost: (data['cost'] ?? 0).toDouble(),
      mileage: data['mileage'] ?? 0,
      serviceDate: (data['serviceDate'] as Timestamp).toDate(),
      serviceCenterName: data['serviceCenterName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
