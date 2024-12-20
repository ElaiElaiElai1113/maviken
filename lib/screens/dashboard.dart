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
import 'package:maviken/screens/reports.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/screens/payRoll.dart';
import 'package:intl/intl.dart';

class DashBoard extends StatefulWidget {
  static const routeName = '/DashBoard';

  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> orderload = [];
  List<AccountReceivable> accountsReceivable = [];
  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchTruck();
    fetchAccountsReceivable();
    fetchInvoices();
  }

  Future<void> fetchAccountsReceivable() async {
    try {
      final response = await Supabase.instance.client
          .from('accountsReceivables')
          .select('*');

      if (response != null) {
        setState(() {
          accountsReceivable = (response as List<dynamic>)
              .map((e) => AccountReceivable.fromJson(e))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('No data received');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
            .from('salesOrder')
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
    final truckResponse = await Supabase.instance.client
        .from('Truck')
        .select('truckID, plateNumber, isRepair, employee!inner(*)');

    print('Truck Response: $truckResponse');
    if (!mounted) return;

    List<Map<String, dynamic>> updatedTrucks =
        await Future.wait(truckResponse.map((truck) async {
      final unresolvedMaintenanceResponse = await Supabase.instance.client
          .from('maintenanceLog')
          .select('isResolved')
          .eq('truckID', truck['truckID'])
          .eq('isResolved', false);
      final employeeList = truck['employee'] as List<dynamic>?;

      return {
        'truckID': truck['truckID'],
        'plateNumber': truck['plateNumber'],
        'isRepair': unresolvedMaintenanceResponse.isNotEmpty,
        'driverName': (employeeList != null && employeeList.isNotEmpty)
            ? '${employeeList[0]['firstName'] ?? ''} ${employeeList[0]['lastName'] ?? ''}'
            : 'Unknown',
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

  Future<void> fetchInvoices() async {
    try {
      final response = await Supabase.instance.client
          .from('accountsReceivables')
          .select('*');

      setState(() {
        invoices = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching invoices: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        // padding: const EdgeInsets.all(20),
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
          borderRadius: 0,
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
                    height: 30,
                  ),
                  dashboardButton(screenWidth, context, NewOrder.routeName,
                      "New Order", Icons.add_box),
                  const SizedBox(
                    height: 30,
                  ),
                  dashboardButton(
                      screenWidth,
                      context,
                      haulingAdvice.HaulingAdvice.routeName,
                      "Hauling Advice",
                      Icons.car_crash_rounded),
                  const SizedBox(
                    height: 30,
                  ),
                  dashboardButton(screenWidth, context, Monitoring.routeName,
                      "Monitoring", Icons.monitor),
                  const SizedBox(
                    height: 30,
                  ),
                  dashboardButton(screenWidth, context,
                      AccountsReceivables.routeName, "Invoices", Icons.receipt),
                  const SizedBox(
                    height: 30,
                  ),
                  dashboardButton(screenWidth, context, Reports.routeName,
                      "Reports", Icons.list),
                  const SizedBox(
                    height: 30,
                  ),
                  dashboardButton(screenWidth, context, Payroll.routeName,
                      "Pay Roll", Icons.payment),
                  const SizedBox(
                    height: 30,
                  ),
                  dashboardButton(
                      screenWidth,
                      context,
                      fleetManagement.routeName,
                      "Fleet Management",
                      Icons.local_shipping),
                  const SizedBox(height: 30),
                  dashboardButton(screenWidth, context, Profiling.routeName,
                      "Profiling", Icons.account_circle),
                  const SizedBox(
                    height: 50,
                  ),
                  exitButton(screenWidth, context, LoginScreen.routeName),
                ],
              ),
              const SizedBox(
                width: 10,
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
                                        "${orders[index]["custName"]} - ${orders[index]["deliveryAdd"]} ",
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
                                            (DateFormat('MMMM d, y').format(
                                                DateTime.parse(orders[index]
                                                        ["date"] ??
                                                    ""))),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
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
                                  flex: 3,
                                  child: ListView.builder(
                                    itemCount: invoices.length,
                                    itemBuilder: (context, index) {
                                      final invoice = invoices[index];
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
                                            leading: const Icon(Icons.receipt,
                                                color: Colors.white),
                                            title: Text(
                                              "BillingNo: ${invoice['billingNo']} - ${invoice['custName']}",
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
                                                  'Total Amount: \₱${invoice['totalAmount'].toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Amount Paid: \₱${invoice['amountPaid'].toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Paid: ${invoice['paid'] ? "Yes" : "No"}',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withOpacity(0.5),
                          //   borderRadius: BorderRadius.circular(8),
                          // ),
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
                                SizedBox(height: 20),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Table(
                                      border: TableBorder.all(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255)),
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
                                                        color: Color.fromARGB(
                                                            255,
                                                            255,
                                                            255,
                                                            255))),
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
                                                      '${truck['truckID']}',
                                                      style: TextStyle(
                                                          color: Colors.white)),
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
                                                      '${truck['plateNumber']}',
                                                      style: TextStyle(
                                                          color: Colors.white)),
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
                                                      '${truck['driverName']}',
                                                      style: TextStyle(
                                                          color: Colors.white)),
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
                                                      truck['isRepair']
                                                          ? "Under Repair"
                                                          : 'Active',
                                                      style: TextStyle(
                                                          color: Colors.white)),
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

class AccountReceivable {
  final String billingNo;
  final String date;
  final String deliveryAddress;
  // Add other fields as necessary

  AccountReceivable({
    required this.billingNo,
    required this.date,
    required this.deliveryAddress,
    // Initialize other fields
  });

  factory AccountReceivable.fromJson(Map<String, dynamic> json) {
    return AccountReceivable(
      billingNo: json['billingNo']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      deliveryAddress: json['deliveryAdd']?.toString() ?? '',
      // Initialize other fields with type checks and conversions
    );
  }
}
