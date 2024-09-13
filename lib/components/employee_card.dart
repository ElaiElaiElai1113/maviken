import 'package:flutter/material.dart';

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
  final bool showLabels;

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
    this.showLabels = false,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  double cardHeight = 0;
  double cardWidth = 0;

  @override
  void initState() {
    super.initState();
    cardHeight = widget.initialHeight;
    cardWidth = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showLabels)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  infoLabel('ID:'),
                  infoLabel('First Name:'),
                  infoLabel('Last Name:'),
                  infoLabel('Position:'),
                  infoLabel('Address:'),
                  infoLabel('City:'),
                  infoLabel('Barangay:'),
                  infoLabel('Contact Number:'),
                  infoLabel('Truck:'),
                ],
              ),
            const SizedBox(height: 50),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.edit),
                ),
                infoValue(widget.employeeID),
                infoValue(widget.firstName),
                infoValue(widget.lastName),
                infoValue(widget.position),
                infoValue(widget.address),
                infoValue(widget.city),
                infoValue(widget.barangay),
                infoValue(widget.contact),
                infoValue(widget.truck),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoLabel(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget infoValue(String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          value,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
