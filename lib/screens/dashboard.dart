import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:maviken/components/monitor_card.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/management.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/components/dashboard_button.dart';
import 'package:maviken/components/exit_button.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/profiling.dart';
import 'package:maviken/main.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashBoard extends StatefulWidget {
  static const routeName = '/DashBoard';

  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<Map<String, dynamic>> orders = [];

  Future<void> fetchData() async {
    final data = await supabase.from('salesOrder').select('*');
    setState(() {
      orders = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(50),
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://plus.unsplash.com/premium_photo-1663040229714-f9fd192358b0?q=80&w=2938&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
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
                const SizedBox(height: 50),
                dashboardButton(screenWidth, context, Profiling.routeName,
                    "Profiling", Icons.account_circle),
                const SizedBox(
                  height: 50,
                ),
                dashboardButton(screenWidth, context, PriceManagement.routeName,
                    "Management", Icons.price_change),
                const SizedBox(
                  height: 50,
                ),
                exitButton(screenWidth, context, LoginScreen.routeName),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            GlassmorphicFlexContainer(
              borderRadius: 8,
              blur: 8,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.bottomCenter,
              border: 1,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 151, 90, 90).withOpacity(0.1),
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
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text("ORDERS"),
                            Expanded(
                              child: ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: const Icon(Icons.drive_eta_sharp),
                                    title: Text(
                                      orders[index]["custName"] +
                                          " - " +
                                          orders[index]["status"],
                                    ),
                                    subtitle: Text(
                                      orders[index]["date"],
                                    ),
                                    isThreeLine: true,
                                    dense: true,
                                  );
                                },
                              ),
                            ),
                          ],
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
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Text("ACCOUNTS RECEIVABLE"),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: orders.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading:
                                              const Icon(Icons.drive_eta_sharp),
                                          title: Text(
                                            orders[index]["custName"] +
                                                " - " +
                                                orders[index]["status"],
                                          ),
                                          subtitle: Text(
                                            orders[index]["date"],
                                          ),
                                          isThreeLine: true,
                                          dense: true,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Text("TRUCK MANAGEMENT"),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: orders.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading:
                                              const Icon(Icons.drive_eta_sharp),
                                          title: Text(
                                            orders[index]["custName"] +
                                                " - " +
                                                orders[index]["status"],
                                          ),
                                          subtitle: Text(
                                            orders[index]["date"],
                                          ),
                                          isThreeLine: true,
                                          dense: true,
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}
