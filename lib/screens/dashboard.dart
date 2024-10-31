import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/components/dashboard_button.dart';
import 'package:maviken/components/exit_button.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/profiling.dart';

class DashBoard extends StatelessWidget {
  static const routeName = '/DashBoard';

  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // return Scaffold(
    //   drawer: const BarTop(),
    //   body: SidebarDrawer(
    //     drawer: const BarTop(),
    //     body: Container(
    //         color: Colors.white,
    //         width: screenWidth,
    //         height: screenHeight,
    //         child: Expanded(
    //           child: Column(
    //             children: [
    //               Expanded(
    //                 child: SingleChildScrollView(
    //                   child: Container(
    //                     color: Colors.white,
    //                     padding: const EdgeInsets.all(25),
    //                     child: Container(
    //                       padding: const EdgeInsets.all(25),
    //                       decoration: BoxDecoration(
    //                         color: Colors.grey[100],
    //                         borderRadius: BorderRadius.circular(10),
    //                         boxShadow: [
    //                           BoxShadow(
    //                             color: Colors.grey.withOpacity(.5),
    //                             spreadRadius: 5,
    //                             blurRadius: 7,
    //                             offset: const Offset(0, 3),
    //                           ),
    //                         ],
    //                       ),
    //                       child: Container(
    //                         child: Column(
    //                             crossAxisAlignment: CrossAxisAlignment.center,
    //                             children: [
    //                               Container(
    //                                 child: Column(
    //                                   children: [
    //                                     Text(
    //                                       "Truck",
    //                                       style: TextStyle(
    //                                         color: Color(0xFFeab557),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                               Container(
    //                                 child: Column(
    //                                   children: [
    //                                     Text(
    //                                       "Employees",
    //                                       style: TextStyle(
    //                                         color: Color(0xFFeab557),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                               Container(
    //                                 child: Column(
    //                                   children: [
    //                                     Text(
    //                                       "Orders",
    //                                       style: TextStyle(
    //                                         color: Color(0xFFeab557),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ]),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         )),
    //   ),
    // );

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
                    color: Color(0xFFeab557),
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
                dashboardButton(screenWidth, context, Profiling.routeName,
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
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFffffff).withOpacity(0.5),
                  const Color((0xFFFFFFFF)).withOpacity(0.5),
                ],
              ),
              child: null,
            ),
          ],
        ),
      ),
    );
  }
}
            // Container(
            //   color: Colors.white,
            //   child: const Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Text(
            //         "Truck",
            //         style: TextStyle(
            //           color: Color(0xFFeab557),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Container(
            //   color: Colors.white,
            //   child: const Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Text(
            //         "Employees",
            //         style: TextStyle(
            //           color: Color(0xFFeab557),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Container(
            //   color: Colors.white,
            //   child: const Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Text(
            //         "Orders",
            //         style: TextStyle(
            //           color: Color(0xFFeab557),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),