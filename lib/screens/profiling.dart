import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/components/textfield.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/screens/all_customer.dart';
import 'package:maviken/screens/all_employee.dart';
import 'package:maviken/screens/all_load.dart';
import 'package:maviken/screens/all_supplier.dart';
import 'package:maviken/screens/all_truck.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:maviken/screens/profile_trucks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/info_button.dart';
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html;

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
PlatformFile? _selectedBarangayClearFile;

PlatformFile? selectedFile;
String? resumeUrl;
String? barangayClearanceUrl;

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
  Future<String?> uploadFile(
      Uint8List fileBytes, String employeeID, String folder) async {
    try {
      final filePath =
          '$folder/$employeeID/resume_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await Supabase.instance.client.storage
          .from(folder)
          .uploadBinary(filePath, fileBytes);

      // Log the response from the upload attempt
      print('Upload Response: $response');

      if (response.isEmpty) {
        print('Error uploading file');
        return null;
      }

      // Get the public URL of the uploaded file
      final publicUrl =
          Supabase.instance.client.storage.from(folder).getPublicUrl(filePath);

      print('Public URL generated: $publicUrl'); // Debug print
      return publicUrl;
    } catch (e) {
      print('Error uploading resume: $e');
      return null;
    }
  }

  Future<void> pickAndUploadFile(String employeeID, String folder) async {
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

          // Attempt to upload and get the URL
          final uploadedUrl = await uploadFile(fileBytes, employeeID, folder);

          // Update state with the URL if upload was successful
          if (uploadedUrl != null) {
            if (folder == 'resumes') {
              resumeUrl = uploadedUrl;
            } else if (folder == 'barangayClearance') {
              barangayClearanceUrl = uploadedUrl;
            }
            print("Resume URL set in state: $resumeUrl"); // Debug
          } else {
            print("Failed to upload resume");
          }
        });
      }
    });
  }

  Future<void> createEmployee() async {
    try {
      final resumeFileName =
          'resumes/${DateTime.now().millisecondsSinceEpoch}_${_selectedResumeFile!.name}';
      final barangayClearFileName =
          'barangayClearance/${DateTime.now().millisecondsSinceEpoch}_${_selectedBarangayClearFile!.name}';
      String? resumeUrl;
      String? barangayClearanceUrl;

      if (kIsWeb) {
        // Web upload logic...
        print("Attempting web upload...");
        if (_selectedResumeFile!.bytes == null) {
          throw Exception('No file bytes available for web upload');
        }
        final uploadResponse = await Supabase.instance.client.storage
            .from('resumes')
            .uploadBinary(resumeFileName, _selectedResumeFile!.bytes!);

        print("Upload response (web): $uploadResponse");

        // Check if upload is successful
        if (uploadResponse.isEmpty) {
          throw Exception('Error uploading file');
        }

        resumeUrl = Supabase.instance.client.storage
            .from('resumes')
            .getPublicUrl(resumeFileName);
      } else {
        // Mobile/desktop upload logic...
        print("Attempting mobile/desktop upload...");
        final uploadResponse = await Supabase.instance.client.storage
            .from('resumes')
            .uploadBinary(resumeFileName,
                await io.File(_selectedResumeFile!.path!).readAsBytes());

        print("Upload response (mobile/desktop): $uploadResponse");

        // Check if upload is successful
        if (uploadResponse.isEmpty) {
          throw Exception('Error uploading file');
        }

        resumeUrl = Supabase.instance.client.storage
            .from('resumes')
            .getPublicUrl(resumeFileName);
      }

      if (kIsWeb) {
        if (_selectedBarangayClearFile!.bytes == null) {
          throw Exception('No file bytes available for web upload');
        }
        final clearanceUploadResponse = await Supabase.instance.client.storage
            .from('resumes')
            .uploadBinary(
                barangayClearFileName, _selectedBarangayClearFile!.bytes!);

        if (clearanceUploadResponse.isEmpty) {
          throw Exception('Error uploading barangay clearance file');
        }

        barangayClearanceUrl = Supabase.instance.client.storage
            .from('resumes')
            .getPublicUrl(barangayClearFileName);
      }

      final employeeData = {
        'firstName': firstName.text.isEmpty ? null : firstName.text,
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
        'barangayClearanceUrl': barangayClearanceUrl,
      };

      print("Employee data to insert: $employeeData");

      // Insert into the database
      final insertResponse = await Supabase.instance.client
          .from('employee')
          .insert([employeeData]);

      if (!mounted) {
        if (insertResponse.error != null) {
          throw Exception('Insert failed: ${insertResponse.error!.message}');
        }
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

    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: buildEmployeeForm(screenWidth, screenHeight, context),
        label: "Profiling");
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: textField(ebarangay, 'Barangay', context,
                        enabled: true),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 3,
                      child: textFieldDate(
                        startDateController,
                        'Start Date',
                        context,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: textField(ecity, 'City', context, enabled: true),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                          _selectedBarangayClearFile = result.files.single;
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
                      'Select Barangay Clearance (PDF, PNG, JPEG)',
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
                      ownerName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoButton(
                      screenWidth * .3,
                      screenHeight * .1,
                      'Representative Name',
                      //change to repname no more first and last name
                      repFullName,
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
