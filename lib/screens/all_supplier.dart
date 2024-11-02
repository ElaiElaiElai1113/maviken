import 'package:flutter/material.dart';
import 'package:maviken/screens/create_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class allSupplierPage extends StatefulWidget {
  static const routeName = '/supplierPage';

  const allSupplierPage({super.key});

  @override
  State<allSupplierPage> createState() => _allSupplierPageState();
}

class _allSupplierPageState extends State<allSupplierPage> {
  List<dynamic> supplierList = [];

  @override
  Future<void> _fetchSupplier() async {
    final response =
        await Supabase.instance.client.from('supplier').select('*');

    setState(() {
      supplierList = response.map((e) {
        return Map<String, dynamic>.from(e);
      }).toList();
    });
  }

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
        final TextEditingController companyController =
            TextEditingController(text: supplier['companyName']);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Supplier Data',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addresLineController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: barangayController,
                  decoration: const InputDecoration(
                    labelText: 'Barangay',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactNoController,
                  decoration: const InputDecoration(
                    labelText: 'Contact #',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save'),
                onPressed: () async {
                  try {
                    final updatedOrder = {
                      'companyName': companyController.text,
                      'lastName': lastNameController.text,
                      'firstName': firstNameController.text,
                      'description': descriptionController.text,
                      'addressLine': addresLineController.text,
                      'barangay': barangayController.text,
                      'city': cityController.text,
                      'contactNo': contactNoController.text,
                    };
                    await supabase
                        .from('supplier')
                        .update(updatedOrder)
                        .eq('supplierID', supplier['supplierID']);
                    setState(() {
                      supplierList[index] = {...supplier, ...updatedOrder};
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
                  }
                }),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchSupplier();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier List'),
        actions: [
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
                        child: Text('Company',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rep First Name',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rep Last Name',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Description',
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Address',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('City',
                              style: TextStyle(color: Colors.white)),
                        )),
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
                ...supplierList.asMap().entries.map((entry) {
                  int index = entry.key;
                  var supplier = entry.value;
                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['companyName']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['lastName']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['firstName']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['description']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['addressLine']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['city']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['barangay']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['contactNo']}'),
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
                                    editSupplier(index);
                                  },
                                  icon: const Icon(Icons.edit)),
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
