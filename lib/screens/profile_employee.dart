import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/all_employee.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/choose_profiling_button.dart';
import 'package:maviken/components/info_button.dart';

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
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const BarTop(),
      body: SidebarDrawer(
        drawer: const BarTop(),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: screenWidth,
            height: screenHeight,
            child: Column(children: [
              AppBar(
                backgroundColor: Colors.white,
                leading: const DrawerIcon(),
                title: const Text("Employee Profiling"),
              ),
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
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
                      profilingButtons(screenWidth, screenHeight, context),
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
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    backgroundColor: Colors.orangeAccent),
                                onPressed: () {
                                  createEmployee();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Employee created successfully!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
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
                            const SizedBox(
                              width: 20,
                              height: 20,
                            ),
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AllEmployeePage()));
                                },
                                child: const Icon(
                                  Icons.read_more,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ]),
                      const SizedBox(width: 20, height: 10),
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
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          infoButton(
                            screenWidth * .3,
                            screenHeight * .1,
                            "First Name",
                            firstName,
                          ),
                          infoButton(screenWidth * .3, screenHeight * .1,
                              'Last Name', lastName)
                        ],
                      ),
                      Row(
                        children: [
                          infoButton(screenWidth * .641, screenHeight * .1,
                              'Address', eaddressLine),
                        ],
                      ),
                      Row(
                        children: [
                          infoButton(screenWidth * .641, screenHeight * .1,
                              'Contact Number', econtactNum),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          infoButton(screenWidth * .35, screenHeight * .1,
                              'Barangay', ebarangay),
                          infoButton(screenWidth * .1, screenHeight * .1,
                              'City', ecity),
                        ],
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

  Row profilingButtons(
      double screenWidth, double screenHeight, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        chooseProfiling(
          screenWidth,
          screenHeight,
          "Employee",
          Colors.orange,
          () => Navigator.popAndPushNamed(context, ProfileEmployee.routeName),
        ),
        chooseProfiling(
          screenWidth,
          screenHeight,
          "Customer",
          Colors.orangeAccent,
          () => Navigator.popAndPushNamed(context, ProfileCustomer.routeName),
        ),
        chooseProfiling(
          screenWidth,
          screenHeight,
          "Supplier",
          Colors.orangeAccent,
          () => Navigator.popAndPushNamed(context, ProfileSupplier.routeName),
        ),
      ],
    );
  }
}
