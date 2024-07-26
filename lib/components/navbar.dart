import 'package:flutter/material.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/screens/profile_employee.dart';

class BarTop extends StatelessWidget implements PreferredSizeWidget {
  const BarTop({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return AppBar(
      backgroundColor: Color.fromARGB(255, 11, 14, 17),
      automaticallyImplyLeading: false,
      toolbarHeight: screenHeight * .13,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
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
                        Color.fromARGB(255, 243, 186, 47),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, NewOrder.routeName);
                    },
                    child: const Text('New Order',
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold)),
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
                        Color.fromARGB(255, 243, 186, 47),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, HaulingAdvice.routeName);
                    },
                    child: const Text('Hauling Advice',
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold)),
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
                        Color.fromARGB(255, 243, 186, 47),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, Monitoring.routeName);
                    },
                    child: const Text('Monitoring',
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold)),
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
                        Color.fromARGB(255, 243, 186, 47),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, ProfileEmployee.routeName);
                    },
                    child: const Text('Profiling',
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold)),
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
                        Color(0xFF6F5A35),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, DashBoard.routeName);
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
    );
  }
}
