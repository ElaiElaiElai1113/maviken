import 'package:flutter/material.dart';

Widget infoLabel(String label) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget infoValue(String value) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
