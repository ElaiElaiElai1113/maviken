import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<Map<String, dynamic>> maintenanceLog = [];

class MaintenanceLogs extends StatefulWidget {
  static const routeName = '/maintenance';
  const MaintenanceLogs({super.key});

  @override
  State<MaintenanceLogs> createState() => _MaintenanceLogsState();
}

class _MaintenanceLogsState extends State<MaintenanceLogs> {
  Future<void> resolveMaintenance(int maintenanceID, int truckID) async {
    try {
      // Update maintenance log to resolved
      await Supabase.instance.client
          .from('maintenanceLog')
          .update({'isResolved': true}).eq('maintenanceID', maintenanceID);

      // Check if there are other unresolved maintenance logs for this truck
      final unresolvedLogs = await Supabase.instance.client
          .from('maintenanceLog')
          .select('isResolved')
          .eq('truckID', truckID)
          .eq('isResolved', false);

      // Update truck status if no other unresolved logs
      if (unresolvedLogs.isEmpty) {
        await Supabase.instance.client
            .from('Truck')
            .update({'isRepair': false}).eq('truckID', truckID);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Maintenance resolved and truck status updated!'),
        backgroundColor: Colors.green,
      ));
      fetchMaintenanceLog(); // Refresh the logs
    } catch (e) {
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
      setState(() {
        maintenanceLog = response
            .map<Map<String, dynamic>>((log) => {
                  'plateNumber': log['Truck']['plateNumber'],
                  'date': log['date'],
                  'serviceType': log['serviceTypes']['serviceType'],
                  'description': log['description'],
                  'cost': log['cost'],
                  'serviceProviders': log['serviceProviders'],
                  'remarks': log['remarks'],
                })
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not retrieve the maintenance logs'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMaintenanceLog();
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

  SizedBox maintenancePage(BuildContext context) {
    return SizedBox(
      child: Table(
        border: TableBorder.all(color: Colors.black),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header
          const TableRow(
            decoration: BoxDecoration(color: Colors.redAccent),
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
                  child: Text('Cost', style: TextStyle(color: Colors.white)),
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
                    child: Text(trucks['cost'].toString()),
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
                    child: ElevatedButton(
                      onPressed: () {
                        resolveMaintenance(
                            trucks['maintenanceID'], trucks['truckID']);
                      },
                      child: const Text("Resolve"),
                    ),
                  ),
                )
              ],
            );
          }),
        ],
      ),
    );
  }
}
