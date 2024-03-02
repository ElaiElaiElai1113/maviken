import 'package:flutter/material.dart';
import 'package:maviken/screens/newOrderOwner.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/HaulingAdvice.dart';

class DashBoard extends StatelessWidget {
  static const routeName = '/DashBoard';
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 50,
            width: screenWidth * .15,
            child: ElevatedButton(
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                elevation: MaterialStatePropertyAll(2),
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xFF0C2233),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, NewOrder.routeName);
              },
              child: const Text('New Order',
                  style: TextStyle(color: Colors.white, letterSpacing: 2)),
            ),
          ),
          SizedBox(
            height: 50,
            width: screenWidth * .15,
            child: ElevatedButton(
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                elevation: MaterialStatePropertyAll(2),
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xFF0C2233),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, HaulingAdvice.routeName);
              },
              child: const Text('Hauling Advice',
                  style: TextStyle(color: Colors.white, letterSpacing: 2)),
            ),
          ),
          SizedBox(
            height: 50,
            width: screenWidth * .15,
            child: ElevatedButton(
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                elevation: MaterialStatePropertyAll(2),
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xFF0C2233),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, Monitoring.routeName);
              },
              child: const Text('Monitoring',
                  style: TextStyle(color: Colors.white, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
