import 'package:flutter/material.dart';
import 'package:maviken/screens/newOrderOwner.dart';
import 'package:maviken/screens/Monitoring.dart';

class DashBoard extends StatelessWidget {
  static const routeName = '/DashBoard';
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * .13,
        backgroundColor: const Color(0xFFFCF7E6),
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
                          onPressed: () {},
                          child: const Text('Delivery Receipts',
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
    );
  }
}
