import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/screens/all_customer.dart';
import 'package:maviken/screens/profile_employee.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:maviken/screens/all_customer.dart';

final TextEditingController comName = TextEditingController();
final TextEditingController repLastName = TextEditingController();
final TextEditingController repFirstName = TextEditingController();
final TextEditingController ccontactNum = TextEditingController();
final TextEditingController cDescription = TextEditingController();
final TextEditingController cBarangay = TextEditingController();
final TextEditingController caddressLine = TextEditingController();
final TextEditingController ccity = TextEditingController();

class ProfileCustomer extends StatefulWidget {
  static const routeName = '/ProfileCustomer';

  const ProfileCustomer({super.key});

  @override
  State<ProfileCustomer> createState() => _ProfileEmployeeState();
}

class _ProfileEmployeeState extends State<ProfileCustomer> {
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const BarTop(),
      body: SidebarDrawer(
        drawer: const BarTop(),
        body: Container(
          color: Colors.white,
          width: screenWidth,
          height: screenHeight,
          child: Column(children: [
            AppBar(
              backgroundColor: Colors.white,
              leading: const DrawerIcon(),
              title: const Text("Customer Profiling"),
            ),
            Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * .1,
                          height: screenHeight * .05,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.orangeAccent),
                            onPressed: () {
                              Navigator.popAndPushNamed(
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
                          width: screenWidth * .1,
                          height: screenHeight * .05,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.orange),
                            onPressed: () {
                              Navigator.pushNamed(
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
                          width: screenWidth * .1,
                          height: screenHeight * .05,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.orangeAccent),
                            onPressed: () {
                              Navigator.pushNamed(
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
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * .08,
                          height: screenHeight * .05,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.orangeAccent),
                            onPressed: () {
                              if (createCustomer() != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Customer creeated successfully!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Customer was not created!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
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
                        const SizedBox(width: 20),
                        SizedBox(
                          width: screenWidth * .08,
                          height: screenHeight * .05,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.orangeAccent),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AllCustomerPage()));
                            },
                            child: const Icon(
                              Icons.read_more,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(width: 20),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          width: screenWidth * .2,
                          height: screenHeight * .1,
                          child: TextField(
                            controller: comName,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
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
                          width: screenWidth * .04,
                          height: screenHeight * .1,
                        ),
                        SizedBox(
                          width: screenWidth * .403,
                          height: screenHeight * .1,
                          child: TextField(
                            controller: repFirstName,
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
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: screenWidth * .641,
                          height: screenHeight * .1,
                          child: TextField(
                            controller: caddressLine,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              labelText: 'Address',
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: screenWidth * .3,
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
                        const SizedBox(width: 25),
                        SizedBox(
                          width: screenWidth * .3,
                          height: screenHeight * .1,
                          child: TextField(
                            controller: cDescription,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              labelText: 'Description',
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          width: screenWidth * .35,
                          height: screenHeight * .1,
                          child: TextField(
                            controller: cBarangay,
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
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
