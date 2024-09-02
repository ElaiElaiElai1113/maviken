import 'package:flutter/material.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profile_employee.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:maviken/screens/profile_trucks.dart';

Row profilingButtons(
    double screenWidth, double screenHeight, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      chooseProfiling(
        screenWidth,
        screenHeight,
        "Employee",
        Colors.orangeAccent,
        () => Navigator.popAndPushNamed(context, ProfileEmployee.routeName),
      ),
      chooseProfiling(
        screenWidth,
        screenHeight,
        "Customer",
        Colors.orangeAccent,
        () => Navigator.popAndPushNamed(context, ProfileCustomer.routeName),
      ),
      chooseProfiling(
        screenWidth,
        screenHeight,
        "Supplier",
        Colors.orangeAccent,
        () => Navigator.popAndPushNamed(context, ProfileSupplier.routeName),
      ),
      chooseProfiling(
        screenWidth * 1.25,
        screenHeight,
        "Truck/Load",
        Colors.orangeAccent,
        () => Navigator.popAndPushNamed(context, ProfileTrucks.routeName),
      ),
    ],
  );
}

SizedBox chooseProfiling(double screenWidth, double screenHeight,
    String profiling, Color? color, VoidCallback routing) {
  return SizedBox(
    width: screenWidth * .1,
    height: screenHeight * .05,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: color),
      onPressed: routing,
      child: Text(
        profiling,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
