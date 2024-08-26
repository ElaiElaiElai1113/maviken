import 'package:flutter/material.dart';
import 'package:maviken/main.dart';

class EmployeeCard extends StatefulWidget {
  final String employeeID;
  final String lastName;
  final String firstName;
  final String position;
  final String address;
  final String city;
  final String barangay;
  final String contact;
  final String truck;
  final double screenWidth;
  final double initialHeight;
  final double initialWidth;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const EmployeeCard({
    super.key,
    required this.employeeID,
    required this.lastName,
    required this.firstName,
    required this.position,
    required this.address,
    required this.city,
    required this.barangay,
    required this.contact,
    required this.truck,
    required this.screenWidth,
    required this.initialHeight,
    required this.initialWidth,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  double cardHeight = 0;
  double cardWidth = 0;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    cardHeight = widget.initialHeight;
    cardWidth = widget.initialWidth;
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Card(
            child: Column(
              children: [
                Text('ID: ${widget.employeeID} '),
                Text('First Name: ${widget.firstName} '),
                Text('Last Name: ${widget.lastName} '),
                Text('Position: ${widget.position} '),
                Text('Address: ${widget.address} '),
                Text('City: ${widget.city} '),
                Text('Barangay: ${widget.barangay} '),
                Text('Contact Number: ${widget.contact} '),
                Text('Truck: ${widget.truck} '),
                IconButton(
                    onPressed: widget.onDelete, icon: const Icon(Icons.delete)),
                IconButton(
                    onPressed: widget.onEdit, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
