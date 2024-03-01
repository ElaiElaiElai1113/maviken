import 'package:flutter/material.dart';
import 'package:maviken/screens/HaulingAdvice.dart';
import 'package:maviken/screens/newOrderOwner.dart';

class Monitoring extends StatelessWidget {
  static const routeName = '/Monitoring';
  const Monitoring({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF7E6),
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * .13,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFffca61),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: 50,
                        width: screenWidth * .15,
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            elevation: MaterialStatePropertyAll(2),
                            backgroundColor: MaterialStatePropertyAll(
                              Color(0xffFFBA41),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, NewOrder.routeName);
                          },
                          child: const Text('New Order',
                              style: TextStyle(
                                  color: Colors.white, letterSpacing: 2)),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: screenWidth * .15,
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            elevation: MaterialStatePropertyAll(2),
                            backgroundColor: MaterialStatePropertyAll(
                              Color(0xffFFBA41),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, Monitoring.routeName);
                          },
                          child: const Text('Monitoring',
                              style: TextStyle(
                                  color: Colors.white, letterSpacing: 2)),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: screenWidth * .15,
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            elevation: MaterialStatePropertyAll(2),
                            backgroundColor: MaterialStatePropertyAll(
                              Color(0xffFFBA41),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, HaulingAdvice.routeName);
                          },
                          child: const Text('HaulingAdvice',
                              style: TextStyle(
                                  color: Colors.white, letterSpacing: 2)),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: screenWidth * .15,
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            elevation: MaterialStatePropertyAll(2),
                            backgroundColor: MaterialStatePropertyAll(
                              Color(0xffFFBA41),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Cashflow',
                              style: TextStyle(
                                  color: Colors.white, letterSpacing: 2)),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: screenWidth * .15,
                        child: ElevatedButton(
                          style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            elevation: MaterialStatePropertyAll(2),
                            backgroundColor: MaterialStatePropertyAll(
                              Color(0xffFFBA41),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Logout',
                              style: TextStyle(
                                  color: Colors.white, letterSpacing: 2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  color: Colors.red,
                  child: SizedBox(
                    width: 500,
                    height: 300,
                    child: Column(
                      children: [
                        Text("0011"),
                        Text("Jejors"),
                        Text("V 21"),
                        Text("Digos, Ruparan"),
                        Text("3,500"),
                        Text("Coarse Sand"),
                        Text("210 Cu. M."),
                      ],
                    ),
                  ),
                ),
                  Card(
                  color: Colors.red,
                  child: SizedBox(
                    width: 500,
                    height: 300,
                  ),
                ),
              ],
            ),
          ],
        ),
       ),
      ),
    );
  }
}
