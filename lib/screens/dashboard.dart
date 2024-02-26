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
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
      ),
          toolbarHeight: screenHeight * .08,
          backgroundColor: const Color(0xffeab557),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
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
                            Color(0xff0a438f),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, NewOrder.routeName);
                        },
                        child: const Text('New Order',
                            style:
                                TextStyle(color: Colors.white, letterSpacing: 2)),
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
                            Color(0xff0a438f),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, Monitoring.routeName);
                        },
                        child: const Text('Monitoring',
                            style:
                                TextStyle(color: Colors.white, letterSpacing: 2)),
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
                            Color(0xff0a438f),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Delivery Receipts',
                            style:
                                TextStyle(color: Colors.white, letterSpacing: 2)),
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
                            Color(0xff0a438f),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Accounts Receivables',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white, letterSpacing: 2)),
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
                            Color(0xff0a438f),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Expenses',
                            style:
                                TextStyle(color: Colors.white, letterSpacing: 2)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
