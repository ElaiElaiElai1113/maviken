import 'package:flutter/material.dart';
import 'package:maviken/screens/profiling.dart';

SizedBox infoButton(double screenWidth, double screenHeight, String info,
    TextEditingController? controller) {
  return SizedBox(
    width: screenWidth,
    height: screenHeight,
    child: TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        labelText: info,
        labelStyle: const TextStyle(color: Colors.black),
      ),
    ),
  );
}

Widget textFieldDate(
    TextEditingController controller, String labelText, BuildContext context,
    {double width = .5}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * width,
    child: TextField(
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
      readOnly: true,
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2500),
        );
        if (pickedDate != null) {
          controller.text = "${pickedDate.toLocal()}".split(' ')[0];
        }
      },
    ),
  );
}
