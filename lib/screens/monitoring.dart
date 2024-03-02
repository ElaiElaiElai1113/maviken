import 'package:flutter/material.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/HaulingAdvice.dart';
import 'package:maviken/screens/newOrderOwner.dart';

class Monitoring extends StatelessWidget {
  static const routeName = '/Monitoring';
  const Monitoring({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData(
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.white),
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
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
                              Color(0xFF0C2233),
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
                              Color(0xFF0C2233),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, HaulingAdvice.routeName);
                          },
                          child: const Text('Hauling Advice',
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
                              Color(0xFF0C2233),
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
                      Wrap(children: [
                        ElevatedButton(
                          style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            elevation: MaterialStatePropertyAll(2),
                            backgroundColor: MaterialStatePropertyAll(
                              Color(0xFF0C2233),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, LoginScreen.routeName);
                          },
                          child: const Icon(
                            Icons.logout,
                            color: Colors.white,
                            semanticLabel: 'Exit',
                          ),
                        ),
                      ]),
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
            color: const Color(0xFFffca61),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Wrap(
                    direction: Axis.horizontal,
                    children: [
                      Card(
                        color: Color(0xFF0C2233),
                        child: SizedBox(
                          width: 500,
                          height: 300,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("0011"),
                                  Text("Jejors"),
                                  Text("Digos, Ruparan"),
                                  Text("Coarse Sand"),
                                  Divider(),
                                  Text("Cu. M."),
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFffca61),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("06/11/24"),
                                  Text("V 21"),
                                  Text("3,500"),
                                  Text("210 Cu. M."),
                                  Divider(),
                                  Text("loads"),
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFffca61),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                      ),
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
}
