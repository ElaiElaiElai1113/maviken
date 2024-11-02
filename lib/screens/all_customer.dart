import 'package:flutter/material.dart';
import 'package:maviken/main.dart';
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
    'company': comName.text.isEmpty ? "No Company Specified" : comName.text,
    'owner': ownerName.text.isEmpty ? "No Owner Specified" : ownerName.text,
    'repFullName':
        repFullName.text.isEmpty ? "No Name Specified" : repFullName.text,
    'description': cDescription.text.isEmpty
        ? "No Description Specified"
        : cDescription.text,
    'addressLine': caddressLine.text.isEmpty
        ? "No Address Line Specified"
        : caddressLine.text,
    'city': ccity.text.isEmpty ? "No City Specified" : ccity.text,
    'barangay':
        cBarangay.text.isEmpty ? "No Barangay Specified" : cBarangay.text,
    'contactNo': int.tryParse(ccontactNum.text) ?? 0,
  });
}

class _AllCustomerPageState extends State<AllCustomerPage> {
  List<dynamic> customerList = [];
  @override
  Future<void> fetchCustomer() async {
    final response =
        await Supabase.instance.client.from('customer').select('*');

    setState(() {
      customerList = response.map((e) {
        return Map<String, dynamic>.from(e);
      }).toList();
    });
  }

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
        final TextEditingController ownerController =
            TextEditingController(text: customer['owner']);
        final TextEditingController repFullNameController =
            TextEditingController(text: customer['repFullName']);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Customer Data',
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ownerController,
                      decoration: const InputDecoration(
                        labelText: 'Owner',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: repFullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Representative Full Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressLineController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
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
                ),
              ),
              child: const Text('Save'),
              onPressed: () async {
                try {
                  final updatedOrder = {
                    'company': companyController.text,
                    'owner': ownerController.text,
                    'repFullName': repFullNameController.text,
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
                fetchCustomer();
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
    fetchCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List'),
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
                        child: Text('Owner',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Representative Name',
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
                ...customerList.asMap().entries.map((entry) {
                  int index = entry.key;
                  var customer = entry.value;
                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              '${customer['company'] ?? "No Company Specified"}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              '${customer['owner'] ?? "No Owner Specified"}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              '${customer['repFullName'] ?? "No  Name Specified"}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${customer['description']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${customer['addressLine']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${customer['city']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${customer['barangay']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${customer['contactNo']}'),
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
                                  editCustomer(index);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  deleteCustomer(index);
                                },
                                icon: const Icon(Icons.delete),
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
