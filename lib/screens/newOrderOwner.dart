import 'package:flutter/material.dart';
import 'package:maviken/screens/Monitoring.dart';



class NewOrder extends StatelessWidget {
  static const routeName = '/NewOrder';
  const NewOrder({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFCF7E6),
          automaticallyImplyLeading: false,
          toolbarHeight: screenHeight * .13,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              decoration: BoxDecoration(
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
        body: Container(
          color: Color(0xFFFCF7E6),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20
              ),
            child: Container(
              width: screenWidth * 1,
              height: screenHeight * .8,
              decoration: BoxDecoration(
              color: Color(0xFFF8E6C3),
              borderRadius: BorderRadius.circular(20)
              ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                      TextField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFeab557),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)
                            ),
                          ),
                          labelText: 'Purchase Order Number',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    
                      TextField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFeab557),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        labelText: 'Date',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                      TextField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFeab557),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        labelText: 'Customer Name',
                        labelStyle: TextStyle(color: Colors.black),
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
