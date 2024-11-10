import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<Map<String, dynamic>> _trucks = [];
Map<String, dynamic>? _selectedTruck;

class fleetManagement extends StatefulWidget {
  static const routeName = '/fleetManage';
  const fleetManagement({super.key});

  @override
  State<fleetManagement> createState() => _fleetManagementState();
}

class _fleetManagementState extends State<fleetManagement> {
  Future<void> fetchTruck() async {
    final response = await Supabase.instance.client
        .from('Truck')
        .select('truckID, plateNumber, employee!inner(*)');

    if (!mounted) return;
    setState(() {
      _trucks = response
          .map<Map<String, dynamic>>((truck) => {
                'truckID': truck['truckID'],
                'plateNumber': truck['plateNumber'],
                'brand': truck['brand'],
                'model': truck['model'],
                'year': truck['year'],
                'color': truck['color'],
              })
          .toList();
      if (_trucks.isNotEmpty) {
        _selectedTruck = _trucks.first;
      }
    });
  }

  Future<void> addTruckRecord() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Create a truck record"),
            content: SingleChildScrollView(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: fleetManage(context),
        label: 'Fleet Management');
  }
}

SizedBox fleetManage(
  BuildContext context,
) {
  return SizedBox(
    child: ElevatedButton(
        onPressed: () {}, child: const Text("Create Truck Record")),
  );
}
