import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/screens/profile_employee.dart';
import 'package:maviken/screens/profile_supplier.dart';

final TextEditingController comName = TextEditingController();
final TextEditingController repName = TextEditingController();
final TextEditingController ccontactNum = TextEditingController();
final TextEditingController cDescription = TextEditingController();
final TextEditingController caddressLine = TextEditingController();
final TextEditingController ccity = TextEditingController();

class ProfileCustomer extends StatefulWidget {
  static const routeName = '/ProfileCustomer';

  const ProfileCustomer({super.key});

  @override
  State<ProfileCustomer> createState() => _ProfileEmployeeState();
}

class _ProfileEmployeeState extends State<ProfileCustomer> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(size: 20),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      drawerEnableOpenDragGesture: false,
      drawer: const BarTop(),
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
                        child: TextField(
                          controller: comName,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Company Name',
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
                        child: const TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Representative Name',
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
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFCF7E6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * .5,
                    height: screenHeight * .1,
                    child: const TextField(
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFCF7E6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        labelText: 'Contact Number',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * .35,
                        height: screenHeight * .1,
                        child: const TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Address',
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
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
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
                      onPressed: () {},
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
