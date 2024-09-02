import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/screens/all_supplier.dart';
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
            Flexible(
              child: SingleChildScrollView(
                child: Container(
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
                              Flexible(
                                child: SizedBox(
                                  width: screenWidth * .08,
                                  height: screenHeight * .05,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        backgroundColor: Colors.orangeAccent),
                                    onPressed: () {
                                      createSupplier();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Supplier created successfully!'),
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
                              const SizedBox(
                                width: 20,
                              ),
                              Flexible(
                                child: SizedBox(
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
                                                  const allSupplierPage()));
                                    },
                                    child: const Icon(
                                      Icons.read_more,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 1,
                              child: infoButton(
                                screenWidth * .3,
                                screenHeight * .1,
                                "First Name",
                                sfirstName,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 1,
                              child: infoButton(screenWidth * .3,
                                  screenHeight * .1, 'Last Name', slastName),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: infoButton(screenWidth * .641,
                                  screenHeight * .1, 'Address', saddressLine),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: infoButton(
                                  screenWidth * .641,
                                  screenHeight * .1,
                                  'Contact Number',
                                  scontactNum),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 3,
                              child: infoButton(screenWidth * .35,
                                  screenHeight * .1, 'Barangay', sbarangay),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: infoButton(screenWidth * .1,
                                  screenHeight * .1, 'City', scity),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
