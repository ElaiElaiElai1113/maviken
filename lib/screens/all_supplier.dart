import 'package:flutter/material.dart';
import 'package:maviken/components/employee_card.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/supplier_card.dart';
import 'package:maviken/screens/create_account.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class allSupplierPage extends StatefulWidget {
  static const routeName = '/supplierPage';

  const allSupplierPage({super.key});

  @override
  State<allSupplierPage> createState() => _allSupplierPageState();
}

class _allSupplierPageState extends State<allSupplierPage> {
  List<dynamic> supplierList = [];

  void deleteSupplier(int index) async {
    final supplierID = supplierList[index]['supplierID'];
    try {
      final response =
          await supabase.from('supplier').delete().eq('supplierID', supplierID);

      setState(() {
        supplierID.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supplier deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error deleting Supplier: $error');
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
      _fetchSupplier();
    }
  }

  void editSupplier(int index) {
    final supplier = supplierList[index];
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController lastNameController =
            TextEditingController(text: supplier['lastName']);
        final TextEditingController firstNameController =
            TextEditingController(text: supplier['firstName']);
        final TextEditingController addresLineController =
            TextEditingController(text: supplier['addressLine']);
        final TextEditingController descriptionController =
            TextEditingController(text: supplier['description']);
        final TextEditingController barangayController =
            TextEditingController(text: supplier['barangay']);

        final TextEditingController cityController =
            TextEditingController(text: supplier['city']);

        final TextEditingController contactNoController =
            TextEditingController(text: supplier['contactNo'].toString());

        return AlertDialog(
          title: const Text('Edit Supplier'),
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
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
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
                      'description': descriptionController.text,
                      'addressLine': addresLineController.text,
                      'barangay': barangayController.text,
                      'city': cityController.text,
                      'contactNo': int.parse(contactNoController.text),
                    };
                    await supabase
                        .from('supplier')
                        .update(updatedOrder)
                        .eq('supplierID', supplier['supplierID']);
                    setState(() {
                      supplier[index] = updatedOrder;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Supplier updated successfully!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    print('Error updating Supplier: $e');

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
                    _fetchSupplier();
                  }
                  ;
                }),
          ],
        );
      },
    );
  }

  Future<void> _fetchSupplier() async {
    final response =
        await Supabase.instance.client.from('supplier').select('*');

    if (mounted) {
      setState(() {
        supplierList = response as List<dynamic>;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSupplier();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const BarTop(),
        body: SidebarDrawer(
            body: ListView.builder(
                itemCount: supplierList.length,
                itemBuilder: (context, index) {
                  final supplier = supplierList[index];
                  return SupplierCard(
                    firstName: supplier['firstName'],
                    lastName: supplier['lastName'],
                    addressLine: supplier['addressLine'],
                    city: supplier['city'],
                    barangay: supplier['barangay'],
                    contactNo: supplier['contactNo'].toString(),
                    description: supplier['description'],
                    onDelete: () => deleteSupplier(index),
                    onEdit: () => editSupplier(index),
                  );
                }),
            drawer: const BarTop()));
  }
}
