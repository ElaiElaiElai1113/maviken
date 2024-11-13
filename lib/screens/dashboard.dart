import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/accountsReceivables.dart';
import 'package:maviken/screens/fleetManage.dart';
import 'package:maviken/screens/hauling_advice.dart' as haulingAdvice;
import 'package:maviken/screens/management.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/components/dashboard_button.dart';
import 'package:maviken/components/exit_button.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/profiling.dart';
import 'package:maviken/main.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashBoard extends StatefulWidget {
  static const routeName = '/DashBoard';

  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> orderload = [];

  Future<void> checkAndUpdateStatus(int salesOrderId) async {
    try {
      // Fetch volumeDel for the specific salesOrderId
      final response = await Supabase.instance.client
          .from('sales_orders')
          .select('volumeDel')
          .eq('id', salesOrderId)
          .single();

      if (response['volumeDel'] != null) {
        int volumeDel = response['volumeDel'];

        // Call the update function with the fetched volumeDel
        await updateSalesOrderStatus(salesOrderId, volumeDel);
      } else {
        print('No volumeDel data found for the sales order.');
      }
    } catch (error) {
      print('Error fetching volumeDel: $error');
    }
  }

  Future<void> updateSalesOrderStatus(int salesOrderId, int volumeDel) async {
    try {
      if (volumeDel > 0) {
        // Update the status to 'On Route' if volumeDel > 0
        await Supabase.instance.client
            .from('sales_orders')
            .update({'status': 'On Route'}).eq('id', salesOrderId);
        print('Sales order status updated to On Route');
      } else {
        print('No update needed. volumeDel is 0 or less.');
      }
    } catch (error) {
      print('Error updating sales order status: $error');
    }
  }

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
    }
  }

  Future<void> fetchData() async {
    final data = await supabase.from('salesOrder').select('*');
    setState(() {
      orders = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> fetchTruck() async {
    final truckResponse = await Supabase.instance.client.from('Truck').select(
        'truckID, plateNumber, isRepair, employee:Truck_driverID_fkey(*)');
    if (!mounted) return;

    List<Map<String, dynamic>> updatedTrucks =
        await Future.wait(truckResponse.map((truck) async {
      final unresolvedMaintenanceResponse = await Supabase.instance.client
          .from('maintenanceLog')
          .select('isResolved')
          .eq('truckID', truck['truckID'])
          .eq('isResolved', false);

      return {
        'truckID': truck['truckID'],
        'plateNumber': truck['plateNumber'],
        'isRepair': unresolvedMaintenanceResponse.isNotEmpty,
        'driverName':
            '${truck['employee']['firstName']} ${truck['employee']['lastName']}',
      };
    }).toList());

    setState(() {
      trucks = updatedTrucks;
      if (trucks.isNotEmpty) {
        selectedTruck = trucks.first;
        truckID = selectedTruck?['truckID'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchTruck();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://plus.unsplash.com/premium_photo-1663040229714-f9fd192358b0?q=80&w=2938&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
            fit: BoxFit.cover,
          ),
        ),
        child: GlassmorphicContainer(
          borderRadius: 8,
          blur: 8,
          alignment: Alignment.bottomCenter,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 58, 41, 41).withOpacity(0.1),
              const Color.fromARGB(255, 180, 37, 37).withOpacity(0.05),
            ],
            stops: const [0.1, 1],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFffffff).withOpacity(0.5),
              const Color(0xFFFFFFFF).withOpacity(0.5),
            ],
          ),
          width: screenWidth,
          height: screenHeight,
          child: Row(
            children: [
              const SizedBox(
                width: 50,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 64,
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  dashboardButton(screenWidth, context, NewOrder.routeName,
                      "New Order", Icons.add_box),
                  const SizedBox(
                    height: 50,
                  ),
                  dashboardButton(
                      screenWidth,
                      context,
                      haulingAdvice.HaulingAdvice.routeName,
                      "Hauling Advice",
                      Icons.car_crash_rounded),
                  const SizedBox(
                    height: 50,
                  ),
                  dashboardButton(screenWidth, context, Monitoring.routeName,
                      "Monitoring", Icons.monitor),
                  const SizedBox(
                    height: 50,
                  ),
                  dashboardButton(screenWidth, context,
                      Accountsreceivables.routeName, "Invoices", Icons.monitor),
                  const SizedBox(
                    height: 50,
                  ),
                  dashboardButton(
                      screenWidth,
                      context,
                      fleetManagement.routeName,
                      "Fleet Management",
                      Icons.monitor),
                  const SizedBox(height: 50),
                  dashboardButton(screenWidth, context, Profiling.routeName,
                      "Profiling", Icons.account_circle),
                  const SizedBox(
                    height: 50,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  exitButton(screenWidth, context, LoginScreen.routeName),
                ],
              ),
              const SizedBox(
                width: 50,
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text(
                            "ORDERS",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 8.0),
                                  child: Card(
                                    color: Colors.orangeAccent,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.drive_eta_sharp,
                                          color: Colors.white),
                                      title: Text(
                                        "${orders[index]["custName"]} - ${orders[index]["deliveryAdd"]} - ${orders[index]["status"]} ",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            orders[index]["date"] ?? "",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          // const SizedBox(height: 5),
                                          // LinearPercentIndicator(
                                          //   lineHeight: 14.0,
                                          //   percent: percentDelivered,
                                          //   backgroundColor: Colors.white24,
                                          //   progressColor: Colors.green,
                                          //   center: Text(
                                          //     "${(percentDelivered * 100).toStringAsFixed(1)}%",
                                          //     style: const TextStyle(
                                          //       color: Colors.white,
                                          //       fontSize: 12.0,
                                          //     ),
                                          //   ),
                                          //   barRadius:
                                          //       const Radius.circular(10),
                                          // ),
                                        ],
                                      ),
                                      isThreeLine: true,
                                      dense: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                const Text(
                                  "Invoices",
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 8.0),
                                        child: Card(
                                          color: Colors.orangeAccent,
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: ListTile(
                                            leading: const Icon(
                                                Icons.drive_eta_sharp,
                                                color: Colors.white),
                                            title: Text(
                                              orders[index]["custName"] +
                                                  " - " +
                                                  orders[index]["status"],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            subtitle: Text(
                                              orders[index]["date"],
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                            isThreeLine: true,
                                            dense: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                const Text(
                                  "TRUCK MANAGEMENT",
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Table(
                                      border:
                                          TableBorder.all(color: Colors.black),
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        // Header
                                        const TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.orangeAccent),
                                          children: [
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Truck ID',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Plate Number',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Driver Name',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Status',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Data rows
                                        ...trucks.map((truck) {
                                          return TableRow(
                                            children: [
                                              TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      '${truck['truckID']}'),
                                                ),
                                              ),
                                              TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      '${truck['plateNumber']}'),
                                                ),
                                              ),
                                              TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      '${truck['driverName']}'),
                                                ),
                                              ),
                                              TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(truck['isRepair']
                                                      ? "Under Repair"
                                                      : 'Active'),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
