import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maviken/components/info_button.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/profiling.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html;
import 'dart:io' as io;

class AllEmployeePage extends StatefulWidget {
  static const routeName = '/employeePage';
  const AllEmployeePage({super.key});

  @override
  State<AllEmployeePage> createState() => _AllEmployeePageState();
}

class _AllEmployeePageState extends State<AllEmployeePage> {
  List<dynamic> employeeList = [];
  bool showAllEmployees = false;
  PlatformFile? _selectedResumeFile;
  PlatformFile? _selectedBarangayClearFile;

  PlatformFile? selectedFile;
  String? resumeUrl;
  String? barangayClearanceUrl;
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

  void showDocumentScreen(BuildContext context, String documents) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: documents.endsWith('.pdf')
              ? SfPdfViewer.network(documents)
              : CachedNetworkImage(imageUrl: documents, fit: BoxFit.contain),
        );
      },
    );
  }

  @override
  @override
  Future<void> _fetchEmployee() async {
    try {
      final response = await Supabase.instance.client
          .from('employee')
          .select(
              '*, employeePosition!left(positionName), Truck!left(plateNumber)')
          .eq('isActive', showAllEmployees ? false : true);

      print(response);

      setState(() {
        employeeList = (response as List<dynamic>).map((e) {
          return Map<String, dynamic>.from(e as Map);
        }).toList();
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  void toggleEmployeeStatus(int index, bool isActive) async {
    final employeeID = employeeList[index]['employeeID'];
    try {
      // Update the employee's active status in Supabase
      await Supabase.instance.client
          .from('employee')
          .update({'isActive': isActive}).eq('employeeID', employeeID);

      // Refresh the employee list
      _fetchEmployee();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Employee marked as ${isActive ? 'active' : 'inactive'}!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error updating employee status: $error');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to update employee status: $error'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  void deleteEmployee(int index) async {
    final employeeID = employeeList[index]['employeeID'];
    try {
      final response =
          await supabase.from('employee').delete().eq('employeeID', employeeID);

      setState(() {
        employeeList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error deleting Employee: $error');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete order: $error'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  void editEmployee(int index) {
    final employee = employeeList[index];

    showDialog(
      context: context,
      builder: (context) {
        // Controllers for each text field
        final TextEditingController lastNameController =
            TextEditingController(text: employee['lastName']);
        final TextEditingController firstNameController =
            TextEditingController(text: employee['firstName']);
        final TextEditingController addressLineController =
            TextEditingController(text: employee['addressLine']);
        final TextEditingController barangayController =
            TextEditingController(text: employee['barangay']);
        final TextEditingController cityController =
            TextEditingController(text: employee['city']);
        final TextEditingController contactNoController =
            TextEditingController(text: employee['contactNo'].toString());
        final TextEditingController startDateController =
            TextEditingController(text: employee['startDate']);
        final TextEditingController endDateController =
            TextEditingController(text: employee['endDate']);

        return AlertDialog(
          title: const Text('Edit Employee Data'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: addressLineController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: barangayController,
                  decoration: const InputDecoration(labelText: 'Barangay'),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: contactNoController,
                  decoration: const InputDecoration(labelText: 'Contact #'),
                ),
                textFieldDate(startDateController, 'Start Date', context),
                textFieldDate(endDateController, 'Termination Date', context),
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Image successfully added!"),
                        backgroundColor: Colors.green,
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Image successfully added!"),
                        backgroundColor: Colors.green,
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  final resumeFileName =
                      'resumes/${DateTime.now().millisecondsSinceEpoch}_${_selectedResumeFile!.name}';
                  final barangayClearFileName =
                      'barangayClearance/${DateTime.now().millisecondsSinceEpoch}_${_selectedBarangayClearFile!.name}';

                  if (kIsWeb) {
                    // Web upload logic...
                    print("Attempting web upload...");
                    if (_selectedResumeFile!.bytes == null) {
                      throw Exception('No file bytes available for web upload');
                    }
                    final uploadResponse = await Supabase
                        .instance.client.storage
                        .from('resumes')
                        .uploadBinary(
                            resumeFileName, _selectedResumeFile!.bytes!);

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
                    final uploadResponse = await Supabase
                        .instance.client.storage
                        .from('resumes')
                        .uploadBinary(
                            resumeFileName,
                            await io.File(_selectedResumeFile!.path!)
                                .readAsBytes());

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
                    final clearanceUploadResponse = await Supabase
                        .instance.client.storage
                        .from('resumes')
                        .uploadBinary(barangayClearFileName,
                            _selectedBarangayClearFile!.bytes!);

                    if (clearanceUploadResponse.isEmpty) {
                      throw Exception(
                          'Error uploading barangay clearance file');
                    }

                    barangayClearanceUrl = Supabase.instance.client.storage
                        .from('resumes')
                        .getPublicUrl(barangayClearFileName);
                  }

                  final updatedEmployee = Map<String, dynamic>.from({
                    'lastName': lastNameController.text,
                    'firstName': firstNameController.text,
                    'addressLine': addressLineController.text,
                    'barangay': barangayController.text,
                    'city': cityController.text,
                    'contactNo': int.parse(contactNoController.text),
                    'startDate': startDateController.text,
                  });

                  // Check if endDate is not empty before adding it to the map
                  if (endDateController.text.isNotEmpty) {
                    updatedEmployee['endDate'] =
                        endDateController.text; // Add endDate if provided
                  }

// Add resumeUrl and barangayClearanceUrl
                  updatedEmployee['resumeUrl'] = resumeUrl;
                  updatedEmployee['barangayClearanceUrl'] =
                      barangayClearanceUrl;

// Now you can proceed to update the employee in the database

                  // Update employee in Supabase
                  await Supabase.instance.client
                      .from('employee')
                      .update(updatedEmployee)
                      .eq('employeeID', employee['employeeID']);

                  setState(() {
                    employeeList[index] = {...employee, ...updatedEmployee};
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employee updated successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error updating Employee: $e');
                  print(resumeUrl);
                  print(barangayClearanceUrl);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'Please ensure all fields are filled correctly.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchEmployee();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee List'),
        actions: [
          Switch(
            value: showAllEmployees,
            onChanged: (value) {
              setState(() {
                showAllEmployees = value;
                _fetchEmployee();
              });
            },
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: SingleChildScrollView(
        child: Expanded(
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(color: Colors.white30),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header
                const TableRow(
                  decoration: BoxDecoration(color: Colors.redAccent),
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child:
                            Text('ID', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Resume',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Start Date',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Termination Date',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('First Name',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Last Name',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Position',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Address',
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child:
                            Text('City', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Barangay',
                              style: TextStyle(color: Colors.white)),
                        )),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Barangay Clearance',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Contact Number',
                              style: TextStyle(color: Colors.white)),
                        )),
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Truck',
                              style: TextStyle(color: Colors.white)),
                        )),
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Actions',
                              style: TextStyle(color: Colors.white)),
                        )),
                  ],
                ),
                // Generate rows dynamically based on filtered data
                ...employeeList.asMap().entries.map((entry) {
                  int index = entry.key; // Get the index from the map
                  var employee = entry.value; // Get the employee data
                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${employee['employeeID']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                String? resumeUrl = employee['resumeUrl'];
                                if (resumeUrl != null) {
                                  showDocumentScreen(context, resumeUrl);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("No resume available")));
                                }
                                print(resumeUrl);
                              },
                              child: const Text(
                                "View Resume",
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                              ),
                            )),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${employee['startDate']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${employee['endDate'] ?? "ACTIVE"}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${employee['firstName']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${employee['lastName']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            employee['employeePosition'] != null
                                ? '${employee['employeePosition']['positionName']}'
                                : 'Position Not Assigned',
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${employee['addressLine']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${employee['city']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${employee['barangay']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                String? barangayClearanceUrl =
                                    employee['barangayClearanceUrl'];
                                if (barangayClearanceUrl != null) {
                                  showDocumentScreen(
                                      context, barangayClearanceUrl);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("No clearance available")));
                                }
                                print(barangayClearanceUrl);
                              },
                              child: const Text(
                                "View Clearance",
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                              ),
                            )),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${employee['contactNo']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            employee['Truck'] != null
                                ? '${employee['Truck']['plateNumber']}'
                                : 'No Truck Assigned',
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    editEmployee(index);
                                  },
                                  icon: const Icon(Icons.edit)),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Switch(
                                    value: employee['isActive'],
                                    onChanged: (value) {
                                      toggleEmployeeStatus(index, value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
