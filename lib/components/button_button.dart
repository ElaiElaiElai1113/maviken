import 'package:flutter/material.dart';

SizedBox bottomButton(
    double screenWidth, BuildContext context, String texttitle, routeName) {
  return SizedBox(
    width: screenWidth * .15,
    child: TextButton(
      onPressed: () async {
        Navigator.pushNamed(context, routeName);
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          texttitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue),
        ),
      ),
    ),
  );
}
