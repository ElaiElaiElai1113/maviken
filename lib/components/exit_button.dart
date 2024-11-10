import 'package:flutter/material.dart';
import 'package:maviken/main.dart';

Wrap exitButton(double screenWidth, BuildContext context, routeName) {
  return Wrap(children: [
    SizedBox(
      height: 50,
      width: screenWidth * .15,
      child: ElevatedButton(
        style: const ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
          elevation: WidgetStatePropertyAll(2),
          backgroundColor: WidgetStatePropertyAll(Colors.orangeAccent),
        ),
        onPressed: () {
          supabase.auth.signOut();
          Navigator.popAndPushNamed(context, routeName);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.black54,
              semanticLabel: 'Exit',
            ),
            SizedBox(
              width: 10,
            ),
            Text('Exit',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
  ]);
}
