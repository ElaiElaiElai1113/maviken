import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/components/textfield.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/all_load.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PriceManagement extends StatefulWidget {
  static const routeName = '/PriceManagement';
  const PriceManagement({super.key});

  @override
  State<PriceManagement> createState() => PriceManagementState();
}

class PriceManagementState extends State<PriceManagement> {
  final TextEditingController employeeRoleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController loadController = TextEditingController();
  List<Map<String, dynamic>> supplierLoadPrice = [];
  List<Map<String, dynamic>> employeeRoles = [];
  List<Map<String, dynamic>> pricingList = [];

  List<Map<String, dynamic>> supplier = [];
  Map<String, dynamic>? selectedSupplier;
  List<Map<String, dynamic>> loadtypes = [];
  Map<String, dynamic>? selectedLoad;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredSupplierLoadPrice = [];
  List<Map<String, dynamic>> filteredEmployeePos = [];
  String selectedManagementPage = "Price";

  // Searchbar
  void filterSearchResults(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSupplierLoadPrice = supplierLoadPrice;
      } else {
        filteredSupplierLoadPrice = supplierLoadPrice.where((supplierPrice) {
          final companyName =
              supplierPrice['supplier']['companyName'].toString().toLowerCase();
          final loadtype =
              supplierPrice['typeofload']['loadtype'].toString().toLowerCase();
          final price = supplierPrice['price'].toString().toLowerCase();

          return companyName.contains(query.toLowerCase()) ||
              loadtype.contains(query.toLowerCase()) ||
              price.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void filterEmployeeResults(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredEmployeePos = employeeRoles;
      } else {
        filteredEmployeePos = employeeRoles.where((employeeRole) {
          final positionName =
              employeeRole['positionName'].toString().toLowerCase();

          return positionName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> updatePricing(int pricingId, String tollFee, String driverFee,
      String helperFee, String miscFee, String gasPrice) async {
    try {
      await supabase.from('pricing').update({
        'tollFee': double.tryParse(tollFee),
        'driver': double.tryParse(driverFee),
        'helper': double.tryParse(helperFee),
        'misc': double.tryParse(miscFee),
        'gasPrice': double.tryParse(gasPrice),
      }).eq('id', pricingId);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully updated!'),
        backgroundColor: Colors.green,
      ));

      // Refresh the pricing list
      fetchPricing();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void editPricing(int pricingId) {
    // Find the pricing entry to edit
    final pricingEntry =
        pricingList.firstWhere((pricing) => pricing['id'] == pricingId);

    // Create controllers for each field
    final TextEditingController tollFeeController =
        TextEditingController(text: pricingEntry['tollFee'].toString());
    final TextEditingController driverFeeController =
        TextEditingController(text: pricingEntry['driverFee'].toString());
    final TextEditingController helperFeeController =
        TextEditingController(text: pricingEntry['helperFee'].toString());
    final TextEditingController miscFeeController =
        TextEditingController(text: pricingEntry['miscFee'].toString());
    final TextEditingController gasPriceController =
        TextEditingController(text: pricingEntry['gasPrice'].toString());
    final TextEditingController markUpPriceController =
        TextEditingController(text: pricingEntry['markUpPrice'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Pricing"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tollFeeController,
                  decoration: const InputDecoration(labelText: 'Toll Fee'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: driverFeeController,
                  decoration: const InputDecoration(labelText: 'Driver Fee'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: helperFeeController,
                  decoration: const InputDecoration(labelText: 'Helper Fee'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: miscFeeController,
                  decoration:
                      const InputDecoration(labelText: 'Miscellaneous Fee'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: gasPriceController,
                  decoration: const InputDecoration(labelText: 'Gas Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: markUpPriceController,
                  decoration: const InputDecoration(labelText: 'Mark-up Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updatePricing(
                    pricingId,
                    tollFeeController.text,
                    driverFeeController.text,
                    helperFeeController.text,
                    miscFeeController.text,
                    gasPriceController.text);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
  // Fetch Data

  Future<void> getSupplierLoadPrice() async {
    final response = await supabase
        .from('supplierLoadPrice')
        .select('*, typeofload!inner(loadtype), supplier!inner(companyName)');

    setState(() {
      supplierLoadPrice = List<Map<String, dynamic>>.from(response);
      filteredSupplierLoadPrice = supplierLoadPrice;
    });
  }

  Future<void> fetchPricing() async {
    try {
      final response = await supabase.from('pricing').select('*');

      setState(() {
        pricingList = response
            .map<Map<String, dynamic>>((price) => {
                  'id': price['id'],
                  'tollFee': price['tollFee'],
                  'driverFee': price['driver'],
                  'helperFee': price['helper'],
                  'miscFee': price['misc'],
                  'gasPrice': price['gasPrice'],
                  'markUpPrice': price['markUpPrice'],
                })
            .toList();
      });
    } catch (e) {
      print('Exception fetching pricing: $e');
    }
  }

  Future<void> fetchSupplier() async {
    final response =
        await Supabase.instance.client.from('supplier').select('*');

    if (!mounted) return;
    setState(() {
      supplier = response
          .map<Map<String, dynamic>>((supplier) => {
                'supplierID': supplier['supplierID'],
                'companyName': supplier['companyName'],
                'fullName':
                    '${supplier['firstName'] ?? ""} - ${supplier['lastName'] ?? ""}',
              })
          .toList();

      if (supplier.isNotEmpty) {
        selectedSupplier = supplier.first;
      }
    });
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

  Future<void> fetchEmployeePos() async {
    final response =
        await Supabase.instance.client.from('employeePosition').select('*');

    setState(() {
      employeeRoles = List<Map<String, dynamic>>.from(response);
      filteredEmployeePos = employeeRoles;
    });
  }

// CRUD
  Future<void> insertSupplierPrice() async {
    final supplierID = selectedSupplier?['supplierID'];
    final loadID = selectedLoad?['loadID'];
    final price = priceController.text;

    if (supplierID != null && loadID != null && price.isNotEmpty) {
      try {
        final response = await supabase.from('supplierLoadPrice').insert([
          {
            'supplier_id': supplierID,
            'load_id': loadID,
            'price': price,
          }
        ]);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Successfully added!'),
          backgroundColor: Colors.green,
        ));
        getSupplierLoadPrice();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e was found!'),
        ));
      }
    }
  }

  Future<void> insertEmployeeRole() async {
    final employeeRole = employeeRoleController.text;

    if (employeeRole.isNotEmpty) {
      try {
        final response = await supabase.from('employeePosition').insert([
          {
            'positionName': employeeRole,
          }
        ]);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Successfully added!'),
          backgroundColor: Colors.green,
        ));
        fetchEmployeePos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e was found!'),
        ));
      }
    }
  }

  Future<void> deleteSupplierPrice(int index) async {
    try {
      final supplierPriceID = supplierLoadPrice[index]['id']; // Get ID
      await Supabase.instance.client
          .from('supplierLoadPrice')
          .delete()
          .eq('id', supplierPriceID);

      setState(() {
        supplierLoadPrice.removeAt(index);
        filteredSupplierLoadPrice = supplierLoadPrice;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully removed'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to remove: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> updateSupplierPrice(int supplierPriceID) async {
    final supplierID = selectedSupplier?['supplierID'];
    final loadID = selectedLoad?['loadID'];
    final price = priceController.text;

    if (supplierID != null && loadID != null && price.isNotEmpty) {
      try {
        final response = await supabase.from('supplierLoadPrice').update({
          'supplier_id': supplierID,
          'load_id': loadID,
          'price': price,
        }).eq('id', supplierPriceID);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Successfully updated!'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }
    }
  }

  Future<void> addSupplierPrice() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("ADD"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  dropDown('Select a Supplier', supplier, selectedSupplier,
                      (Map<String, dynamic>? newValue) {
                    setState(() {
                      selectedSupplier = newValue;
                    });
                  }, 'companyName'),
                  dropDown('Select a load', loadtypes, selectedLoad,
                      (Map<String, dynamic>? newValue) {
                    setState(() {
                      selectedLoad = newValue;
                    });
                  }, 'loadtype'),
                  const SizedBox(height: 20),
                  textField(priceController, 'Price: ', context, enabled: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        insertSupplierPrice();
                        fetchLoadTypes();
                        fetchSupplier();
                      },
                      child: const Text("ADD"))
                ],
              ),
            ),
          );
        });
  }

  Future<void> updSupplierPrice(Map<String, dynamic> supplierPrice) async {
    setState(() {
      selectedSupplier = supplier.firstWhere(
        (supplier) =>
            supplier['companyName'] == supplierPrice['supplier']['companyName'],
        orElse: () => supplier.first,
      );

      selectedLoad = loadtypes.firstWhere(
        (load) => load['loadtype'] == supplierPrice['typeofload']['loadtype'],
        orElse: () => loadtypes.first,
      );

      priceController.text = supplierPrice['price'].toString();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("UPDATE"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dropDown('Select a Supplier', supplier, selectedSupplier,
                    (Map<String, dynamic>? newValue) {
                  setState(() {
                    selectedSupplier = newValue;
                  });
                }, 'companyName'),
                dropDown('Select a load', loadtypes, selectedLoad,
                    (Map<String, dynamic>? newValue) {
                  setState(() {
                    selectedLoad = newValue;
                  });
                }, 'loadtype'),
                const SizedBox(
                  height: 25,
                ),
                textField(priceController, 'Price: ', context, enabled: true),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  onPressed: () {
                    updateSupplierPrice(supplierPrice['id']);
                    getSupplierLoadPrice();
                    Navigator.of(context).pop();
                  },
                  child: const Text("UPDATE"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> addEmployeeRole() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("ADD"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  textField(employeeRoleController, 'Employee Role: ', context,
                      enabled: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        insertEmployeeRole();
                      },
                      child: const Text("ADD"))
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getSupplierLoadPrice();
    fetchSupplier();
    fetchLoadTypes();
    fetchEmployeePos();
    fetchPricing();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: buildManagementPage(screenWidth, screenHeight, context),
        label: 'Management');
  }

  Widget buildManagementPage(
      double screenWidth, double screenHeight, BuildContext context) {
    switch (selectedManagementPage) {
      case 'Price':
        return priceManagement(context);
      case 'Employee Roles':
        return positionManagement(context);
      case 'Pricing Computation':
        return pricingManagement(context);
      default:
        return priceManagement(context);
    }
  }

  Scaffold positionManagement(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                addEmployeeRole();
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                String reloaded = 'Role List Reloaded!';
                fetchEmployeePos();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(reloaded),
                  backgroundColor: Colors.green,
                ));
              },
              icon: const Icon(Icons.replay)),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            DropdownButton<String>(
              dropdownColor: Colors.orangeAccent,
              elevation: 16,
              value: selectedManagementPage,
              onChanged: (String? newValue) {
                setState(() {
                  selectedManagementPage = newValue!;
                  fetchEmployeePos();
                });
              },
              items: <String>['Price', 'Employee Roles', 'Pricing Computation']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: filterEmployeeResults,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.black),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // Header
                    const TableRow(
                      decoration: BoxDecoration(color: Colors.orangeAccent),
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Role ID',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Employee Role',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    // Generate rows dynamically based on filtered data
                    ...filteredEmployeePos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final employeeRoles = entry.value;

                      return TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${employeeRoles['positionID']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${employeeRoles['positionName']}'),
                            ),
                          )
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold priceManagement(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AllLoadPage.routeName);
              },
              child: const Text('View Load')),
          IconButton(
              onPressed: () {
                addSupplierPrice();
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                String reloaded = 'Price List Reloaded!';
                getSupplierLoadPrice();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(reloaded),
                  backgroundColor: Colors.green,
                ));
              },
              icon: const Icon(Icons.replay)),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            DropdownButton<String>(
              // dropdownColor: Colors.orangeAccent,
              elevation: 16,
              value: selectedManagementPage,
              onChanged: (String? newValue) {
                setState(() {
                  selectedManagementPage = newValue!;
                  fetchEmployeePos();
                });
              },
              items: <String>['Price', 'Employee Roles', 'Pricing Computation']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: filterSearchResults,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.black),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // Header
                    const TableRow(
                      decoration: BoxDecoration(color: Colors.orangeAccent),
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Company Name',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Load Type',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Price',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Action',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Last Update',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    // Generate rows dynamically based on filtered data
                    ...filteredSupplierLoadPrice.asMap().entries.map((entry) {
                      final index = entry.key;
                      final supplierPrice = entry.value;

                      return TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  '${supplierPrice['supplier']['companyName']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  '${supplierPrice['typeofload']['loadtype']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('PHP ${supplierPrice['price']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      updSupplierPrice(supplierPrice);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      deleteSupplierPrice(index);
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                supplierPrice['lastupdated'] != null
                                    ? DateFormat('yyyy-MM-dd').format(
                                        DateTime.parse(
                                            supplierPrice['lastupdated']))
                                    : 'N/A',
                                style: const TextStyle(color: Colors.grey),
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
          ],
        ),
      ),
    );
  }

  Scaffold pricingManagement(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                addEmployeeRole();
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                String reloaded = 'Role List Reloaded!';
                fetchEmployeePos();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(reloaded),
                  backgroundColor: Colors.green,
                ));
              },
              icon: const Icon(Icons.replay)),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            DropdownButton<String>(
              dropdownColor: Colors.orangeAccent,
              elevation: 16,
              value: selectedManagementPage,
              onChanged: (String? newValue) {
                setState(() {
                  selectedManagementPage = newValue!;
                  fetchPricing();
                });
              },
              items: <String>['Price', 'Employee Roles', 'Pricing Computation']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: filterEmployeeResults,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.black),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // Header
                    const TableRow(
                      decoration: BoxDecoration(color: Colors.orangeAccent),
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Toll Fee',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Driver Fee',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Helper Fee',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Miscellaneous Fee',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Gas Price',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Mark-up Price',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Actions',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    // Generate rows dynamically based on filtered data
                    ...pricingList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pricing = entry.value;

                      return TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${pricing['tollFee']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${pricing['driverFee']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${pricing['helperFee']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${pricing['miscFee']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${pricing['gasPrice']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${pricing['markUpPrice']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  editPricing(pricing['id']);
                                },
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
          ],
        ),
      ),
    );
  }
}
