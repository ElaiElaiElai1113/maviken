import 'package:flutter/material.dart';

class LoadCard extends StatefulWidget {
  final String price;
  final String totalVolume;
  final String volumeDel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const LoadCard(
      {super.key,
      required this.price,
      required this.totalVolume,
      required this.volumeDel,
      required this.onEdit,
      required this.onDelete});

  @override
  State<LoadCard> createState() => _LoadCardState();
}

class _LoadCardState extends State<LoadCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Card(
      child: Column(
        children: [
          Text(widget.price),
          Text(widget.totalVolume),
          Text(widget.volumeDel),
          IconButton(onPressed: widget.onEdit, icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: widget.onDelete, icon: const Icon(Icons.delete)),
        ],
      ),
    ));
  }
}
