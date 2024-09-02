import 'package:maviken/main.dart';
import 'package:flutter/material.dart';

class TruckCard extends StatefulWidget {
  final String plateNumber;
  final String brand;
  final String model;
  final String year;
  final String color;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const TruckCard({
    super.key,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.onDelete,
    required this.onEdit,
  });
  @override
  State<TruckCard> createState() => _TruckCardState();
}

class _TruckCardState extends State<TruckCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          IconButton(onPressed: widget.onEdit, icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: widget.onDelete, icon: const Icon(Icons.delete)),
          Text('Plate Number: ${widget.plateNumber}'),
          Text('Brand: ${widget.brand}'),
          Text('Model: ${widget.model}'),
          Text('Year: ${widget.year}'),
          Text('Color: ${widget.color}'),
        ],
      ),
    );
  }
}
