import 'package:flutter/material.dart';
import 'package:maviken/components/employee_card.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/main.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllEmployeePage extends StatefulWidget {
  static const routeName = '/employeePage';
  const AllEmployeePage({super.key});

  @override
  State<AllEmployeePage> createState() => _AllEmployeePageState();
}

class _AllEmployeePageState extends State<AllEmployeePage> {
  List<dynamic> employeeList = [];

  @override
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
    final Employee = employeeList[index];
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController lastNameController =
            TextEditingController(text: Employee['lastName']);
        final TextEditingController firstNameController =
            TextEditingController(text: Employee['firstName']);
        final TextEditingController addresLineController =
            TextEditingController(text: Employee['addressLine']);
        final TextEditingController barangayController =
            TextEditingController(text: Employee['barangay']);

        final TextEditingController cityController =
            TextEditingController(text: Employee['city']);

        final TextEditingController contactNoController =
            TextEditingController(text: Employee['contactNo'].toString());

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
                  controller: addresLineController,
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
                  final updatedOrder = {
                    'lastName': lastNameController.text,
                    'firstName': firstNameController.text,
                    'addressLine': addresLineController.text,
                    'barangay': barangayController.text,
                    'city': cityController.text,
                    'contactNo': int.parse(contactNoController.text),
                  };
                  await supabase
                      .from('employee')
                      .update(updatedOrder)
                      .eq('employeeID', Employee['employeeID']);
                  setState(() {
                    employeeList[index] = updatedOrder;
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
                _fetchEmployee();
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

  Future<void> _fetchEmployee() async {
    final response = await Supabase.instance.client.from('employee').select(
        '*, employeePosition!inner(positionName), Truck!left(plateNumber)');

    if (mounted) {
      setState(() {
        employeeList = response as List<dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        drawer: const BarTop(),
        body: SidebarDrawer(
            drawer: const BarTop(),
            body: ListView.builder(
              itemCount: employeeList.length,
              itemBuilder: (context, index) {
                final employee = employeeList[index];
                return EmployeeCard(
                  employeeID: employee['employeeID'].toString(),
                  lastName: employee['lastName'] ?? '',
                  firstName: employee['firstName'] ?? '',
                  position: employee['employeePosition']['positionName'] ?? '',
                  address: employee['addressLine'] ?? '',
                  city: employee['city'] ?? '',
                  barangay: employee['barangay'] ?? '',
                  contact: employee['contactNo'].toString(),
                  truck: employee['truckID'] != null
                      ? employee['Truck']['plateNumber'] ?? ''
                      : 'No Truck Assigned',
                  screenWidth: screenWidth * .25,
                  initialHeight: screenHeight * .30,
                  initialWidth: screenWidth * .25,
                  onDelete: () => deleteEmployee(index),
                  onEdit: () => editEmployee(index),
                  showLabels: index == 0,
                );
              },
            )));
  }
}
