import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';

class Monitoring extends StatelessWidget {
  static const routeName = '/Monitoring';

  const Monitoring({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const BarTop(),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: const Color(0xFFFCF7E6),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8E6C3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      monitorCard(),
                      monitorCard(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card monitorCard() {
    return Card(
      color: const Color(0xFFffca61),
      child: SizedBox(
        width: 500,
        height: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("0011"),
                const Text("Jejors"),
                const Text("Digos, Ruparan"),
                const Text("Coarse Sand"),
                const Divider(),
                const Text("Cu. M."),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFeab557),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "0/21,000",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("06/11/24"),
                const Text("V 21"),
                const Text("3,500"),
                const Text("210 Cu. M."),
                const Divider(),
                const Text("loads"),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFeab557),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "0/21",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
