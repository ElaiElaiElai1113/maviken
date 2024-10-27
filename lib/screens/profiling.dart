import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/screens/all_customer.dart';
import 'package:maviken/screens/all_employee.dart';
import 'package:maviken/screens/all_load.dart';
import 'package:maviken/screens/all_supplier.dart';
import 'package:maviken/screens/all_truck.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:maviken/screens/profile_trucks.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/info_button.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:html' as html;
import 'package:universal_platform/universal_platform.dart';

final TextEditingController firstName = TextEditingController();
final TextEditingController lastName = TextEditingController();
final TextEditingController eaddressLine = TextEditingController();
final TextEditingController startDateController = TextEditingController();
final TextEditingController econtactNum = TextEditingController();
final TextEditingController ebarangay = TextEditingController();
final TextEditingController ecity = TextEditingController();
final TextEditingController sssID = TextEditingController();
final TextEditingController pagIbigID = TextEditingController();
final TextEditingController driversLicense = TextEditingController();
final TextEditingController loadController = TextEditingController();
PlatformFile? _selectedResumeFile;

PlatformFile? selectedFile;
String? resumeUrl;

List<Map<String, dynamic>> _employees = [];
Map<String, dynamic>? _selectedEmployee;
List<Map<String, dynamic>> loadtypes = [];
Map<String, dynamic>? selectedLoad;
String selectedProfileType = "Employee";
Future<void> newLoad() async {
  final response = await Supabase.instance.client.from('typeofload').insert([
    {
      'loadtype': loadController.text,
    }
  ]);
}

class Profiling extends StatefulWidget {
  static const routeName = '/Profililing';

  const Profiling({super.key});

  @override
  State<Profiling> createState() => _ProfilingState();
}

class _ProfilingState extends State<Profiling> {
  Future<String?> uploadResume(Uint8List fileBytes, String employeeID) async {
    try {
      final filePath =
          'resumes/$employeeID/resume_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await Supabase.instance.client.storage
          .from('resumes')
          .uploadBinary(filePath, fileBytes);

      // Log the response from the upload attempt
      print('Upload Response: $response');

      if (response.isEmpty) {
        print('Error uploading file');
        return null;
      }

      // Get the public URL of the uploaded file
      final publicUrl = Supabase.instance.client.storage
          .from('resumes')
          .getPublicUrl(filePath);

      print('Public URL generated: $publicUrl'); // Debug print
      return publicUrl;
    } catch (e) {
      print('Error uploading resume: $e');
      return null;
    }
  }

  Future<void> pickAndUploadFile(String employeeID) async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf,.png,.jpg,.jpeg';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);

        // Listen for the file read to complete
        reader.onLoadEnd.listen((e) async {
          final fileBytes = reader.result as Uint8List;
          print('File bytes length: ${fileBytes.length}'); // Debug

          // Attempt to upload and get the URL
          final uploadedUrl = await uploadResume(fileBytes, employeeID);
          print("Uploaded URL received: $uploadedUrl"); // Debug

          // Update state with the URL if upload was successful
          if (uploadedUrl != null) {
            setState(() {
              resumeUrl = uploadedUrl;
            });
            print("Resume URL set in state: $resumeUrl"); // Debug
          } else {
            print("Failed to upload resume");
          }
        });
      }
    });
  }

  Future<void> createEmployee() async {
    if (_selectedResumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a resume file before saving.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_selectedResumeFile!.name}';
      String? resumeUrl;

      if (kIsWeb) {
        // Web upload logic...
        print("Attempting web upload...");
        if (_selectedResumeFile!.bytes == null) {
          throw Exception('No file bytes available for web upload');
        }
        final uploadResponse = await Supabase.instance.client.storage
            .from('resumes')
            .uploadBinary(fileName, _selectedResumeFile!.bytes!);

        print("Upload response (web): $uploadResponse");

        // Check if upload is successful
        if (uploadResponse.isEmpty) {
          throw Exception('Error uploading file');
        }

        resumeUrl = Supabase.instance.client.storage
            .from('resumes')
            .getPublicUrl(fileName);
      } else {
        // Mobile/desktop upload logic...
        print("Attempting mobile/desktop upload...");
        final uploadResponse = await Supabase.instance.client.storage
            .from('resumes')
            .uploadBinary(fileName,
                await io.File(_selectedResumeFile!.path!).readAsBytes());

        print("Upload response (mobile/desktop): $uploadResponse");

        // Check if upload is successful
        if (uploadResponse.isEmpty) {
          throw Exception('Error uploading file');
        }

        resumeUrl = Supabase.instance.client.storage
            .from('resumes')
            .getPublicUrl(fileName);
      }

      print("Resume URL: $resumeUrl");

      final employeeData = {
        'firstName': firstName.text,
        'lastName': lastName.text,
        'sssID': sssID.text,
        'pagIbigID': pagIbigID.text,
        'driversLicense': driversLicense.text,
        'addressLine': eaddressLine.text,
        'contactNo': econtactNum.text,
        'barangay': ebarangay.text,
        'city': ecity.text,
        'startDate': startDateController.text,
        'positionID': _selectedEmployee?['positionID'],
        'resumeUrl': resumeUrl,
      };

      print("Employee data to insert: $employeeData");

      // Insert into the database
      final insertResponse = await Supabase.instance.client
          .from('employee')
          .insert([employeeData]);

      if (insertResponse.error != null) {
        throw Exception('Insert failed: ${insertResponse.error!.message}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee created successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating employee: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> fetchLoadTypes() async {
    final response =
        await Supabase.instance.client.from('typeofload').select('*');

    if (!mounted) return;
    setState(() {
      loadtypes = response
          .map<Map<String, dynamic>>((load) => {
                'loadID': load['loadID'],
                'loadtype': load['loadtype'],
              })
          .toList();
      if (loadtypes.isNotEmpty) {
        selectedLoad = loadtypes.first;
      }
    });
  }

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
        body: Container(
          color: Colors.white,
          width: screenWidth,
          height: screenHeight,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                leading: const DrawerIcon(),
                title: const Text("Profiling"),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          dropdownColor: Colors.orangeAccent,
                          elevation: 16,
                          value: selectedProfileType,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedProfileType = newValue!;
                            });
                          },
                          items: <String>[
                            'Customer',
                            'Employee',
                            'Supplier/Load',
                            'Truck'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        buildProfileForm(screenWidth, screenHeight, context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileForm(
      double screenWidth, double screenHeight, BuildContext context) {
    switch (selectedProfileType) {
      case 'Customer':
        return buildCustomerForm(screenWidth, screenHeight, context);
      case 'Employee':
        return buildEmployeeForm(screenWidth, screenHeight, context);
      case 'Supplier/Load':
        return buildSupplierForm(screenWidth, screenHeight, context);
      case 'Truck':
        return buildTruckForm(screenWidth, screenHeight, context);
      default:
        return buildEmployeeForm(screenWidth, screenHeight, context);
    }
  }

  SingleChildScrollView buildEmployeeForm(
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
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SizedBox(
                      width: screenWidth * 0.08,
                      height: screenHeight * 0.05,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.orangeAccent,
                        ),
                        onPressed: () {
                          createEmployee();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Employee created successfully!'),
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
                      width: screenWidth * 0.08,
                      height: screenHeight * 0.05,
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
                              builder: (context) => const AllEmployeePage(),
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
              dropDown(
                'Position',
                _employees,
                _selectedEmployee,
                (Map<String, dynamic>? newValue) {
                  setState(() {
                    _selectedEmployee = newValue;
                  });
                },
                'positionName',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: infoButton(
                      screenWidth * 0.3,
                      screenHeight * 0.1,
                      'First Name',
                      firstName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoButton(
                      screenWidth * 0.3,
                      screenHeight * 0.1,
                      'Last Name',
                      lastName,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: infoButton(
                      screenWidth * 0.3,
                      screenHeight * 0.1,
                      'SSS ID',
                      sssID,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoButton(
                      screenWidth * 0.3,
                      screenHeight * 0.1,
                      'Pag-ibig ID',
                      pagIbigID,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoButton(
                      screenWidth * 0.3,
                      screenHeight * 0.1,
                      'Drivers License ID',
                      driversLicense,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              infoButton(
                  screenWidth, screenHeight * 0.1, 'Address', eaddressLine),
              const SizedBox(height: 20),
              infoButton(screenWidth, screenHeight * 0.1, 'Contact Number',
                  econtactNum),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: infoButton(
                      screenWidth * 0.35,
                      screenHeight * 0.1,
                      'Barangay',
                      ebarangay,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoButton(
                      screenWidth * 0.3,
                      screenHeight * 0.1,
                      'Barangay Clearance',
                      lastName, // Assuming this stores barangay clearance status
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: infoButton(
                      screenWidth * 0.1,
                      screenHeight * 0.1,
                      'City',
                      ecity,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: textFieldDate(
                      startDateController,
                      'Start Date',
                      context,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'png', 'jpeg', 'jpg'],
                      );

                      if (result != null && result.files.isNotEmpty) {
                        setState(() {
                          _selectedResumeFile = result.files.single;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Image successfully added!"),
                          backgroundColor: Colors.green,
                        ));
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Image was not added!"),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
                    child: const Text(
                      'Select Resume (PDF, PNG, JPEG)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
              const SizedBox(height: 20),
              const SizedBox(height: 20),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoButton(
                      screenWidth * .3,
                      screenHeight * .1,
                      'Owner',
                      //null no owner table
                      repFirstName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoButton(
                      screenWidth * .3,
                      screenHeight * .1,
                      'Representative Name',
                      //change to repname no more first and last name
                      repFirstName,
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
