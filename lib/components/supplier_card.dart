import 'package:flutter/material.dart';

class SupplierCard extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String addressLine;
  final String city;
  final String barangay;
  final String contactNo;
  final String description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const SupplierCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.addressLine,
    required this.city,
    required this.barangay,
    required this.contactNo,
    required this.description,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<SupplierCard> createState() => _SupplierCardState();
}

class _SupplierCardState extends State<SupplierCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text('First Name: ${widget.firstName}'),
          Text('Last Name: ${widget.lastName}'),
          Text('Description: ${widget.description}'),
          Text('Address: ${widget.addressLine}'),
          Text('City: ${widget.city}'),
          Text('Barangay: ${widget.barangay}'),
          Text('Contact Number: ${widget.contactNo}'),
          IconButton(
              onPressed: widget.onDelete, icon: const Icon(Icons.delete)),
          IconButton(onPressed: widget.onEdit, icon: const Icon(Icons.edit)),
        ],
      ),
    );
  }
}
