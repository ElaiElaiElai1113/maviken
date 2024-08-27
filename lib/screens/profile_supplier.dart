import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/screens/all_employee.dart';
import 'package:maviken/screens/all_supplier.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profile_employee.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:maviken/components/info_button.dart';
import 'package:maviken/components/choose_profiling_button.dart';

final TextEditingController sfirstName = TextEditingController();
final TextEditingController slastName = TextEditingController();
final TextEditingController scontactNum = TextEditingController();
final TextEditingController sdescription = TextEditingController();
final TextEditingController saddressLine = TextEditingController();
final TextEditingController sbarangay = TextEditingController();
final TextEditingController scity = TextEditingController();

class ProfileSupplier extends StatefulWidget {
  static const routeName = '/ProfileSupplier';

  const ProfileSupplier({super.key});

  @override
  State<ProfileSupplier> createState() => _ProfileSupplierState();
}

class _ProfileSupplierState extends State<ProfileSupplier> {
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
              title: const Text("Supplier Profiling"),
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
                                createSupplier();
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
                                Navigator.pushNamed(
                                    context, allSupplierPage.routeName);
                              },
                              child: const Icon(
                                Icons.read_more,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ]),
                    const SizedBox(width: 20),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        infoButton(
                          screenWidth * .3,
                          screenHeight * .1,
                          "First Name",
                          sfirstName,
                        ),
                        infoButton(screenWidth * .3, screenHeight * .1,
                            'Last Name', slastName),
                      ],
                    ),
                    Row(
                      children: [
                        infoButton(screenWidth * .641, screenHeight * .1,
                            'Address', saddressLine),
                      ],
                    ),
                    Row(
                      children: [
                        infoButton(screenWidth * .641, screenHeight * .1,
                            'Contact Number', scontactNum),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        infoButton(screenWidth * .35, screenHeight * .1,
                            'Barangay', sbarangay),
                        infoButton(
                            screenWidth * .1, screenHeight * .1, 'City', scity),
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
