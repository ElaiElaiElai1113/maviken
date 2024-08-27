import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/all_employee.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController firstName = TextEditingController();
final TextEditingController lastName = TextEditingController();
final TextEditingController eaddressLine = TextEditingController();
final TextEditingController econtactNum = TextEditingController();
final TextEditingController ebarangay = TextEditingController();
final TextEditingController ecity = TextEditingController();
List<Map<String, dynamic>> _employees = [];
Map<String, dynamic>? _selectedEmployee;

class ProfileEmployee extends StatefulWidget {
  static const routeName = '/ProfileEmployee';

  const ProfileEmployee({super.key});

  @override
  State<ProfileEmployee> createState() => _ProfileEmployeeState();
}

class _ProfileEmployeeState extends State<ProfileEmployee> {
  Future<void> _fetchEmployeeData() async {
    final response = await Supabase.instance.client
        .from('employeePosition')
        .select('positionID, positionName');
    setState(() {
      _employees = response
          .map<Map<String, dynamic>>((position) => {
                'positionID': position['positionID'],
                'positionName': position['positionName'],
              })
          .toList();
      if (_employees.isNotEmpty) {
        _selectedEmployee = _employees.first;
      }
    });
  }

  Future<void> createEmployee() async {
    final response = await supabase.from('employee').insert([
      {
        'lastName': lastName.text,
        'firstName': firstName.text,
        'addressLine': eaddressLine.text,
        'city': ecity.text,
        'barangay': ebarangay.text,
        'contactNo': int.tryParse(econtactNum.text) ?? 0,
        'positionID': _selectedEmployee?['positionID'],
      }
    ]);
  }

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const BarTop(),
      body: SidebarDrawer(
        drawer: const BarTop(),
        body: Expanded(
          child: Container(
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
                                  backgroundColor: Colors.orange),
                              onPressed: () {},
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
                                  backgroundColor: Colors.orangeAccent),
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: screenWidth * .08,
                              height: screenHeight * .05,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    backgroundColor: Colors.orangeAccent),
                                onPressed: () {
                                  if (createEmployee() != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Employee created successfully!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Employee was not created!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                  ;
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
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    backgroundColor: Colors.orangeAccent),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AllEmployeePage.routeName);
                                },
                                child: const Icon(
                                  Icons.read_more,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ]),
                      const SizedBox(width: 20),
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
                              controller: eaddressLine,
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
                              controller: econtactNum,
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
                              controller: ecity,
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
                      dropDown(
                        'Position',
                        _employees,
                        _selectedEmployee,
                        (Map<String, dynamic>? newValue) {
                          setState(() {
                            _selectedEmployee = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

Widget dropDown(
  String labelText,
  List<Map<String, dynamic>> items,
  Map<String, dynamic>? selectedItem,
  ValueChanged<Map<String, dynamic>?> onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        labelText,
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      ),
      const SizedBox(height: 10),
      DropdownButton<Map<String, dynamic>>(
        hint: const Text('Select an item'),
        value: selectedItem,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<Map<String, dynamic>>>(
            (Map<String, dynamic> value) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: value,
            child: Text(
              value['positionName'],
              style: TextStyle(color: Colors.grey[700]),
            ),
          );
        }).toList(),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
        underline: Container(),
        style: TextStyle(color: Colors.grey[700]),
      ),
    ],
  );
}
