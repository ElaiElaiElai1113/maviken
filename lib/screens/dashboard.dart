import 'package:flutter/material.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/HaulingAdvice.dart';
import 'package:maviken/screens/newOrderOwner.dart';
import 'package:maviken/components/dashboardButton.dart';
import 'package:maviken/components/exitButton.dart';
import 'package:maviken/screens/loginScreen.dart';

class DashBoard extends StatelessWidget {
  static const routeName = '/DashBoard';
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: const Color(0xFFFCF7E6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text('Dashboard',
                style: TextStyle(fontSize: 64, color: Colors.black)),
            const SizedBox(
              height: 50,
            ),
            dashboardButton(
                screenWidth, context, NewOrder.routeName, "New Order"),
            const SizedBox(
              height: 50,
            ),
            dashboardButton(screenWidth, context, HaulingAdvice.routeName,
                "Hauling Advice"),
            const SizedBox(
              height: 50,
            ),
            dashboardButton(
                screenWidth, context, Monitoring.routeName, "Monitoring"),
            const SizedBox(height: 50),
            exitButton(screenWidth, context, LoginScreen.routeName),
          ],
        ),
      ),
    );
  }
}
