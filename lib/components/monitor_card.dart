import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonitorCard extends StatefulWidget {
  final String id;
  final String custName;
  final String date;
  final String deliveryAdd;
  final String typeofload;
  final String totalVolume;
  final String price;
  final String volumeDel;
  final String status;

  final double screenWidth;
  final double initialHeight;
  final double initialWidth;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewHA;
  final List<Map<String, dynamic>> loads;

  const MonitorCard({
    super.key,
    required this.id,
    required this.custName,
    required this.date,
    required this.deliveryAdd,
    required this.typeofload,
    required this.totalVolume,
    required this.price,
    required this.volumeDel,
    required this.status,
    required this.screenWidth,
    required this.initialHeight,
    required this.initialWidth,
    required this.onEdit,
    required this.onDelete,
    required this.loads,
    required this.onViewHA,
  });

  @override
  State<MonitorCard> createState() => _MonitorCardState();
}

class _MonitorCardState extends State<MonitorCard> {
  String currentStatus = '';
  int? supplierID;
  int? loadID;
  final TextEditingController volumeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<Map<String, dynamic>> _typeofload = [];
  Map<String, dynamic>? _selectedLoad;
  List<Map<String, dynamic>> _suppliers = [];
  Map<String, dynamic>? _selectedSupplier;
  List<Map<String, dynamic>> pricing = [];

  final TextEditingController gasConsumptionController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
    _updateStatus();
    fetchSupplier();
    fetchLoad();
    fetchPricing();
  }

  Future<void> _updateStatus() async {
    String newStatus = await determineStatus();
    setState(() {
      currentStatus = newStatus;
    });
  }

  List<Map<String, dynamic>> availableLoadTypes = [];

// Function to fetch available load types from the database
  Future<void> fetchLoad() async {
    final response =
        await Supabase.instance.client.from('typeofload').select('*');
    setState(() {
      _typeofload = response
          .map<Map<String, dynamic>>((typeofload) => {
                'loadID': typeofload['loadID'] ?? 'Unknown',
                'typeofload': typeofload['loadtype'] ?? 'Unknown Load',
              })
          .toList();
      if (_typeofload.isNotEmpty) {
        _selectedLoad = _typeofload.first;
      }
    });
  }

  Future<void> fetchPricing() async {
    final response = await Supabase.instance.client.from('pricing').select('*');
    setState(() {
      pricing = response
          .map<Map<String, dynamic>>((price) => {
                'tollFee': price['tollFee'],
                'driverFee': price['driver'],
                'helperFee': price['helper'],
                'miscFee': price['misc'],
                'gasPrice': price['gasPrice'],
                'markUpPrice': price['markUpPrice'],
              })
          .toList();
    });
  }

  Future<void> fetchSupplier() async {
    try {
      final response = await supabase.from('supplier').select('*');

      if (!mounted) return;
      setState(() {
        _suppliers = response
            .map<Map<String, dynamic>>((supplier) => {
                  'supplierID': supplier['supplierID'],
                  'companyName': supplier['companyName'],
                })
            .toList();
        if (_suppliers.isNotEmpty) {
          _selectedSupplier = _suppliers.first;
          supplierID = _selectedSupplier?['supplierID'];
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchSupplierLoadPrice() async {
    if (supplierID == null) return;

    try {
      final response = await supabase
          .from('supplierLoadPrice')
          .select('*, typeofload!inner(*)')
          .eq('supplier_id', supplierID as Object);

      if (!mounted) return;
      setState(() {
        _typeofload = response.map<Map<String, dynamic>>((load) {
          return {
            'price': load['price'],
            'loadID': load['load_id'],
            'typeofload': load['typeofload']['loadtype'],
          };
        }).toList();

        if (_typeofload.isNotEmpty) {
          _selectedLoad = _typeofload.first;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void calculateTotalPrice() {
    double loadPrice =
        double.tryParse(_selectedLoad?['price'].toString() ?? '0') ?? 0;
    double gasConsumption = double.tryParse(gasConsumptionController.text) ?? 0;

    // Assuming you want to include toll, driver, helper, misc, and gas price
    double tollFee = pricing.isNotEmpty
        ? double.tryParse(pricing[0]['tollFee'].toString()) ?? 0
        : 0;
    double driverFee = pricing.isNotEmpty
        ? double.tryParse(pricing[0]['driverFee'].toString()) ?? 0
        : 0;
    double helperFee = pricing.isNotEmpty
        ? double.tryParse(pricing[0]['helperFee'].toString()) ?? 0
        : 0;
    double miscFee = pricing.isNotEmpty
        ? double.tryParse(pricing[0]['miscFee'].toString()) ?? 0
        : 0;
    double gasPrice = pricing.isNotEmpty
        ? double.tryParse(pricing[0]['gasPrice'].toString()) ?? 0
        : 0;

    double markUpPrice = pricing.isNotEmpty
        ? double.tryParse(pricing[0]['markUpPrice'].toString()) ?? 0
        : 0;

    double gasTotal = gasConsumption * gasPrice;

    // Calculate total price
    double totalPrice = ((gasTotal / 20) +
        (tollFee / 20) +
        (driverFee / 20) +
        (helperFee / 20) +
        (miscFee / 20) +
        (markUpPrice / 20));
    // (gasTotal + tollFee + driverFee + helperFee + miscFee + markUpPrice) / 20;

    totalPrice = totalPrice + loadPrice;
    // Update the price controller
    priceController.text =
        totalPrice.toStringAsFixed(2); // Format to 2 decimal places
  }

// Call this method whenever the load price or gas consumption changes
  void _onLoadOrGasConsumptionChange() {
    setState(() {
      calculateTotalPrice();
    });
  }

  void _showAddLoadDialog(BuildContext context) {
    List<Map<String, dynamic>> filteredLoads = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            // Fetch loads dynamically based on selected supplier
            Future<void> _updateLoads() async {
              if (_selectedSupplier == null) return;

              try {
                final response = await supabase
                    .from('supplierLoadPrice')
                    .select('*, typeofload!inner(*)')
                    .eq('supplier_id', _selectedSupplier!['supplierID']);

                setState(() {
                  filteredLoads = response.map<Map<String, dynamic>>((load) {
                    return {
                      'price': load['price'],
                      'loadID': load['load_id'],
                      'typeofload': load['typeofload']['loadtype'],
                    };
                  }).toList();

                  // Update default selected load if available
                  if (filteredLoads.isNotEmpty) {
                    _selectedLoad = filteredLoads.first;
                  } else {
                    _selectedLoad = null;
                  }
                });
              } catch (e) {
                print('Error fetching loads: $e');
              }
            }

            return AlertDialog(
              title: const Text('Add Load'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown for selecting supplier
                  dropDown(
                    'Supplier',
                    _suppliers,
                    _selectedSupplier,
                    (Map<String, dynamic>? newValue) async {
                      setState(() {
                        _selectedSupplier = newValue;
                      });
                      await _updateLoads(); // Fetch loads for the selected supplier
                    },
                    'companyName',
                  ),
                  // Dropdown for selecting load type
                  dropDown(
                    'Type of Load',
                    filteredLoads,
                    _selectedLoad,
                    (Map<String, dynamic>? newValue) {
                      setState(() {
                        _selectedLoad = newValue;

                        calculateTotalPrice();
                      });
                    },
                    'typeofload',
                  ),
                  // Text fields for volume and price
                  TextField(
                    controller: gasConsumptionController,
                    decoration:
                        const InputDecoration(labelText: 'Gas Consumption'),
                    onChanged: (value) {
                      calculateTotalPrice();
                    },
                  ),

                  TextField(
                    controller: volumeController,
                    decoration: const InputDecoration(labelText: 'Volume (m³)'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                        labelText: 'Price', enabled: false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await _addLoadToSalesOrder(
                      _selectedLoad,
                      volumeController.text,
                      priceController.text,
                      _selectedSupplier?['supplierID'],
                    );
                    setState(() {
                      _selectedSupplier = _selectedSupplier;
                      _selectedLoad = _selectedLoad;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add Load'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addLoadToSalesOrder(Map<String, dynamic>? selectedLoad,
      String volume, String price, int supplierID) async {
    if (selectedLoad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a load type')),
      );
      return;
    }

    int? volumeInt = int.tryParse(volume);
    double? priceDouble = double.tryParse(price);

    if (volumeInt == null || volumeInt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid volume')),
      );
      return;
    }

    if (priceDouble == null || priceDouble <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price')),
      );
      return;
    }

    try {
      await supabase.from('salesOrderLoad').insert({
        'salesOrder_id': widget.id,
        'loadID': selectedLoad['loadID'],
        'totalVolume': volumeInt,
        'price': priceDouble,
        'supplierID': supplierID,
        'volumeDel': 0,
      });

      setState(() {
        widget.loads.add({
          'typeofload': selectedLoad['typeofload'],
          'totalVolume': volumeInt,
          'price': priceDouble,
          'supplierID': supplierID,
          'volumeDel': 0,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load added successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add load: $error')),
      );
    }
  }

  void onEditLoad(BuildContext context, Map<String, dynamic> load) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController volumeController =
            TextEditingController(text: load['totalVolume'].toString());
        final TextEditingController priceController =
            TextEditingController(text: load['loadPrice'].toString());

        return AlertDialog(
          title: const Text('Edit Load'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                  controller: volumeController,
                  decoration: const InputDecoration(labelText: 'Volume'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ),
            ],
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
                  final updatedLoad = {
                    'totalVolume': int.parse(volumeController.text),
                    'price': double.parse(priceController.text),
                  };

                  await supabase
                      .from('salesOrderLoad')
                      .update(updatedLoad)
                      .eq('salesOrderLoad_id', load['salesOrderLoad_id']);

                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error updating load: $e');
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Failed to update the load.'),
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

  void onDeleteLoad(BuildContext context, Map<String, dynamic> load) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Load'),
          content: const Text('Are you sure you want to delete this load?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await supabase
                      .from('salesOrderLoad')
                      .delete()
                      .eq('salesOrderLoad_id', load['salesOrderLoad_id']);
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error deleting load: $e');
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Failed to delete the load.'),
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

  Future<String> determineStatus() async {
    // Check if all loads are fully delivered
    bool allLoadsDelivered = widget.loads.every((load) {
      var volumeDelivered = int.tryParse(load['volumeDel'].toString()) ?? 0;
      var totalVolume = int.tryParse(load['totalVolume'].toString()) ?? 0;
      return volumeDelivered >= totalVolume;
    });

    String newStatus;

    if (allLoadsDelivered) {
      newStatus = 'Complete';
    } else {
      // Check if at least one load is partially delivered
      bool isOnRoute = widget.loads.any((load) {
        var volumeDelivered = int.tryParse(load['volumeDel'].toString()) ?? 0;
        return volumeDelivered > 0;
      });

      newStatus = isOnRoute ? 'On Route' : widget.status;
    }

    // If the new status is different from the current one, update the database
    if (newStatus != widget.status) {
      try {
        await supabase
            .from('salesOrder')
            .update({'status': newStatus}).eq('salesOrder_id', widget.id);
      } catch (e) {
        print('Failed to update status in the database: $e');
      }
    }

    return newStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(15),
      // ),
      // elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.id} - ${widget.custName}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Delivery: ${widget.deliveryAdd}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          'Status: ${currentStatus}',
                          style: TextStyle(
                            color: currentStatus == 'Complete'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: widget.onViewHA,
                              child: const Text(
                                'View All Hauling Advice',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            if (currentStatus == 'No Delivery') ...[],
                            TextButton(
                              onPressed: () {
                                _showAddLoadDialog(context);
                              },
                              child: const Text(
                                'Add Load',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: determineStatus() == "Complete"
                            ? Colors.grey
                            : Colors.blueAccent,
                      ),
                      onPressed: determineStatus() == "Complete"
                          ? null
                          : widget.onEdit,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color:
                            determineStatus() == "Complete" ? null : Colors.red,
                      ),
                      onPressed: determineStatus() == "Complete"
                          ? null
                          : widget.onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            ExpansionTile(
              title: const Text(
                'Load Details',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1.5),
                    2: FlexColumnWidth(1.5),
                  },
                  children: [
                    // Table header
                    const TableRow(
                      decoration: BoxDecoration(color: Colors.orangeAccent),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Type of Load',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Volume',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Billing',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Actions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    for (var load in widget.loads)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '${load['typeofload']['loadtype'] ?? "Unknown Load"}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '${load['volumeDel']} / ${load['totalVolume']}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                'PHP ${((load['price'] ?? 0) * (load['volumeDel'] ?? 0)).toStringAsFixed(2)}'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blueAccent),
                                  onPressed: () => onEditLoad(context, load),
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => onDeleteLoad(context, load),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
