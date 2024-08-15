import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:maviken/functions.dart';

final TextEditingController firstName = TextEditingController();
final TextEditingController lastName = TextEditingController();
final TextEditingController eaddressLine = TextEditingController();
final TextEditingController econtactNum = TextEditingController();
final TextEditingController ebarangay = TextEditingController();
final TextEditingController ecity = TextEditingController();

class ProfileEmployee extends StatefulWidget {
  static const routeName = '/ProfileEmployee';

  const ProfileEmployee({super.key});

  @override
  State<ProfileEmployee> createState() => _ProfileEmployeeState();
}

class _ProfileEmployeeState extends State<ProfileEmployee> {
  List<String> items = [];
  String selectedItem = "";
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(size: 20),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text("Employee"),
      ),
      drawerEnableOpenDragGesture: false,
      drawer: const BarTop(),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.white,
        padding: const EdgeInsets.all(50),
        child: Container(
          padding: const EdgeInsets.all(100),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
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
                        child: TextField(
                          controller: firstName,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'First Name',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * .05,
                        height: screenHeight * .1,
                      ),
                      SizedBox(
                        width: screenWidth * .15,
                        height: screenHeight * .1,
                        child: TextField(
                          controller: lastName,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Last Name',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth * .5,
                    height: screenHeight * .1,
                    child: TextField(
                      controller: caddressLine,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        labelText: 'Address',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * .5,
                        height: screenHeight * .1,
                        child: TextField(
                          controller: ccontactNum,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Contact Number',
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
                        child: TextField(
                          controller: ebarangay,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Barangay',
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
                        child: TextField(
                          controller: ccity,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'City',
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
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 111, 90, 53),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, ProfileEmployee.routeName);
                      },
                      child: const Text(
                        'Employee',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * .08,
                    height: screenHeight * .1,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 111, 90, 53),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, ProfileCustomer.routeName);
                      },
                      child: const Text(
                        'Customer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * .08,
                    height: screenHeight * .1,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 111, 90, 53),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, ProfileSupplier.routeName);
                      },
                      child: const Text(
                        'Supplier',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * .08,
                    height: screenHeight * .1,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 111, 90, 53),
                        ),
                      ),
                      onPressed: () {
                        createEmployee();
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
