import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maviken/components/info_button.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/dropdownbutton.dart';

List<Map<String, dynamic>> trucks = [];
Map<String, dynamic>? selectedTruck;
List<Map<String, dynamic>> serviceType = [];
Map<String, dynamic>? selectedService;

final TextEditingController dateController = TextEditingController();

class fleetManagement extends StatefulWidget {
  static const routeName = '/fleetManage';
  const fleetManagement({super.key});

  @override
  State<fleetManagement> createState() => _fleetManagementState();
}

class _fleetManagementState extends State<fleetManagement> {
  Future<void> fetchServiceTypes() async {
    final response =
        await Supabase.instance.client.from('serviceTypes').select('*');

    if (!mounted) return;
    setState(() {
      serviceType = response
          .map<Map<String, dynamic>>((service) => {
                'serviceID': service['id'],
                'serviceType': service['serviceType'],
              })
          .toList();
      if (serviceType.isNotEmpty) {
        selectedService = serviceType.first;
      }
    });
  }

  Future<void> fetchTruck() async {
    final response = await Supabase.instance.client
        .from('Truck')
        .select('truckID, plateNumber, employee:Truck_driverID_fkey(*)');

    if (!mounted) return;
    setState(() {
      trucks = response
          .map<Map<String, dynamic>>((truck) => {
                'truckID': truck['truckID'],
                'plateNumber': truck['plateNumber'],
                'brand': truck['brand'],
                'model': truck['model'],
                'year': truck['year'],
                'color': truck['color'],
              })
          .toList();
      if (trucks.isNotEmpty) {
        selectedTruck = trucks.first;
      }
    });
  }

  Future<void> addTruckRecord() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Create a truck record"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: textFieldDate(dateController, 'Date', context),
                  ),
                  dropDown('Truck', trucks, selectedTruck,
                      (Map<String, dynamic>? newValue) {
                    setState(() {
                      selectedTruck = newValue;
                    });
                  }, 'plateNumber'),
                  dropDown('Service Type', serviceType, selectedService,
                      (Map<String, dynamic>? newValue) {
                    setState(() {
                      selectedService = newValue;
                    });
                  }, 'serviceType')
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    fetchTruck();
    fetchServiceTypes();
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

  SizedBox fleetManage(
    BuildContext context,
  ) {
    return SizedBox(
      child: ElevatedButton(
          onPressed: () {
            addTruckRecord();
          },
          child: const Text("Create Truck Record")),
    );
  }
}
