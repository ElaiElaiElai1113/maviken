import 'package:flutter/material.dart';
import 'package:maviken/screens/newOrderOwner.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/main.dart';

class HaulingAdvice extends StatelessWidget {
  static const routeName = '/HaulingAdvice';
  const HaulingAdvice({super.key});

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
                              Color(0xFFeab557),
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
                              Color(0xFFeab557),
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
                              Color(0xFFeab557),
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
                              Color(0xFFeab557),
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
          padding: const EdgeInsets.all(150),
          decoration: BoxDecoration(
            color: const Color(0xFFF8E6C3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * .3,
                        height: screenHeight * .1,
                        child: const TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Purchase Order Number',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * .5,
                        height: screenHeight * .1,
                      ),
                      SizedBox(
                        width: screenWidth * .15,
                        height: screenHeight * .1,
                        child: const TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'YY/MM/DD',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth * .5,
                    height: screenHeight * .1,
                    child: const TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFCF7E6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        labelText: 'Customer Name',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * .5,
                        height: screenHeight * .1,
                        child: const TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Site/Address',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * .35,
                        height: screenHeight * .1,
                        child: const TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * .05,
                        height: screenHeight * .1,
                      ),
                      SizedBox(
                        width: screenWidth * .1,
                        height: screenHeight * .1,
                        child: const TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Quantity',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * .08,
                    height: screenHeight * .1,
                  ),
                  SizedBox(
                    width: screenWidth * .08,
                    height: screenHeight * .1,
                    child: const TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFCF7E6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        labelText: 'Volume',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * .08,
                    height: screenHeight * .1,
                    child: const TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFCF7E6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        labelText: 'Price',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * .08,
                    height: screenHeight * .1,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                            Color(0xFFeab557),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Color(0xFFFCF7E6),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
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
