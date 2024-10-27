import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/screens/all_customer.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:maviken/components/choose_profiling_button.dart';
import 'package:maviken/components/info_button.dart';

final TextEditingController comName = TextEditingController();
final TextEditingController repLastName = TextEditingController();
final TextEditingController repFirstName = TextEditingController();
final TextEditingController ccontactNum = TextEditingController();
final TextEditingController cDescription = TextEditingController();
final TextEditingController cBarangay = TextEditingController();
final TextEditingController caddressLine = TextEditingController();
final TextEditingController ccity = TextEditingController();
final TextEditingController startDate = TextEditingController();
List<Map<String, dynamic>> _customers = [];
Map<String, dynamic>? _selectedCustomer;

class ProfileCustomer extends StatefulWidget {
  static const routeName = '/ProfileCustomer';

  const ProfileCustomer({super.key});

  @override
  State<ProfileCustomer> createState() => _ProfileCustomerState();
}

class _ProfileCustomerState extends State<ProfileCustomer> {
  @override
  void initState() {
    super.initState();
  }

  @override
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
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                leading: const DrawerIcon(),
                title: const Text("Customer Profiling"),
              ),
              Flexible(
                child: buildCustomerForm(screenWidth, screenHeight, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SingleChildScrollView buildCustomerForm(
      double screenWidth, double screenHeight, BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(25),
        child: Container(
          padding: const EdgeInsets.all(25),
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
            children: [
              ProfilingDropdown(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                initialProfiling: 'Customer',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SizedBox(
                      width: screenWidth * .08,
                      height: screenHeight * .05,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.orangeAccent,
                        ),
                        onPressed: () {
                          createCustomer();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Customer created successfully!'),
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
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    child: SizedBox(
                      width: screenWidth * .08,
                      height: screenHeight * .05,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.orangeAccent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllCustomerPage(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.read_more,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: infoButton(
                      screenWidth * .3,
                      screenHeight * .1,
                      'Company Name',
                      comName,
                    ),
                  ),
                  Expanded(
                    child: infoButton(
                      screenWidth * .3,
                      screenHeight * .1,
                      'Owner',
                      comName,
                    ),
                  ),
                  Expanded(
                    child: infoButton(
                      screenWidth * .3,
                      screenHeight * .1,
                      'First Names',
                      repFirstName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoButton(
                      screenWidth * .3,
                      screenHeight * .1,
                      'Last Name',
                      repLastName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              infoButton(
                  screenWidth, screenHeight * .1, 'Address', caddressLine),
              const SizedBox(height: 20),
              infoButton(screenWidth, screenHeight * .1, 'Contact Number',
                  ccontactNum),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 3,
                    child: infoButton(
                      screenWidth * .35,
                      screenHeight * .1,
                      'Barangay',
                      cBarangay,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: infoButton(
                      screenWidth * .1,
                      screenHeight * .1,
                      'City',
                      ccity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              infoButton(
                  screenWidth, screenHeight * .1, 'Description', cDescription),
            ],
          ),
        ),
      ),
    );
  }
}
