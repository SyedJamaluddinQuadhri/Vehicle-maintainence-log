import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vehicle.dart';
import '../../models/fuel_record.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import 'add_fuel_screen.dart';

class FuelListScreen extends StatelessWidget {
  final Vehicle vehicle;

  const FuelListScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dbService = DatabaseService();
    final userId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('${vehicle.name} - Fuel Records'),
      ),
      body: StreamBuilder<List<FuelRecord>>(
        stream: dbService.getFuelRecords(userId, vehicle.id),
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
                  Icon(Icons.local_gas_station, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No fuel records yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Calculate total fuel and cost
          double totalLiters = 0;
          double totalCost = 0;
          for (var record in records) {
            totalLiters += record.liters;
            totalCost += record.totalCost;
          }

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.local_gas_station, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          '${totalLiters.toStringAsFixed(2)} L',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Total Fuel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.currency_rupee, color: Colors.green),
                        const SizedBox(height: 8),
                        Text(
                          '₹${totalCost.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Total Cost',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.receipt, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text(
                          '${records.length}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Records',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Records List
              Expanded(
                child: ListView.builder(
                  itemCount: records.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.local_gas_station, color: Colors.white),
                        ),
                        title: Text(
                          '${record.liters.toStringAsFixed(2)} Liters',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Date: ${DateFormat('dd MMM yyyy').format(record.fillDate)}'),
                            Text('Price/L: ₹${record.pricePerLiter.toStringAsFixed(2)}'),
                            Text('Total: ₹${record.totalCost.toStringAsFixed(2)}'),
                            Text('Mileage: ${record.mileage} km'),
                            if (record.stationName != null)
                              Text('Station: ${record.stationName}'),
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
                                  'Are you sure you want to delete this fuel record?',
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
                              await dbService.deleteFuelRecord(
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
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFuelScreen(vehicle: vehicle),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
