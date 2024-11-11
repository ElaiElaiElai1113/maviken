import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/accountsReceivables.dart';
import 'package:maviken/screens/fleetManage.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/management.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/components/dashboard_button.dart';
import 'package:maviken/components/exit_button.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/profiling.dart';
import 'package:maviken/main.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class DashBoard extends StatefulWidget {
  static const routeName = '/DashBoard';

  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> orderload = [];

  Future<void> fetchData() async {
    final data = await supabase.from('salesOrder').select('*');
    setState(() {
      orders = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> fetchDataorder() async {
    try {
      final datas = await supabase.from('salesOrder').select(
          'salesOrder_id, custName, salesOrderLoad(salesOrder_id, totalVolume)');

      setState(() {
        orderload = List<Map<String, dynamic>>.from(datas);
      });
    } catch (error) {}
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDataorder();
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
                  dashboardButton(screenWidth, context, HaulingAdvice.routeName,
                      "Hauling Advice", Icons.car_crash_rounded),
                  const SizedBox(
                    height: 50,
                  ),
                  dashboardButton(screenWidth, context, Monitoring.routeName,
                      "Monitoring", Icons.monitor),
                  const SizedBox(
                    height: 50,
                  ),
                  dashboardButton(
                      screenWidth,
                      context,
                      Accountsreceivables.routeName,
                      "Accounts Receivable",
                      Icons.monitor),
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
                                  "ACCOUNTS RECEIVABLE",
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
                        padding: const EdgeInsets.all(20.0),
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
