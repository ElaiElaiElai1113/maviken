import 'package:flutter/material.dart';

class CustomerCard extends StatefulWidget {
  final String customerID;
  final String company;
  final String repFirstName;
  final String repLastName;
  final String description;
  final String addressLine;
  final String city;
  final String barangay;
  final String contactNum;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const CustomerCard({
    super.key,
    required this.customerID,
    required this.company,
    required this.repFirstName,
    required this.repLastName,
    required this.description,
    required this.addressLine,
    required this.city,
    required this.barangay,
    required this.contactNum,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          IconButton(onPressed: widget.onEdit, icon: Icon(Icons.edit)),
          IconButton(onPressed: widget.onDelete, icon: Icon(Icons.delete)),
          Text('Customer ID: ${widget.customerID}'),
          Text('Company: ${widget.company}'),
          Text('First Name: ${widget.repFirstName}'),
          Text('Last Name: ${widget.repLastName}'),
          Text('Description: ${widget.description}'),
          Text('Address: ${widget.addressLine}'),
          Text('City: ${widget.city}'),
          Text('Barangay: ${widget.barangay}'),
          Text('Contact Number: ${widget.contactNum}'),
        ],
      ),
    );
  }
}
