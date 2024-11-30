import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/info_button.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/fleetManage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';

class AllEmployeePage extends StatefulWidget {
  static const routeName = '/employeePage';
  const AllEmployeePage({super.key});

  @override
  State<AllEmployeePage> createState() => _AllEmployeePageState();
}

class _AllEmployeePageState extends State<AllEmployeePage> {
  List<dynamic> employeeList = [];
  List<Map<String, dynamic>> _trucks = [];
  Map<String, dynamic>? _selectedTruck;

  bool showAllEmployees = false;
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
  Future<void> _fetchTruck() async {
    try {
      final response = await Supabase.instance.client.from('Truck').select('*');

      print(response);

      setState(() {
        trucks = (response as List<dynamic>).map((e) {
          return Map<String, dynamic>.from(e as Map);
        }).toList();
      });
    } catch (e) {
      print('Error fetching trucks: $e');
    }
  }

  Future<void> _fetchEmployee() async {
    try {
      final response = await Supabase.instance.client
          .from('employee')
          .select(
              '*, employeePosition!left(positionName), Truck!employee_truckID_fkey(plateNumber)')
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

  Future<String?> uploadFile(
      Uint8List fileBytes, String employeeID, String folder) async {
    try {
      final filePath =
          '$folder/$employeeID/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await Supabase.instance.client.storage
          .from(folder)
          .uploadBinary(filePath, fileBytes);

      if (response.isEmpty) {
        print('Error uploading file');
        return null;
      }

      final publicUrl =
          Supabase.instance.client.storage.from(folder).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  void editEmployee(int index) {
    final employee = employeeList[index];

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

    // Variables to hold selected files
    PlatformFile? selectedResumeFile;
    PlatformFile? selectedBarangayClearFile;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Employee Data',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Drop-down for Truck (if needed)
                    dropDown('Truck', trucks, _selectedTruck,
                        (Map<String, dynamic>? newValue) {
                      setState(() {
                        _selectedTruck = newValue;
                      });
                    }, 'plateNumber'),
                    const SizedBox(height: 25),
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: addressLineController,
                      decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: barangayController,
                      decoration: const InputDecoration(
                          labelText: 'Barangay',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: contactNoController,
                      decoration: const InputDecoration(
                          labelText: 'Contact #',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Flexible(
                          child: textFieldDate(
                              startDateController, 'Start Date', context),
                        ),
                        const SizedBox(width: 25),
                        Flexible(
                          child: textFieldDate(
                              endDateController, 'Termination Date', context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Resume selection
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'png', 'jpeg', 'jpg'],
                        );

                        if (result != null && result.files.isNotEmpty) {
                          setState(() {
                            selectedResumeFile = result.files.first;
                          });
                        }
                      },
                      child: const Text('Select Resume'),
                    ),
                    const SizedBox(height: 10),
                    // Display selected resume file name
                    if (selectedResumeFile != null)
                      Text('Selected Resume: ${selectedResumeFile!.name}'),
                    const SizedBox(height: 10),
                    // Barangay clearance selection
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [' pdf', 'png', 'jpeg', 'jpg'],
                        );

                        if (result != null && result.files.isNotEmpty) {
                          setState(() {
                            selectedBarangayClearFile = result.files.first;
                          });
                        }
                      },
                      child: const Text('Select Barangay Clearance'),
                    ),
                    const SizedBox(height: 10),
                    // Display selected barangay clearance file name
                    if (selectedBarangayClearFile != null)
                      Text(
                          'Selected Barangay Clearance: ${selectedBarangayClearFile!.name}'),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              child: const Text('Save',
                  style: TextStyle(color: Color(0xFF0a438f))),
              onPressed: () async {
                try {
                  final updatedEmployee = {
                    'lastName': lastNameController.text.isNotEmpty
                        ? lastNameController.text
                        : employee['lastName'],
                    'firstName': firstNameController.text.isNotEmpty
                        ? firstNameController.text
                        : employee['firstName'],
                    'addressLine': addressLineController.text.isNotEmpty
                        ? addressLineController.text
                        : employee['addressLine'],
                    'barangay': barangayController.text.isNotEmpty
                        ? barangayController.text
                        : employee['barangay'],
                    'city': cityController.text.isNotEmpty
                        ? cityController.text
                        : employee['city'],
                    'contactNo': contactNoController.text.isNotEmpty
                        ? int.parse(contactNoController.text)
                        : employee['contactNo'],
                    'startDate': startDateController.text.isNotEmpty
                        ? startDateController.text
                        : employee['startDate'],
                    'endDate': endDateController.text.isNotEmpty
                        ? endDateController.text
                        : employee['endDate'],
                  };

                  // Upload selected resume file if available
                  if (selectedResumeFile != null) {
                    final resumeUrl = await uploadFile(
                        selectedResumeFile!.bytes!,
                        employee['employeeID'],
                        'resumes');
                    updatedEmployee['resumeUrl'] = resumeUrl;
                  }

                  // Upload selected barangay clearance file if available
                  if (selectedBarangayClearFile != null) {
                    final clearanceUrl = await uploadFile(
                        selectedBarangayClearFile!.bytes!,
                        employee['employeeID'],
                        'barangayClearance');
                    updatedEmployee['barangayClearanceUrl'] = clearanceUrl;
                  }

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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error updating employee: $e'),
                    duration: const Duration(seconds: 2),
                  ));
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
    _fetchTruck();
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
        child: Table(
          border: TableBorder.all(color: Colors.black),
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
                    child: Text('ID', style: TextStyle(color: Colors.white)),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('Resume', style: TextStyle(color: Colors.white)),
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
                      child:
                          Text('Status', style: TextStyle(color: Colors.white)),
                    )),
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
                    child:
                        Text('Position', style: TextStyle(color: Colors.white)),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Truck', style: TextStyle(color: Colors.white)),
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
                    child: Text('City', style: TextStyle(color: Colors.white)),
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
                                      content: Text("No resume available")));
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
                      child: Text(
                        employee['Truck'] != null
                            ? employee['Truck']['plateNumber']
                            : "No Truck Assigned",
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
                              showDocumentScreen(context, barangayClearanceUrl);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("No clearance available")));
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
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                editEmployee(index);
                              },
                              icon: const Icon(Icons.edit)),
                          Flexible(
                            child: TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          employee['isActive']
                                              ? 'Active'
                                              : 'Inactive',
                                          style: TextStyle(
                                            color: employee['isActive']
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Switch(
                                          value: employee['isActive'],
                                          onChanged: (value) {
                                            toggleEmployeeStatus(index, value);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
    );
  }
}
