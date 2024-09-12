// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:maviken/components/customer_card.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/main.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/screens/profile_customer.dart';

class AllCustomerPage extends StatefulWidget {
  static const routeName = '/customerPage';

  const AllCustomerPage({super.key});

  @override
  State<AllCustomerPage> createState() => _AllCustomerPageState();
}

Future<void> createCustomer() async {
  final response = await supabase.from('customer').insert({
    'company': comName.text,
    'repFirstName': repFirstName.text,
    'repLastName': repLastName.text,
    'description': cDescription.text,
    'addressLine': caddressLine.text,
    'city': ccity.text,
    'barangay': cBarangay.text,
    'contactNo': int.tryParse(ccontactNum.text) ?? 0,
  });
}

class _AllCustomerPageState extends State<AllCustomerPage> {
  List<dynamic> customerList = [];

  void deleteCustomer(int index) async {
    final customerID = customerList[index]['customerID'];
    try {
      final response =
          await supabase.from('customer').delete().eq('customerID', customerID);

      setState(() {
        customerList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer deleted successfully!'),
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

  void editCustomer(int index) {
    final customer = customerList[index];
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController companyController =
            TextEditingController(text: customer['company']);
        final TextEditingController firstNameController =
            TextEditingController(text: customer['repFirstName']);
        final TextEditingController lastNameController =
            TextEditingController(text: customer['repLastName']);
        final TextEditingController descriptionController =
            TextEditingController(text: customer['description']);
        final TextEditingController addressLineController =
            TextEditingController(text: customer['addressLine']);
        final TextEditingController cityController =
            TextEditingController(text: customer['city']);
        final TextEditingController barangayController =
            TextEditingController(text: customer['barangay']);
        final TextEditingController contactNoController =
            TextEditingController(text: customer['contactNo'].toString());

        return AlertDialog(
          title: const Text('Edit Order'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: 'Company'),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: addressLineController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
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
                    'company': companyController.text,
                    'repFirstName': firstNameController.text,
                    'repLastName': lastNameController.text,
                    'description': descriptionController.text,
                    'addressLine': addressLineController.text,
                    'barangay': barangayController.text,
                    'city': cityController.text,
                    'contactNo': int.parse(contactNoController.text),
                  };
                  await supabase
                      .from('customer')
                      .update(updatedOrder)
                      .eq('customerID', customer['customerID']);
                  setState(() {
                    customerList[index] = updatedOrder;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customer edited successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error updating Customer: $e');

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

  Future<void> _fetchEmployee() async {
    final response =
        await Supabase.instance.client.from('customer').select('*');

    if (mounted) {
      setState(() {
        customerList = response as List<dynamic>;
      });
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    _fetchEmployee();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const BarTop(),
        body: SidebarDrawer(
            body: ListView.builder(
                itemCount: customerList.length,
                itemBuilder: (content, index) {
                  final customer = customerList[index];
                  return CustomerCard(
                    customerID: customer['customerID'].toString(),
                    company: customer['company'],
                    repFirstName: customer['repFirstName'],
                    repLastName: customer['repLastName'],
                    description: customer['description'],
                    addressLine: customer['addressLine'],
                    city: customer['city'],
                    barangay: customer['barangay'],
                    contactNum: customer['contactNo'].toString(),
                    onDelete: () => deleteCustomer(index),
                    onEdit: () => editCustomer(index),
                  );
                }),
            drawer: const BarTop()));
  }
}
