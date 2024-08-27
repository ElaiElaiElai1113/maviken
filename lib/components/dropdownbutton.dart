import 'package:flutter/material.dart';

Widget dropDown(
  String labelText,
  List<Map<String, dynamic>> items,
  Map<String, dynamic>? selectedItem,
  ValueChanged<Map<String, dynamic>?> onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        labelText,
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      ),
      const SizedBox(height: 10),
      DropdownButton<Map<String, dynamic>>(
        hint: const Text('Select an item'),
        value: selectedItem,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<Map<String, dynamic>>>(
            (Map<String, dynamic> value) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: value,
            child: Text(
              value['positionName'],
              style: TextStyle(color: Colors.grey[700]),
            ),
          );
        }).toList(),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
        underline: Container(),
        style: TextStyle(color: Colors.grey[700]),
      ),
    ],
  );
}
