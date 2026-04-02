import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vehicle.dart';
import '../../models/maintenance_record.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import 'add_maintenance_screen.dart';

class MaintenanceListScreen extends StatelessWidget {
  final Vehicle vehicle;

  const MaintenanceListScreen({Key? key, required this.vehicle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dbService = DatabaseService();
    final userId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('${vehicle.name} - Maintenance'),
      ),
      body: StreamBuilder<List<MaintenanceRecord>>(
        stream: dbService.getMaintenanceRecords(userId, vehicle.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No maintenance records yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.build, color: Colors.white),
                  ),
                  title: Text(
                    record.serviceType,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(record.description),
                      const SizedBox(height: 4),
                      Text('Date: ${DateFormat('dd MMM yyyy').format(record.serviceDate)}'),
                      Text('Mileage: ${record.mileage} km'),
                      Text('Cost: ₹${record.cost.toStringAsFixed(2)}'),
                      if (record.serviceCenterName != null)
                        Text('Center: ${record.serviceCenterName}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Record'),
                          content: const Text(
                            'Are you sure you want to delete this maintenance record?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await dbService.deleteMaintenanceRecord(
                          userId,
                          vehicle.id,
                          record.id,
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMaintenanceScreen(vehicle: vehicle),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
