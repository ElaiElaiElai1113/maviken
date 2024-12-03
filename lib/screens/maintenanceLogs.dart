import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/inventory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<Map<String, dynamic>> maintenanceLog = [];
int? maintenanceID;
int? truckID;
List<Map<String, dynamic>> inventoryItems = [];
Map<String, dynamic>? selectedInventory;
final TextEditingController quantityController = TextEditingController();

class MaintenanceLogs extends StatefulWidget {
  static const routeName = '/maintenance';
  const MaintenanceLogs({super.key});

  @override
  State<MaintenanceLogs> createState() => _MaintenanceLogsState();
}

class _MaintenanceLogsState extends State<MaintenanceLogs> {
  Future<void> fetchInventory() async {
    final response = await supabase
        .from('inventory')
        .select('*, serviceTypes!inner(serviceType)');

    inventoryItems = response
        .map<Map<String, dynamic>>((inventory) => {
              'id': inventory['id'],
              'itemName': inventory['itemName'],
              'quantity': inventory['quantity'],
              'lastUpdated': inventory['lastUpdated'],
              'category': inventory['category'],
              'serviceType': inventory['serviceTypes']['serviceType'],
            })
        .toList();
  }

  Future<void> markMaintenanceAsResolved(int maintenanceID, int truckID) async {
    if (maintenanceID == null || truckID == null) {
      print('Error: maintenanceID or truckID is null');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error: Maintenance ID or Truck ID is missing.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      // Update maintenance log to resolved
      final updateResponse = await Supabase.instance.client
          .from('maintenanceLog')
          .update({'isResolved': true})
          .eq('maintenanceID', maintenanceID)
          .select(); // Request the updated row(s)

      // Log the response for maintenance update
      print('Maintenance Update Response: $updateResponse');

      // Check if maintenance update was successful
      if (updateResponse == null ||
          updateResponse is! List ||
          updateResponse.isEmpty) {
        print('Failed to update maintenance log for ID: $maintenanceID');
        return;
      }

      // Check for unresolved logs
      final unresolvedLogs = await Supabase.instance.client
          .from('maintenanceLog')
          .select('isResolved')
          .eq('truckID', truckID)
          .eq('isResolved', false);

      if (unresolvedLogs.isEmpty) {
        final truckUpdateResult = await Supabase.instance.client
            .from('Truck')
            .update({'isRepair': false})
            .eq('truckID', truckID)
            .select(); // Request the updated row(s)

        // Check if truck update was successful
        if (truckUpdateResult == null ||
            truckUpdateResult is! List ||
            truckUpdateResult.isEmpty) {
          print('Error: Failed to update truck status');
          return;
        }
      }

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Maintenance marked as resolved!'),
        backgroundColor: Colors.green,
      ));

      // Fetch updated maintenance logs
      await fetchMaintenanceLog();
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Error: $e occurred while marking maintenance as resolved.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showResolveDialog(
      BuildContext context, int maintenanceID, int truckID) {
    Map<String, dynamic>? selectedInventory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Resolve Maintenance'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  dropDown(
                    'Inventory item used',
                    inventoryItems,
                    selectedInventory,
                    (Map<String, dynamic>? newValue) {
                      setState(() {
                        selectedInventory = newValue;
                      });
                    },
                    'itemName',
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'Quantity Used'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final inventoryId = selectedInventory?['id'];
                final quantity = int.tryParse(quantityController.text) ?? 0;

                if (inventoryId != null) {
                  await resolveMaintenance(
                      maintenanceID, truckID, inventoryId, quantity);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please select a valid inventory item.'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text('Resolve'),
            ),
          ],
        );
      },
    );
  }

  Future<void> resolveMaintenance(
      int? maintenanceID, int? truckID, int inventoryID, int quantity) async {
    if (maintenanceID == null || truckID == null) {
      print('Error: maintenanceID or truckID is null');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error: Maintenance ID or Truck ID is missing.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      // Fetch the inventory item to ensure it exists
      final inventoryItem =
          inventoryItems.firstWhere((item) => item['id'] == inventoryID);
      final updatedQuantity = inventoryItem['quantity'] - quantity;

      if (updatedQuantity < 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Not enough inventory available.'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      // Update inventory quantity and request returning updated rows
      final updateResponse = await Supabase.instance.client
          .from('inventory')
          .update({'quantity': updatedQuantity})
          .eq('id', inventoryID)
          .select(); // Request the updated row(s)

      // Log the response for inventory update
      print('Update Response: $updateResponse');

      // Update maintenance log to resolved and request returning updated rows
      final updateMaintenanceResponse = await Supabase.instance.client
          .from('maintenanceLog')
          .update({'isResolved': true})
          .eq('maintenanceID', maintenanceID)
          .select(); // Request the updated row(s)

      // Log the response for maintenance update
      print('Maintenance Update Response: $updateMaintenanceResponse');

      // Check if maintenance update was successful
      if (updateMaintenanceResponse == null ||
          updateMaintenanceResponse is! List ||
          updateMaintenanceResponse.isEmpty) {
        print('Failed to update maintenance log for ID: $maintenanceID');
        return;
      }

      // Check for unresolved logs
      final unresolvedLogs = await Supabase.instance.client
          .from('maintenanceLog')
          .select('isResolved')
          .eq('truckID', truckID)
          .eq('isResolved', false);

      if (unresolvedLogs.isEmpty) {
        final truckUpdateResult = await Supabase.instance.client
            .from('Truck')
            .update({'isRepair': false})
            .eq('truckID', truckID)
            .select(); // Request the updated row(s)

        // Check if truck update was successful
        if (truckUpdateResult == null ||
            truckUpdateResult is! List ||
            truckUpdateResult.isEmpty) {
          print('Error: Failed to update truck status');
          return;
        }
      }

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Maintenance resolved and inventory updated!'),
        backgroundColor: Colors.green,
      ));

      // Fetch updated inventory and maintenance logs
      await fetchInventory();
      await fetchMaintenanceLog();
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e occurred while resolving maintenance.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> fetchMaintenanceLog() async {
    try {
      final response = await Supabase.instance.client
          .from('maintenanceLog')
          .select('*, Truck!inner(*), serviceTypes!inner(*)');
      if (!mounted) return;

      // Map the response to maintenanceLog
      maintenanceLog = response
          .map<Map<String, dynamic>>((log) => {
                'maintenanceID': log['maintenanceID'],
                'truckID': log['truckID'],
                'plateNumber': log['Truck']['plateNumber'],
                'date': DateTime.parse(
                    log['date']), // Ensure date is a DateTime object
                'serviceType': log['serviceTypes']['serviceType'],
                'description': log['description'],
                'serviceProviders': log['serviceProviders'],
                'remarks': log['remarks'],
                'isResolved': log['isResolved'],
              })
          .toList();

      // Sort the maintenanceLog in descending order by date
      maintenanceLog.sort((a, b) => b['date'].compareTo(a['date']));

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not retrieve the maintenance logs'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMaintenanceLog();
    fetchInventory();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: maintenancePage(context),
        label: "Maintenance");
  }

  SingleChildScrollView maintenancePage(BuildContext context) {
    return SingleChildScrollView(
      child: Table(
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
                  child: Text('Date', style: TextStyle(color: Colors.white)),
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
                  child: Text('Service Type',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Description',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Service Providers',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Remarks', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Status', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Action', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          // Generate rows dynamically based on filtered data
          ...maintenanceLog.asMap().entries.map((entry) {
            final index = entry.key;
            final trucks = entry.value;

            return TableRow(
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${trucks['date']} '),
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
                    child: Text('${trucks['serviceType']}'),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(trucks['description']),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(trucks['serviceProviders']),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(trucks['remarks']),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        trucks['isResolved'] ? "Complete" : "Ongoing Repairs"),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: trucks['isResolved']
                        ? const Text("Resolved",
                            style: TextStyle(color: Colors.green))
                        : (trucks['serviceProviders'] == 'Power Trac')
                            ? ElevatedButton(
                                onPressed: () async {
                                  // Directly mark as resolved without any prompts
                                  await markMaintenanceAsResolved(
                                      trucks['maintenanceID'],
                                      trucks['truckID']);
                                },
                                child: const Text("Resolve"),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  _showResolveDialog(
                                      context,
                                      trucks['maintenanceID'],
                                      trucks['truckID']);
                                },
                                child: const Text("Resolve"),
                              ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
