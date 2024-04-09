import 'package:flutter/material.dart';
import 'package:maviken/screens/create_account.dart';

Padding textFieldBar(value, icon, controllerType) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 70),
    child: TextField(
      controller: controllerType,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFeab557),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: icon,
        prefixIconColor: Colors.white,
        labelText: value,
        labelStyle: const TextStyle(color: Colors.white),
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
        fillColor: const Color(0xFFeab557),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: icon,
        prefixIconColor: Colors.white,
        labelText: value,
        labelStyle: const TextStyle(color: Colors.white),
      ),
    ),
  );
}
