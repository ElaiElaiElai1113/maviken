import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/info_button.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/screens/all_truck.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController plateNumber = TextEditingController();
final TextEditingController tbrand = TextEditingController();
final TextEditingController tmodel = TextEditingController();
final TextEditingController tyear = TextEditingController();
final TextEditingController tcolor = TextEditingController();
final TextEditingController tdriverID = TextEditingController();

int helperID = 0;
int driverID = 0;
List<Map<String, dynamic>> drivers = [];
Map<String, dynamic>? selectedDriver;
List<Map<String, dynamic>> helpers = [];

Map<String, dynamic>? selectedHelper;

class ProfileTrucks extends StatefulWidget {
  static const routeName = '/profiletruck';
  const ProfileTrucks({super.key});

  @override
  State<ProfileTrucks> createState() => ProfileTrucksState();
}

class ProfileTrucksState extends State<ProfileTrucks> {
  Future<void> fetchDriverData() async {
    final response = await Supabase.instance.client
        .from('employee')
        .select('employeeID, lastName, firstName')
        .eq('positionID', 3);
    if (mounted) {
      setState(() {
        drivers = response
            .map<Map<String, dynamic>>((employee) => {
                  'employeeID': employee['employeeID'],
                  'fullName':
                      '${employee['lastName']}, ${employee['firstName']}',
                })
            .toList();
        if (drivers.isNotEmpty) {
          selectedDriver = drivers.first;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDriverData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: buildTruckForm(screenWidth, screenHeight, context),
        label: "Truck Profiling");
  }

  SingleChildScrollView buildTruckForm(
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
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: infoButton(
                      screenWidth * .3,
                      screenHeight * .1,
                      "Plate Number",
                      plateNumber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoButton(
                      screenWidth * .3,
                      screenHeight * .1,
                      'Brand',
                      tbrand,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              infoButton(screenWidth, screenHeight * .1, 'Model', tmodel),
              const SizedBox(height: 20),
              infoButton(screenWidth, screenHeight * .1, 'Year', tyear),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 3,
                    child: infoButton(
                      screenWidth * .35,
                      screenHeight * .1,
                      'Color',
                      tcolor,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.orangeAccent,
                        ),
                        onPressed: () {
                          createTruck();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Truck created successfully!'),
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
                              builder: (context) => const AllTruckPage(),
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
            ],
          ),
        ),
      ),
    );
  }
}
