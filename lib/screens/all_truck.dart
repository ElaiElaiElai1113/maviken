import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/truck_card.dart';
import 'package:maviken/main.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllTruckPage extends StatefulWidget {
  const AllTruckPage({super.key});

  @override
  State<AllTruckPage> createState() => _AllTruckPageState();
}

class _AllTruckPageState extends State<AllTruckPage> {
  List<dynamic> truckList = [];

  Future<void> fetchTruck() async {
    final response = await Supabase.instance.client.from('Truck').select('*');
    if (mounted) {
      setState(() {
        truckList = response as List<dynamic>;
      });
    }
  }

  void editTruck(int index) {
    final Truck = truckList[index];
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController plateNumberController =
            TextEditingController(text: Truck['plateNumber']);
        final TextEditingController brandController =
            TextEditingController(text: Truck['brand']);
        final TextEditingController modelController =
            TextEditingController(text: Truck['model']);
        final TextEditingController yearController =
            TextEditingController(text: Truck['year'].toString());
        final TextEditingController colorController =
            TextEditingController(text: Truck['color']);

        return AlertDialog(
          title: const Text('Edit Truck'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: plateNumberController,
                  decoration: const InputDecoration(labelText: 'Plate Number'),
                ),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: 'Brand'),
                ),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                ),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                ),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  final updatedOrder = {
                    'plateNumber': plateNumberController.text,
                    'brand': brandController.text,
                    'model': modelController.text,
                    'year': int.tryParse(yearController.text),
                    'color': colorController.text,
                  };
                  await supabase
                      .from('Truck')
                      .update(updatedOrder)
                      .eq('truckID', Truck['truckID']);
                  setState(() {
                    Truck[index] = updatedOrder;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employee updated successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error updating Employee: $e');

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'Please ensure all fields are filled correctly.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                }
                fetchTruck();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTruck(int index) async {
    final Truck = truckList[index]['truckID'];
    try {
      final response =
          await supabase.from('Truck').delete().eq('truckID', Truck);

      setState(() {
        truckList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Truck deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete truck: $error'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTruck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const BarTop(),
      body: SidebarDrawer(
          body: ListView.builder(
              itemCount: truckList.length,
              itemBuilder: (context, index) {
                final Truck = truckList[index];
                return TruckCard(
                  plateNumber: Truck['plateNumber'],
                  brand: Truck['brand'],
                  model: Truck['model'],
                  year: Truck['year'].toString(),
                  color: Truck['color'],
                  onDelete: () => deleteTruck(index),
                  onEdit: () => editTruck(index),
                );
              }),
          drawer: const BarTop()),
    );
  }
}
