import 'package:flutter/material.dart';

Padding textFieldBar(value, icon, controllerType) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 70),
    child: TextField(
      controller: controllerType,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 252, 250, 245),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: icon,
        prefixIconColor: Colors.black87,
        labelText: value,
        labelStyle: const TextStyle(color: Colors.black54),
      ),
    ),
  );
}

Padding textFieldBarPass(value, icon, controllerType, boolPass) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 70),
    child: TextField(
      obscureText: boolPass,
      controller: controllerType,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 252, 250, 245),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: icon,
        prefixIconColor: Colors.black87,
        labelText: value,
        labelStyle: const TextStyle(color: Colors.black54),
      ),
    ),
  );
}
