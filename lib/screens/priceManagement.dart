import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/textfield.dart';
import 'package:maviken/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PriceManagement extends StatefulWidget {
  static const routeName = '/PriceManagement';
  const PriceManagement({super.key});

  @override
  State<PriceManagement> createState() => PriceManagementState();
}

class PriceManagementState extends State<PriceManagement> {
  final TextEditingController priceController = TextEditingController();
  List<Map<String, dynamic>> supplierLoadPrice = [];
  List<Map<String, dynamic>> supplier = [];
  Map<String, dynamic>? selectedSupplier;
  List<Map<String, dynamic>> loadtypes = [];
  Map<String, dynamic>? selectedLoad;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredSupplierLoadPrice = [];

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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e was found!'),
        ));
      }
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
            title: Text("ADD"),
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
                  textField(priceController, 'Price: ', context, enabled: true),
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
    // Set the pre-selected supplier and load based on the data being edited
    setState(() {
      selectedSupplier = supplier.firstWhere(
        (supplier) =>
            supplier['companyName'] == supplierPrice['supplier']['companyName'],
        orElse: () => supplier
            .first, // In case of any mismatch, default to first supplier
      );

      selectedLoad = loadtypes.firstWhere(
        (load) => load['loadtype'] == supplierPrice['typeofload']['loadtype'],
        orElse: () => loadtypes
            .first, // In case of any mismatch, default to first load type
      );

      // Pre-fill the price controller with the existing price value
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

  @override
  void initState() {
    super.initState();
    getSupplierLoadPrice();
    fetchSupplier();
    fetchLoadTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Management'),
        actions: [
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
      body: Column(
        children: [
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
              onChanged: filterSearchResults,
            ),
          ),
          Expanded(
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
                  ...filteredSupplierLoadPrice.map((supplierPrice) {
                    return TableRow(
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '${supplierPrice['supplier']['companyName']}'),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '${supplierPrice['typeofload']['loadtype']}'),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${supplierPrice['price']}'),
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
                                      updSupplierPrice(supplierPrice);
                                    },
                                    icon: Icon(Icons.edit)),
                              ],
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
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
    );
  }
}
