import 'package:flutter/material.dart';

Widget title(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.grey[800],
    ),
    textAlign: TextAlign.center,
  );
}
