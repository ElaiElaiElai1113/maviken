import 'package:flutter/material.dart';
import 'package:maviken/screens/newOrderOwner.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/HaulingAdvice.dart';
import 'package:maviken/main.dart';

class DashBoard extends StatelessWidget {
  static const routeName = '/DashBoard';
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: const Color(0xFFFCF7E6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text('Welcome!',
                style: TextStyle(fontSize: 64, color: Colors.black)),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
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
                  Navigator.pushNamed(context, NewOrder.routeName);
                },
                child: const Text('New Order',
                    style: TextStyle(color: Colors.white, letterSpacing: 2)),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
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
                  Navigator.pushNamed(context, HaulingAdvice.routeName);
                },
                child: const Text('Hauling Advice',
                    style: TextStyle(color: Colors.white, letterSpacing: 2)),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
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
                  Navigator.pushNamed(context, Monitoring.routeName);
                },
                child: const Text('Monitoring',
                    style: TextStyle(color: Colors.white, letterSpacing: 2)),
              ),
            ),
            const SizedBox(height: 50),
            Wrap(children: [
              SizedBox(
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
                        Color.fromARGB(255, 192, 146, 67)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginScreen.routeName);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                        semanticLabel: 'Exit',
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Exit', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
