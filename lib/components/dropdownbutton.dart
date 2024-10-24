import 'package:flutter/material.dart';

Widget dropDown(
  String labelText,
  List<Map<String, dynamic>> items,
  Map<String, dynamic>? selectedItem,
  ValueChanged<Map<String, dynamic>?> onChanged,
  String databaseItem,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        labelText,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100], // Light background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
          border: Border.all(color: Colors.grey[300]!), // Light border
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Soft shadow
              blurRadius: 8,
              offset: const Offset(2, 4), // Shadow position
            ),
          ],
        ),
        child: DropdownButton<Map<String, dynamic>>(
          hint: const Text(
            'Select an item',
            style: TextStyle(color: Colors.grey),
          ),
          value: selectedItem,
          onChanged: onChanged,
          isExpanded: true, // Makes sure the dropdown expands fully
          underline: Container(), // Remove underline
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          items: items.map<DropdownMenuItem<Map<String, dynamic>>>(
              (Map<String, dynamic> value) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: value,
              child: Text(
                value[databaseItem],
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}
