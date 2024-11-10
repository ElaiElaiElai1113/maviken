import "package:flutter/material.dart";

SizedBox dashboardButton(
  double screenWidth,
  BuildContext context,
  String route,
  String title,
  IconData icon,
) {
  return SizedBox(
    height: 50,
    width: screenWidth * .15,
    child: ElevatedButton(
      style: const ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        elevation: WidgetStatePropertyAll(2),
        backgroundColor: WidgetStatePropertyAll(
          Colors.orangeAccent,
        ),
      ),
      onPressed: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(color: Colors.white, letterSpacing: 2)),
        ],
      ),
    ),
  );
}
