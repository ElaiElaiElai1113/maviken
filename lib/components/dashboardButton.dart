import "package:flutter/material.dart";

SizedBox dashboardButton(
    double screenWidth, BuildContext context, String route, String title) {
  return SizedBox(
    height: 50,
    width: screenWidth * .15,
    child: ElevatedButton(
      style: const ButtonStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        elevation: MaterialStatePropertyAll(2),
        backgroundColor: MaterialStatePropertyAll(
          Color(0xFFeab557),
        ),
      ),
      onPressed: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: Text(title,
          style: const TextStyle(color: Colors.white, letterSpacing: 2)),
    ),
  );
}
