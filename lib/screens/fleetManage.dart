import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maviken/components/info_button.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/components/textfield.dart';
import 'package:maviken/screens/all_truck.dart';
import 'package:maviken/screens/maintenanceLogs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/dropdownbutton.dart';

List<Map<String, dynamic>> trucks = [];
Map<String, dynamic>? selectedTruck;
List<Map<String, dynamic>> serviceType = [];
Map<String, dynamic>? selectedService;
String? selectedServiceProviders;
int? truckID;

final TextEditingController dateController = TextEditingController();
final TextEditingController descController = TextEditingController();
final TextEditingController remarksController = TextEditingController();
final TextEditingController costController = TextEditingController();

class fleetManagement extends StatefulWidget {
  static const routeName = '/fleetManage';
  const fleetManagement({super.key});

  @override
  State<fleetManagement> createState() => _fleetManagementState();
}

class _fleetManagementState extends State<fleetManagement> {
  bool _isLoading = false;
  Future<void> fetchHaulingAdvice(int truckID) async {
    try {
      final response = await Supabase.instance.client
          .from('haulingAdvice')
          .select('*')
          .eq('truckID', truckID);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Hauling Advice for Truck ID $truckID"),
            content: response.isEmpty
                ? const Text("No hauling advice found for this truck.")
                : SingleChildScrollView(
                    child: Column(
                      children: response.map<Widget>((hauling) {
                        return ListTile(
                          title: Text('Date: ${hauling['date']}'),
                          subtitle:
                              Text('Volume Delivered: ${hauling['volumeDel']}'),
                        );
                      }).toList(),
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e was found!'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  Future<void> insertServiceType(String serviceType) async {
    try {
      final response = await Supabase.instance.client
          .from('serviceTypes')
          .insert({'serviceType': serviceType});

      fetchServiceTypes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e was found!'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> deleteServiceType(int serviceId) async {
    try {
      await Supabase.instance.client
          .from('serviceTypes')
          .delete()
          .eq('id', serviceId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Service type successfully deleted!'),
        backgroundColor: Colors.green,
      ));
      viewServiceTypes(); // Refresh the list after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e was found!'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> editServiceType(int serviceId, String currentServiceType) async {
    final TextEditingController serviceTypeController =
        TextEditingController(text: currentServiceType);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Service Type"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: serviceTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Service Type',
                    hintText: 'Edit the service type',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String serviceType = serviceTypeController.text.trim();
                    if (serviceType.isNotEmpty) {
                      await updateServiceType(serviceId, serviceType);
                      Navigator.of(context).pop(); // Close the dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Please enter a service type.'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  child: const Text('Update Service Type'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> updateServiceType(int serviceId, String serviceType) async {
    try {
      await Supabase.instance.client
          .from('serviceTypes')
          .update({'serviceType': serviceType}).eq('id', serviceId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Service type successfully updated!'),
        backgroundColor: Colors.green,
      ));
      viewServiceTypes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e was found!'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> viewServiceTypes() async {
    final response =
        await Supabase.instance.client.from('serviceTypes').select('*');

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Service Types"),
          content: SingleChildScrollView(
            child: Column(
              children: response.map<Widget>((service) {
                return ListTile(
                  title: Text(service['serviceType']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          editServiceType(
                              service['id'], service['serviceType']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteServiceType(service['id']);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addServiceType() async {
    final TextEditingController serviceTypeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Service Type"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: serviceTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Service Type',
                    hintText: 'Enter the new service type',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String serviceType = serviceTypeController.text.trim();
                    if (serviceType.isNotEmpty) {
                      await insertServiceType(serviceType);
                      Navigator.of(context).pop(); // Close the dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Please enter a service type.'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  child: const Text('Add Service Type'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchTruck() async {
    try {
      final truckResponse = await Supabase.instance.client
          .from('Truck')
          .select('truckID, plateNumber, isRepair, employee!inner(*)');

      if (!mounted) return;
      // Process truck data with employee list handling
      List<Map<String, dynamic>> updatedTrucks =
          await Future.wait(truckResponse.map((truck) async {
        // Check for unresolved maintenance logs for each truck
        final unresolvedMaintenanceResponse = await Supabase.instance.client
            .from('maintenanceLog')
            .select('isResolved')
            .eq('truckID', truck['truckID'])
            .eq('isResolved', false);

        // Determine if the truck is under repair based on unresolved logs
        bool isUnderRepair = unresolvedMaintenanceResponse.isNotEmpty;

        // Update the truck's isRepair status in the database if it has changed
        if (truck['isRepair'] != isUnderRepair) {
          await Supabase.instance.client.from('Truck').update(
              {'isRepair': isUnderRepair}).eq('truckID', truck['truckID']);
        }

        // Select the appropriate employee for the truck
        String driverName = '';
        if (truck['employee'] != null && truck['employee'].isNotEmpty) {
          final activeDriver = truck['employee'].firstWhere(
            (employee) => employee['isActive'] == true,
            orElse: () => null,
          );

          if (activeDriver != null) {
            driverName =
                '${activeDriver['firstName'] ?? ''} ${activeDriver['lastName'] ?? ''}';
          }
        }

        // Return truck information with updated repair status and driver name
        return {
          'truckID': truck['truckID'],
          'plateNumber': truck['plateNumber'],
          'isRepair': isUnderRepair,
          'driverName': driverName,
        };
      }).toList());

      // Update state with the fetched truck data
      setState(() {
        trucks = updatedTrucks;
        if (trucks.isNotEmpty) {
          selectedTruck = trucks.first;
          truckID = selectedTruck?['truckID'];
        }
      });
    } catch (e) {
      print('Error fetching trucks: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> insertMaintenance() async {
    try {
      final response =
          await Supabase.instance.client.from('maintenanceLog').insert([
        {
          'truckID': selectedTruck?['truckID'],
          'date': dateController.text,
          'serviceType': selectedService?['serviceID'],
          'description': descController.text,
          'cost': int.tryParse(costController.text),
          'serviceProviders': selectedServiceProviders,
          'remarks': remarksController.text,
        }
      ]);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Maintenance successfuly loggged!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e was found!'),
        backgroundColor: Colors.red,
      ));
    }
    fetchTruck();
  }

  Future<void> addTruckRecord() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create a truck record"),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: 500,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: textFieldDate(dateController, 'Date', context),
                      ),
                      DropdownButton<String>(
                        hint: const Text("Select Service Provider"),
                        value: selectedServiceProviders,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(fontSize: 18),
                        underline: Container(
                          height: 2,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedServiceProviders = newValue;
                          });
                        },
                        items: <String>['Power Trac', 'In-house']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 25),
                      dropDown('Truck', trucks, selectedTruck,
                          (Map<String, dynamic>? newValue) {
                        setState(() {
                          selectedTruck = newValue;
                        });
                      }, 'plateNumber'),
                      const SizedBox(height: 25),
                      dropDown('Service Type', serviceType, selectedService,
                          (Map<String, dynamic>? newValue) {
                        setState(() {
                          selectedService = newValue;
                        });
                      }, 'serviceType'),
                      const SizedBox(height: 25),
                      textField(descController, 'Description', context,
                          enabled: true),
                      const SizedBox(height: 25),
                      textField(costController, 'Cost', context, enabled: true),
                      const SizedBox(height: 25),
                      textField(
                          remarksController, 'Additional Remarks', context,
                          enabled: true),
                      const SizedBox(height: 25),
                      ElevatedButton(
                          onPressed: () {
                            insertMaintenance();
                          },
                          child: const Text('Add Entry')),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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
        page: _isLoading
            ? Center(child: CircularProgressIndicator())
            : fleetManage(context),
        label: 'Fleet Management');
  }

  Column fleetManage(
    BuildContext context,
  ) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              child: ElevatedButton(
                  onPressed: () {
                    addTruckRecord();
                  },
                  child: const Text("Create Truck Record")),
            ),
            SizedBox(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, MaintenanceLogs.routeName);
                  },
                  child: const Text("View Maintenance Logs")),
            ),
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  addServiceType();
                },
                child: const Text("Add Service Type"),
              ),
            ),
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  viewServiceTypes();
                },
                child: const Text("View Service Types"),
              ),
            ),
          ],
        ),
        Table(
          border: TableBorder.all(color: Colors.black),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header
            const TableRow(
              decoration: BoxDecoration(color: Colors.orangeAccent),
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('Truck ID', style: TextStyle(color: Colors.white)),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Plate Number',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('Driver', style: TextStyle(color: Colors.white)),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('Status', style: TextStyle(color: Colors.white)),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('Actions', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            // Generate rows dynamically based on filtered data
            ...trucks.asMap().entries.map((entry) {
              final index = entry.key;
              final trucks = entry.value;

              return TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${trucks['truckID']}'),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${trucks['plateNumber']}'),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${trucks['driverName']}'),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text(trucks['isRepair'] ? "Under Repair" : 'Active'),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          fetchHaulingAdvice(trucks['truckID']);
                        },
                        child: const Text("View Delivery History"),
                      ),
                    ),
                  )
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}
