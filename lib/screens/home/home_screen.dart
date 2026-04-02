import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/vehicle.dart';
import '../vehicles/add_vehicle_screen.dart';
import '../maintenance/maintenance_list_screen.dart';
import '../fuel/fuel_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dbService = DatabaseService();
    final userId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Vehicle>>(
        stream: dbService.getVehicles(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final vehicles = snapshot.data ?? [];

          if (vehicles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No vehicles added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first vehicle',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: vehicles.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(
                      vehicle.type == 'car'
                          ? Icons.directions_car
                          : vehicle.type == 'bike'
                              ? Icons.two_wheeler
                              : Icons.local_shipping,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    vehicle.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    '${vehicle.brand} ${vehicle.model} (${vehicle.year})\n${vehicle.registrationNumber}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'maintenance',
                        child: Row(
                          children: [
                            Icon(Icons.build),
                            SizedBox(width: 8),
                            Text('Maintenance'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'fuel',
                        child: Row(
                          children: [
                            Icon(Icons.local_gas_station),
                            SizedBox(width: 8),
                            Text('Fuel Records'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'maintenance') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MaintenanceListScreen(
                              vehicle: vehicle,
                            ),
                          ),
                        );
                      } else if (value == 'fuel') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FuelListScreen(
                              vehicle: vehicle,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Vehicle'),
                            content: Text(
                              'Are you sure you want to delete ${vehicle.name}? This will also delete all maintenance and fuel records.',
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
                          await dbService.deleteVehicle(userId, vehicle.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vehicle deleted successfully'),
                              ),
                            );
                          }
                        }
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
              builder: (context) => const AddVehicleScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
