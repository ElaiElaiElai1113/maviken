import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/functions.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController firstName = TextEditingController();
final TextEditingController lastName = TextEditingController();
final TextEditingController eaddressLine = TextEditingController();
final TextEditingController econtactNum = TextEditingController();
final TextEditingController ebarangay = TextEditingController();
final TextEditingController ecity = TextEditingController();
List<Map<String, dynamic>> _position = [];
Map<String, dynamic>? _selectedPosition;

class ProfileEmployee extends StatefulWidget {
  static const routeName = '/ProfileEmployee';

  const ProfileEmployee({super.key});

  @override
  State<ProfileEmployee> createState() => _ProfileEmployeeState();
}

class _ProfileEmployeeState extends State<ProfileEmployee> {
  @override
  Future<void> _fetchTruckData() async {
    final response = await Supabase.instance.client
        .from('Truck')
        .select('truckID, plateNumber');
    setState(() {
      _position = response
          .map<Map<String, dynamic>>((truck) => {
                'truckID': truck['truckID'],
                'plateNumber': truck['plateNumber'],
              })
          .toList();
      if (_position.isNotEmpty) {
        _selectedPosition = _position.first;
      }
    });
  }

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
              title: const Text("Profiling"),
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
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: screenWidth * .08,
                          height: screenHeight * .05,
                        ),
                        SizedBox(
                          width: screenWidth * .05,
                          height: screenHeight * .1,
                        ),
                        SizedBox(
                          width: screenWidth * .08,
                          height: screenHeight * .05,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.orangeAccent),
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
                    Row(
                      mainAxisSize: MainAxisSize.max,
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
                          width: screenWidth * .04,
                          height: screenHeight * .1,
                        ),
                        SizedBox(
                          width: screenWidth * .3,
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
                          width: screenWidth * .641,
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
                      mainAxisSize: MainAxisSize.max,
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
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
