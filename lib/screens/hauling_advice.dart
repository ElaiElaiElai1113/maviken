import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/textfield.dart';
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
  final _pickUpAddController = TextEditingController();
  final _deliveryAddController = TextEditingController();
  final _typeOfLoadController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _volumeDeliveredController = TextEditingController();
  final _totalVolumeController = TextEditingController();
  final _haulingAdvicePriceController = TextEditingController();
  final _driverNameController = TextEditingController();

// Drop Down Variables
  String? _salesOrderId;
  List<Map<String, dynamic>> _haulingAdviceList = [];
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

  void _editHaulingAdvice(int index) {
    // Get the selected hauling advice based on the index
    var selectedAdvice = _haulingAdviceList[index];

    // Populate controllers with the existing data
    _haulingAdviceNumController.text =
        selectedAdvice['haulingAdviceId'].toString();
    _customerNameController.text = selectedAdvice['customer'];
    _dateController.text = selectedAdvice['date'];
    _volumeDeliveredController.text = selectedAdvice['volumeDel'].toString();

    // Safely access nested fields
    _typeOfLoadController.text = selectedAdvice['salesOrder']?['salesOrderLoad']
            ?['typeofload']?['loadtype'] ??
        '';
    _plateNumberController.text = selectedAdvice['Truck']?['plateNumber'] ?? '';
    _driverNameController.text =
        selectedAdvice['employee']?['driverName'] ?? '';

    // Show a form or dialog to allow the user to edit the hauling advice
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Hauling Advice"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                textField(
                    _haulingAdviceNumController, 'Hauling Advice #', context,
                    enabled: true),
                const SizedBox(height: 10),
                textField(
                    _volumeDeliveredController, 'Volume Delivered', context),
                const SizedBox(height: 10),
                textField(
                    _plateNumberController, 'Truck Plate Number', context),
                const SizedBox(height: 10),
                textField(_driverNameController, 'Driver Name', context),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Update the hauling advice with the new values
                  _haulingAdviceList[index]['haulingAdviceId'] =
                      int.parse(_haulingAdviceNumController.text);
                  _haulingAdviceList[index]['customer'] =
                      _customerNameController.text;
                  _haulingAdviceList[index]['date'] = _dateController.text;
                  _haulingAdviceList[index]['volumeDel'] =
                      double.parse(_volumeDeliveredController.text);

                  _haulingAdviceList[index]['Truck']['plateNumber'] =
                      _plateNumberController.text;
                  _haulingAdviceList[index]['employee']['driverName'] =
                      _driverNameController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteHaulingAdvice(int index) {
    // Confirm deletion before proceeding
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Hauling Advice"),
          content: const Text(
              "Are you sure you want to delete this hauling advice?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Remove the selected hauling advice from the list
                  _haulingAdviceList.removeAt(index);
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchSalesOrderLoad() async {
    print('SALES ORDER ID: $_salesOrderId');
    if (_salesOrderId == null) return; // Check for null before proceeding

    try {
      final response = await Supabase.instance.client
          .from('salesOrderLoad')
          .select('*, typeofload!inner(*)')
          .eq('salesOrder_id', _salesOrderId!);

      // Print the response to check the structure and data types
      print('Response data: $response');

      if (response.isNotEmpty) {
        setState(() {
          // Map response to _loadList, accessing nested employee fields properly
          _loadList = response.map<Map<String, dynamic>>((loadlist) {
            return {
              'id': loadlist['id'].toString(),
              'loadtype': loadlist['typeofload']['loadtype'],
              'loadID': loadlist['loadID'],
            };
          }).toList();

          if (_loadList.isNotEmpty) {
            _selectedLoad = _loadList.first;
          }
        });
      }
    } catch (e) {
      print('Error Sales Order Load: $e');
    }
  }

  Future<void> _fetchDeliveryData() async {
    final response = await Supabase.instance.client.from('delivery').select(
        'deliveryid, salesOrder!inner(salesOrder_id,custName, pickUpAdd, deliveryAdd)');
    if (mounted) {
      setState(() {
        _deliveryData = response
            .map<Map<String, dynamic>>((delivery) => {
                  'deliveryid': delivery['deliveryid'].toString(),
                  'salesOrder_id':
                      delivery['salesOrder']['salesOrder_id'].toString(),
                  'custName': delivery['salesOrder']['custName'],
                  'pickUpAdd': delivery['salesOrder']['pickUpAdd'],
                  'deliveryAdd': delivery['salesOrder']['deliveryAdd'],
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
            'salesOrder_id, custName, pickUpAdd, deliveryAdd, date, haulingAdvice!inner(deliveryID)')
        .eq('haulingAdvice.deliveryID', deliveryIdOnly);

    if (!mounted) return;

    setState(() {
      if (response.isNotEmpty) {
        final order = response.first;
        _salesOrderId = order['salesOrder_id'].toString();

        _customerNameController.text = order['custName'] ?? '';
        _pickUpAddController.text = order['pickUpAdd'] ?? '';
        _deliveryAddController.text = order['deliveryAdd'] ?? '';

        // Now that _salesOrderId is set, fetch the sales order load
        _fetchSalesOrderLoad();
      } else {
        _customerNameController.clear();
        _pickUpAddController.clear();
        _deliveryAddController.clear();
        _dateController.clear();
        _typeOfLoadController.clear();
        _volumeDeliveredController.clear();
        _plateNumberController.clear();
      }
    });
  }

  Future<void> _fetchHaulingAdvices() async {
    if (_salesOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Sales Order')));
      return;
    }

    if (_selectedLoad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Load Type')));
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('haulingAdvice')
          .select(
              '*, Truck!inner(plateNumber), employee!inner(firstName, lastName), salesOrder!inner(custName)')
          .eq('salesOrder_id', _salesOrderId as Object);

      //  'haulingAdviceId': advice['haulingAdviceId'],
      //             'volumeDel': advice['volumeDel'],
      //             'loadtypes': advice['loadID'],
      //             'date': advice['date'],
      //             'truckID': advice['truckID'],
      //             'lastName': advice['employee']?['lastName'] ?? 'Unknown',
      //             'firstName': advice['employee']?['firstName'] ?? 'Unknown',
      //             'fullName':
      //                 '${advice['employee']?['firstName'] ?? 'Unknown'} ${advice['employee']?['lastName'] ?? 'Unknown'}',
      //             'plateNumber': advice['Truck']?['plateNumber'] ?? 'Unknown',
      //             'customer': advice['custName'] ?? 'Unknown Customer',
      if (mounted) {
        setState(() {
          setState(() {
            _haulingAdviceList = response
                .map<Map<String, dynamic>>((advice) => {
                      'haulingAdviceId': advice['haulingAdviceId'],
                      'volumeDel': advice['volumeDel'],
                      'date': advice['date'],
                      'truckID': advice['truckID'] ?? "Truck not specificed",
                      'fullName':
                          '${advice['employee']['firstName']} - ${advice['employee']['lastName']}',
                      'plateNumber': advice['Truck']['plateNumber'] ??
                          "Unknown plate number",
                      'customer': advice['salesOrder']['custName'] ??
                          "Unknown Customer",
                      'loadtype': advice['loadtype'],
                    })
                .toList();
          });
        });
      }
    } catch (e) {
      print('Error fetching Hauling Advices: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching Hauling Advices: ${e.toString()}'),
      ));
    }
    print(_haulingAdviceList);
  }

  Future<void> _createDataHA() async {
    // Data Validation
    if (_selectedDeliveryId == null ||
        _selectedEmployee == null ||
        _selectedTruck == null ||
        _salesOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please make sure all fields are selected')));
      return;
    }

    // Hauling Advice Number Validation
    int? haulingAdviceNumber = int.tryParse(_haulingAdviceNumController.text);
    if (haulingAdviceNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please insert a valid hauling advice number'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Date Validation
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please input a date"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    final selectedDate = DateTime.parse(_dateController.text);
    if (selectedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please set a valid date"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ensure _selectedLoad is not null and loadID is set
    if (_selectedLoad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Load Type')));
      return;
    }

    final truckID = _selectedTruck!['truckID'];
    final employeeID = _selectedEmployee!['employeeID'];
    final volumeDelivered = int.tryParse(_volumeDeliveredController.text) ?? 0;
    final supplierName = _selectedSupplier!['companyName'];
    final loadID = _selectedLoad!['loadID'];

    try {
      // Fetch the current volume delivered and total volume for this specific load and sales order
      final response = await Supabase.instance.client
          .from('salesOrderLoad')
          .select('volumeDel, totalVolume, typeofload(loadtype)')
          .eq('salesOrder_id', _salesOrderId as Object)
          .eq('loadID', loadID)
          .single();

      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('No data found for the given Sales Order ID and Load')));
        return;
      }

      final orderLoad = response;
      int currentVolumeDelivered = orderLoad['volumeDel'];
      int totalVolume = orderLoad['totalVolume'] ?? 0;
      String loadType = orderLoad['typeofload']['loadtype'] ?? '';

      // Check if the volume delivered exceeds the total volume
      final updatedVolumeDelivered = currentVolumeDelivered + volumeDelivered;
      if (updatedVolumeDelivered > totalVolume) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Error: The volume delivered exceeds the total allowed volume.')));
        return;
      }

      // Insert the Hauling Advice record with loadType
      await Supabase.instance.client.from('haulingAdvice').insert({
        'haulingAdviceId': _haulingAdviceNumController.text,
        'truckID': truckID,
        'driverID': employeeID,
        'volumeDel': volumeDelivered,
        'salesOrder_id': _salesOrderId,
        'date': _dateController.text,
        'deliveryID': int.parse(_selectedDeliveryId!),
        'supplier': supplierName,
        'loadtype': _selectedLoad?['loadtype'],
      });

      // Update the volume for the specific load in the salesOrderLoad table
      await Supabase.instance.client
          .from('salesOrderLoad')
          .update({'volumeDel': updatedVolumeDelivered})
          .eq('salesOrder_id', _salesOrderId!)
          .eq('loadID', loadID); // Ensure the update is for the specific load

      // Optionally add the new hauling advice to the list in state
      setState(() {
        _haulingAdviceList.add({
          'haulingAdviceId': _haulingAdviceNumController.text,
          'truckID': truckID,
          'volumeDel': volumeDelivered,
          'salesOrder_id': _salesOrderId,
          'date': _dateController.text,
          'deliveryID': int.parse(_selectedDeliveryId!),
          'supplier': supplierName,
          'loadtype': loadType, // Include loadType here
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hauling Advice saved successfully')));
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e.toString().contains('duplicate key')) {
        errorMessage =
            'Error: This Hauling Advice ID already exists. Please use a unique ID.';
      } else if (e.toString().contains('23505')) {
        errorMessage =
            'Error: Duplicate entry detected for the Hauling Advice. Please check your input.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    _haulingAdviceNumController.dispose();
    _customerNameController.dispose();
    _pickUpAddController.dispose();
    _deliveryAddController.dispose();
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
    _fetchSalesOrderLoad();
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

  bool _showHaulingAdviceList = false;

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
                  child: SingleChildScrollView(
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

                                _fetchHaulingAdvices();
                              });
                            }, 'loadtype'),
                            DropdownButton<String>(
                              value: _selectedDeliveryId,
                              onChanged: (value) {
                                _onDeliverySelected(value);
                                _fetchHaulingAdvices();
                                buildHaulingAdviceList();
                              },
                              items: _deliveryData.map((delivery) {
                                final displayText =
                                    '${delivery['salesOrder_id']} - ${delivery['custName']} - ${delivery['pickUpAdd']} - ${delivery['deliveryAdd']}';
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      labelText: 'Date',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
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
                                textField(_deliveryAddController,
                                    'Delivery Address', context),
                                textField(_volumeDeliveredController,
                                    'Volume Delivered', context,
                                    enabled: true, width: .115),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
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
                                  onPressed: () {
                                    setState(() {
                                      _showHaulingAdviceList =
                                          !_showHaulingAdviceList;
                                      if (_showHaulingAdviceList) {
                                        _fetchHaulingAdvices();
                                        print(_haulingAdviceList);
                                      }
                                    });
                                  },
                                  child: const Text(
                                    'View Hauling Advices',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 25),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    padding: const EdgeInsets.all(15.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _fetchHaulingAdvices();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.replay,
                                    color: Colors.white,
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
                                    child: dropDown('Supplier', _suppliers,
                                        _selectedSupplier,
                                        (Map<String, dynamic>? newValue) {
                                  setState(() {
                                    _selectedSupplier = newValue;
                                  });
                                }, 'companyName'))
                              ],
                            ),
                            if (_showHaulingAdviceList)
                              buildHaulingAdviceList(),
                          ],
                        ),
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

  Widget buildHaulingAdviceList() {
    return _haulingAdviceList.isNotEmpty
        ? Table(
            border: TableBorder.all(color: Colors.white30),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Colors.redAccent),
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Hauling Advice ID',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child:
                          Text('Date', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Plate Number',
                            style: TextStyle(color: Colors.white)),
                      )),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Driver',
                            style: TextStyle(color: Colors.white)),
                      )),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Customer',
                            style: TextStyle(color: Colors.white)),
                      )),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Load Type',
                            style: TextStyle(color: Colors.white)),
                      )),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Volume Delivered',
                            style: TextStyle(color: Colors.white)),
                      )),
                ],
              ),
              ..._haulingAdviceList.asMap().entries.map((entry) {
                int index = entry.key;
                var haulingAdvice = entry.value;
                return TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${haulingAdvice['haulingAdviceId'] ?? 'N/A'}',
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          haulingAdvice['date'] ?? 'N/A',
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          haulingAdvice['plateNumber'] ?? 'N/A',
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          haulingAdvice['fullName'] ?? 'N/A',
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          haulingAdvice['customer'] ?? 'N/A',
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          haulingAdvice['loadtype']?.toString() ?? 'N/A',
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          haulingAdvice['volumeDel']?.toString() ?? 'N/A',
                        ),
                      ),
                    ),
                  ],
                );
              })
            ],
          )
        : const Text('No Hauling Advice data available');
  }
}

// ListView.builder(
//             shrinkWrap: true,
//             itemCount: _haulingAdviceList.length,
//             itemBuilder: (ctx, index) {
//               final advice = _haulingAdviceList[index];

//               return Card(
//                 child: ListTile(
//                   title: Text('Hauling Advice #${advice['haulingAdviceId']}'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Date: ${advice['date']}'),
//                       Text('Truck: ${advice['plateNumber']}'),
//                       Text(
//                           'Driver: ${advice['lastName']}, ${advice['firstName']}'),
//                       Text('Customer: ${advice['customer']}'),
//                       Text('Load Type: ${advice['loadtype']}'),
//                       Text('Volume Delivered: ${advice['volumeDel']}'),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit, color: Colors.blue),
//                         onPressed: () {
//                           _editHaulingAdvice(index); // Call the edit function
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           _deleteHaulingAdvice(
//                               index); // Call the delete function
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           )