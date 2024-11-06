import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/all_load.dart';
import 'package:maviken/screens/all_supplier.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:maviken/components/info_button.dart';
import 'package:maviken/components/choose_profiling_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController sCompanyName = TextEditingController();
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
  final TextEditingController loadController = TextEditingController();

  Future<void> newLoad() async {
    final response = await Supabase.instance.client.from('typeofload').insert([
      {
        'loadtype': loadController.text,
      }
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: buildSupplierForm(screenWidth, screenHeight, context),
        label: "Supplier Profiling");
  }

  SingleChildScrollView buildSupplierForm(
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
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Supplier",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.orangeAccent),
              ),
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
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.orangeAccent),
                          onPressed: () {
                            createSupplier();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Supplier created successfully!'),
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
                                  borderRadius: BorderRadius.circular(10)),
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
                      "Company Name",
                      sCompanyName,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
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
                    child: infoButton(screenWidth * .3, screenHeight * .1,
                        'Last Name', slastName),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: infoButton(screenWidth * .641, screenHeight * .1,
                        'Address', saddressLine),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: infoButton(screenWidth * .641, screenHeight * .1,
                        'Contact Number', scontactNum),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 3,
                    child: infoButton(screenWidth * .35, screenHeight * .1,
                        'Barangay', sbarangay),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: infoButton(
                        screenWidth * .1, screenHeight * .1, 'City', scity),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Load Type",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.orangeAccent),
                  ),
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
                                      borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: Colors.orangeAccent),
                              onPressed: () {
                                try {
                                  newLoad();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Load successfully added!"),
                                    backgroundColor: Colors.green,
                                  ));
                                  loadController.clear();
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text("An error has occured: $e"),
                                    backgroundColor: Colors.red,
                                  ));
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
                                      borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: Colors.orangeAccent),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AllLoadPage()));
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
                  Row(mainAxisSize: MainAxisSize.max, children: [
                    Expanded(
                      flex: 1,
                      child: infoButton(
                        screenWidth * .3,
                        screenHeight * .1,
                        "Load Type",
                        loadController,
                      ),
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
