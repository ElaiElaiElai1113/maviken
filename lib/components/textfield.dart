import 'package:flutter/material.dart';
import 'package:maviken/screens/new_order.dart';

Widget textField(TextEditingController controller, String labelText, context,
    {bool enabled = false, double width = .5}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * width,
    child: TextField(
      enabled: enabled,
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
    ),
  );
}
