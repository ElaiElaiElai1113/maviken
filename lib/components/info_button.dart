import 'package:flutter/material.dart';

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
