import 'package:flutter/material.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profile_employee.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:maviken/screens/profile_trucks.dart';

class ProfilingDropdown extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String? initialProfiling;
  const ProfilingDropdown(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      this.initialProfiling});

  @override
  _ProfilingDropdownState createState() => _ProfilingDropdownState();
}

class _ProfilingDropdownState extends State<ProfilingDropdown> {
  String? selectedProfiling;

  @override
  void initState() {
    super.initState();
    selectedProfiling = widget.initialProfiling;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: const Text(
        "Select Profile",
        style: TextStyle(
          color: Colors.orangeAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      value: selectedProfiling,
      icon: const Icon(
        Icons.arrow_drop_down,
      ),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(fontSize: 18),
      underline: Container(
        height: 2,
      ),
      onChanged: (String? newValue) {
        setState(() {
          selectedProfiling = newValue;
        });

        switch (newValue) {
          case "Employee":
            Navigator.popAndPushNamed(context, ProfileEmployee.routeName);
            break;
          case "Customer":
            Navigator.popAndPushNamed(context, ProfileCustomer.routeName);
            break;
          case "Supplier":
            Navigator.popAndPushNamed(context, ProfileSupplier.routeName);
            break;
          case "Truck/Load":
            Navigator.popAndPushNamed(context, ProfileTrucks.routeName);
            break;
        }
      },
      items: <String>['Employee', 'Customer', 'Supplier', 'Truck/Load']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
