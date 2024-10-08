import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/textfield.dart';
import 'package:maviken/screens/billing_statement.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HaulingAdvice extends StatefulWidget {
  static const routeName = '/HaulingAdvice';
  const HaulingAdvice({super.key});

  @override
  State<HaulingAdvice> createState() => _HaulingAdviceState();
}

class _HaulingAdviceState extends State<HaulingAdvice> {
  final _haulingAdviceNumController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _typeOfLoadController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _volumeDeliveredController = TextEditingController();
  final _totalVolumeController = TextEditingController();
  final _haulingAdvicePriceController = TextEditingController();

// Drop Down Variables
  String? _salesOrderId;
  List<Map<String, dynamic>> _deliveryData = [];
  String? _selectedDeliveryId;
  List<Map<String, dynamic>> _employees = [];
  Map<String, dynamic>? _selectedEmployee;
  List<Map<String, dynamic>> _trucks = [];
  Map<String, dynamic>? _selectedTruck;
  List<Map<String, dynamic>> _suppliers = [];
  Map<String, dynamic>? _selectedSupplier;
  List<Map<String, dynamic>> _loadList = [];
  Map<String, dynamic>? _selectedLoad;

  Future<void> _fetchSalesOrderLoad() async {
    print('SALES ORDER ID: $_salesOrderId');
    if (_salesOrderId == null) return; // Check for null before proceeding

    try {
      final response = await Supabase.instance.client
          .from('salesOrderLoad')
          .select('*, typeofload!inner(*), salesOrder!inner(salesOrder_id)')
          .eq('salesOrder_id', _salesOrderId!);

      if (response.isNotEmpty) {
        setState(() {
          _loadList = response.map<Map<String, dynamic>>((loadlist) {
            return {
              'id': loadlist['id'].toString(),
              'loadtype': loadlist['typeofload']['loadtype'],
            };
          }).toList();

          // Ensure that _selectedLoad is set correctly to a Map
          if (_loadList.isNotEmpty) {
            _selectedLoad =
                _loadList.first; // Set the entire map, not just the ID
          }
        });
      }
    } catch (e) {
      print('Error Sales Order Load: $e');
    }
  }

  Future<void> _fetchDeliveryData() async {
    final response = await Supabase.instance.client
        .from('delivery')
        .select('deliveryid, salesOrder!inner(custName, address)');
    if (mounted) {
      setState(() {
        _deliveryData = response
            .map<Map<String, dynamic>>((delivery) => {
                  'deliveryid': delivery['deliveryid'].toString(),
                  'custName': delivery['salesOrder']['custName'],
                  'address': delivery['salesOrder']['address'],
                })
            .toList();
        if (_deliveryData.isNotEmpty) {
          _selectedDeliveryId = _deliveryData.first['deliveryid'];
          _fetchSalesOrderInfo();
        }
      });
    }
  }

  Future<void> _fetchSupplierInfo() async {
    final response =
        await Supabase.instance.client.from('supplier').select('*');
    if (mounted) {
      setState(() {
        _suppliers = response
            .map<Map<String, dynamic>>((supplier) => {
                  'supplierID': supplier['supplierID'],
                  'companyName': supplier['companyName'],
                })
            .toList();
        if (_suppliers.isNotEmpty) {
          _selectedSupplier = _suppliers.first;
        }
      });
    }
  }

  Future<void> _fetchEmployeeData() async {
    final response = await Supabase.instance.client
        .from('employee')
        .select('employeeID, lastName, firstName')
        .eq('positionID', 3);
    if (mounted) {
      setState(() {
        _employees = response
            .map<Map<String, dynamic>>((employee) => {
                  'employeeID': employee['employeeID'],
                  'fullName':
                      '${employee['lastName']}, ${employee['firstName']}',
                })
            .toList();
        if (_employees.isNotEmpty) {
          _selectedEmployee = _employees.first;
        }
      });
    }
  }

  Future<void> _fetchTruckData() async {
    final response = await Supabase.instance.client
        .from('Truck')
        .select('truckID, plateNumber');

    if (!mounted) return;
    setState(() {
      _trucks = response
          .map<Map<String, dynamic>>((truck) => {
                'truckID': truck['truckID'],
                'plateNumber': truck['plateNumber'],
              })
          .toList();
      if (_trucks.isNotEmpty) {
        _selectedTruck = _trucks.first;
      }
    });
  }

  Future<void> _fetchSalesOrderInfo() async {
    if (_selectedDeliveryId == null) return;

    final deliveryIdOnly = _selectedDeliveryId!.split(' - ')[0];
    final response = await Supabase.instance.client
        .from('salesOrder')
        .select(
            'salesOrder_id, custName, address, date, haulingAdvice!inner(deliveryID)')
        .eq('haulingAdvice.deliveryID', deliveryIdOnly);

    if (!mounted) return;

    setState(() {
      if (response.isNotEmpty) {
        final order = response.first;
        _salesOrderId = order['salesOrder_id'].toString();

        _customerNameController.text = order['custName'] ?? '';
        _addressController.text = order['address'] ?? '';
      } else {
        _customerNameController.clear();
        _addressController.clear();
        _dateController.clear();
        _typeOfLoadController.clear();
        _volumeDeliveredController.clear();
        _plateNumberController.clear();
      }
    });
  }

  Future<void> _createDataHA() async {
    print("Selected Delivery ID: $_selectedDeliveryId");
    print("Selected Employee: $_selectedEmployee");
    print("Selected Truck: $_selectedTruck");
    print("Sales Order ID: $_salesOrderId");
    if (_selectedDeliveryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Delivery ID')));
      return;
    }

    if (_selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an Employee')));
      return;
    }

    if (_selectedTruck == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a Truck')));
      return;
    }

    if (_salesOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sales Order ID is missing')));
      return;
    }

    final truckID = _selectedTruck!['truckID'];
    final employeeID = _selectedEmployee!['employeeID'];
    final volumeDelivered = int.tryParse(_volumeDeliveredController.text) ?? 0;
    final supplierName = _selectedSupplier!['companyName'];

    try {
      // Fetch the current volume delivered and total volume from salesOrderLoad
      final response = await Supabase.instance.client
          .from('salesOrderLoad')
          .select('volumeDel, totalVolume')
          .eq('id', _salesOrderId as Object)
          .limit(1);

      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No data found for the given Sales Order ID')));
        return;
      }

      final orderLoad = response.first;
      int currentVolumeDelivered = orderLoad['volumeDel'] ?? 0;
      int totalVolume = orderLoad['totalVolume'] ?? 0;

      // Check for the volume delivered matches the total volume, if matches stops adding
      final updatedVolumeDelivered = currentVolumeDelivered + volumeDelivered;
      if (updatedVolumeDelivered > totalVolume) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Error: The volume delivered exceeds the total allowed volume.')));
        return;
      }

      // Insert the Hauling Advice record
      await Supabase.instance.client.from('haulingAdvice').insert({
        'haulingAdviceId': _haulingAdviceNumController.text,
        'truckID': truckID,
        'driverID': employeeID,
        'volumeDel': volumeDelivered,
        'salesOrder_id': _salesOrderId,
        'date': _dateController.text,
        'deliveryID': int.parse(_selectedDeliveryId!),
        'supplier': supplierName,
      });

      // Update the volume in the salesOrderLoad table
      await Supabase.instance.client.from('salesOrderLoad').update(
          {'volumeDel': updatedVolumeDelivered}).eq('id', _salesOrderId!);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hauling Advice saved successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      print('Error in createDataHA: $e');
    }
  }

  Future<void> _showBillingStatement() async {
    if (_selectedDeliveryId == null || _salesOrderId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('haulingAdvice')
          .select(
              'haulingAdviceId, volumeDel, truckID, date, supplier, Truck!inner(plateNumber)')
          .eq('salesOrder_id', _salesOrderId as Object);

      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No data found for the given Sales Order ID')),
        );
        return;
      }

      List<Map<String, dynamic>> haulingAdviceDetails = response
          .map<Map<String, dynamic>>((advice) => {
                'haulingAdviceId': advice['haulingAdviceId'],
                'typeofload': advice['salesOrder']['typeofload'],
                'price': advice['salesOrder']['price'],
                'volumeDel': advice['volumeDel'],
                'calculatedPrice':
                    (advice['volumeDel'] * advice['salesOrder']['price'])
                        .toString(),
                'date': advice['date'],
                'plateNumber': advice['Truck']['plateNumber'],
                'supplier': advice['supplier']
              })
          .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillingStatement(
            customerName: _customerNameController.text,
            haulingAdviceDetails: haulingAdviceDetails,
          ),
        ),
      );
    } catch (e) {
      print('Error in showBillingStatement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _haulingAdviceNumController.dispose();
    _customerNameController.dispose();
    _addressController.dispose();
    _typeOfLoadController.dispose();
    _plateNumberController.dispose();
    _dateController.dispose();
    _volumeDeliveredController.dispose();
    _totalVolumeController.dispose();
    _haulingAdvicePriceController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchDeliveryData(); // Step 1: Fetch delivery data
    _fetchEmployeeData(); // Step 2: Fetch employee data
    _fetchTruckData(); // Step 3: Fetch truck data
    _fetchSupplierInfo(); // Step 4: Fetch supplier info
  }

  void _onDeliverySelected(String? selectedDeliveryId) {
    setState(() {
      _selectedDeliveryId = selectedDeliveryId;
    });

    // Step 5: Fetch sales order info after delivery is selected
    _fetchSalesOrderInfo();

    // Step 6: Fetch sales order load after sales order info is fetched
    _fetchSalesOrderLoad();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const BarTop(),
      body: SidebarDrawer(
        drawer: const BarTop(),
        body: Container(
          color: Colors.white,
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  leading: const DrawerIcon(),
                  title: const Text("Hauling Advice"),
                ),
                Flexible(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(50),
                    child: Container(
                      padding: const EdgeInsets.all(50),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          dropDown('Load List:', _loadList, _selectedLoad,
                              (Map<String, dynamic>? newValue) {
                            setState(() {
                              _selectedLoad = newValue;
                            });
                          }, 'loadtype'),
                          DropdownButton<String>(
                            value: _selectedDeliveryId,
                            onChanged: (value) {
                              _onDeliverySelected(
                                  value); // Call the new method to handle fetching
                            },
                            items: _deliveryData.map((delivery) {
                              final displayText =
                                  '${delivery['deliveryid']} - ${delivery['custName']} - ${delivery['address']}';
                              return DropdownMenuItem<String>(
                                value: delivery['deliveryid'],
                                child: Text(displayText),
                              );
                            }).toList(),
                            hint: const Text('Select Delivery ID'),
                          ),
                          const SizedBox(height: 20),
                          textField(_haulingAdviceNumController,
                              'Hauling Advice #', context,
                              enabled: true),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              textField(_customerNameController,
                                  'Customer Name', context),
                              SizedBox(
                                width: screenWidth * .15,
                                height: 60,
                                child: TextField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: _dateController,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                    labelText: 'Date',
                                    labelStyle: TextStyle(color: Colors.black),
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2500),
                                    );
                                    if (pickedDate != null) {
                                      _dateController.text = pickedDate
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0];
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              textField(_addressController, 'Address', context),
                              textField(_volumeDeliveredController,
                                  'Volume Delivered', context,
                                  enabled: true, width: .115),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              textField(
                                  _typeOfLoadController, 'Description', context,
                                  width: .35),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  padding: const EdgeInsets.all(15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _createDataHA,
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  padding: const EdgeInsets.all(15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _showBillingStatement,
                                child: const Text(
                                  'View Billing Statement',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: dropDown('Truck Driver Assigned:',
                                    _employees, _selectedEmployee,
                                    (Map<String, dynamic>? newValue) {
                                  setState(() {
                                    _selectedEmployee = newValue;
                                  });
                                }, 'fullName'),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: dropDown(
                                    'Plate Number:', _trucks, _selectedTruck,
                                    (Map<String, dynamic>? newValue) {
                                  setState(() {
                                    _selectedTruck = newValue;
                                  });
                                }, 'plateNumber'),
                              ),
                              Expanded(
                                  child: dropDown(
                                      'Supplier', _suppliers, _selectedSupplier,
                                      (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedSupplier = newValue;
                                });
                              }, 'companyName'))
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
      ),
    );
  }

  Widget title(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget dropDown(
    String labelText,
    List<Map<String, dynamic>> items,
    Map<String, dynamic>? selectedItem,
    ValueChanged<Map<String, dynamic>?> onChanged,
    dbItem,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        const SizedBox(height: 10),
        DropdownButton<Map<String, dynamic>>(
          hint: const Text('Select an item'),
          value: selectedItem,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<Map<String, dynamic>>>(
              (Map<String, dynamic> value) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: value,
              child: Text(
                value[dbItem] ?? value[dbItem],
                style: TextStyle(color: Colors.grey[700]),
              ),
            );
          }).toList(),
          dropdownColor: Colors.white,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
          underline: Container(),
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }
}
