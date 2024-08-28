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
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.orangeAccent),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Customer creeated successfully!'),
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
                        infoButton(screenWidth * .3, screenHeight * .1,
                            'Company Name', comName),
                        infoButton(screenWidth * .3, screenHeight * .1,
                            'First Name', repFirstName),
                      ],
                    ),
                    Row(
                      children: [
                        infoButton(screenWidth * .641, screenHeight * .1,
                            'Address', caddressLine),
                      ],
                    ),
                    Row(
                      children: [
                        infoButton(screenWidth * .3, screenHeight * .1,
                            'Contact Number', ccontactNum),
                        infoButton(screenWidth * .3, screenHeight * .1,
                            'Description', cDescription),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        infoButton(screenWidth * .35, screenHeight * .1,
                            'Barangay', cBarangay),
                        infoButton(
                            screenWidth * .1, screenHeight * .1, 'City', ccity),
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
