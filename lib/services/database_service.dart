import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';
import '../models/maintenance_record.dart';
import '../models/fuel_record.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== VEHICLES =====
  
  // Add vehicle
  Future<void> addVehicle(String userId, Vehicle vehicle) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .add(vehicle.toMap());
  }

  // Get vehicles stream
  Stream<List<Vehicle>> getVehicles(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList());
  }

  // Delete vehicle
  Future<void> deleteVehicle(String userId, String vehicleId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .delete();
  }

  // ===== MAINTENANCE RECORDS =====
  
  // Add maintenance record
  Future<void> addMaintenanceRecord(
      String userId, String vehicleId, MaintenanceRecord record) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('maintenance')
        .add(record.toMap());
  }

  // Get maintenance records stream
  Stream<List<MaintenanceRecord>> getMaintenanceRecords(
      String userId, String vehicleId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('maintenance')
        .orderBy('serviceDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceRecord.fromFirestore(doc))
            .toList());
  }

  // Delete maintenance record
  Future<void> deleteMaintenanceRecord(
      String userId, String vehicleId, String recordId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('maintenance')
        .doc(recordId)
        .delete();
  }

  // ===== FUEL RECORDS =====
  
  // Add fuel record
  Future<void> addFuelRecord(
      String userId, String vehicleId, FuelRecord record) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('fuel')
        .add(record.toMap());
  }

  // Get fuel records stream
  Stream<List<FuelRecord>> getFuelRecords(String userId, String vehicleId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('fuel')
        .orderBy('fillDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FuelRecord.fromFirestore(doc)).toList());
  }

  // Delete fuel record
  Future<void> deleteFuelRecord(
      String userId, String vehicleId, String recordId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('fuel')
        .doc(recordId)
        .delete();
  }
}
