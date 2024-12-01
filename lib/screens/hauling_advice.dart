import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_item.dart';
import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/components/textfield.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/screens/profiling.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HaulingAdvice extends StatefulWidget {
  static const routeName = '/HaulingAdvice';
  const HaulingAdvice({super.key});

  @override
  State<HaulingAdvice> createState() => _HaulingAdviceState();
}

class _HaulingAdviceState extends State<HaulingAdvice> {
  int _currentIndex = 1;
  bool _isBarTopVisible = true;
  void toggleBarTop() {
    setState(() {
      _isBarTopVisible = !_isBarTopVisible;
    });
  }

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
  final _deliveredAndTotalController = TextEditingController();

// Drop Down Variables
  String? _salesOrderId;
  String? _supplierId;
  int driversID = 0;
  int truckID = 0;
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
  List<Map<String, dynamic>> _helpers = [];
  Map<String, dynamic>? _selectedHelper;
  List<Map<String, dynamic>> _supplierAdd = [];
  Map<String, dynamic>? _selectedSupplierAdd;

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
    if (_salesOrderId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('salesOrderLoad')
          .select('*, typeofload!inner(*), supplier!inner(*)')
          .eq('salesOrder_id', _salesOrderId!);

      if (response.isNotEmpty) {
        setState(() {
          _loadList = response.map<Map<String, dynamic>>((loadlist) {
            return {
              'id': loadlist['id'].toString(),
              'loadtype': loadlist['typeofload']['loadtype'],
              'loadID': loadlist['loadID'],
              'totalVolume': loadlist['totalVolume'],
              'volumeDel': loadlist['volumeDel'],
              'supplierID': loadlist['supplier']['supplierID'],
              'supplierName': loadlist['supplier']['companyName'],
            };
          }).toList();

          if (_loadList.isNotEmpty) {
            _selectedLoad = _loadList.first;
            _updateDeliveredAndTotalVolume();
          }
        });
      }
    } catch (e) {
      print('Error Sales Order Load: $e');
    }
  }

  void _updateDeliveredAndTotalVolume() {
    if (_selectedLoad != null) {
      final totalVolume = _selectedLoad!['totalVolume'] ?? 0;
      final volumeDelivered = _selectedLoad!['volumeDel'] ?? 0;

      _deliveredAndTotalController.text = '$volumeDelivered / $totalVolume';
    } else {
      _deliveredAndTotalController.text = '0 / 0';
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
                  'addressLine': supplier['addressLine'],
                })
            .toList();
        if (_suppliers.isNotEmpty) {
          _selectedSupplier = _suppliers.first;
          supplierID = _selectedSupplier?['supplierID'];
          setState(() {});
        }
      });
    }
  }

  Future<void> _fetchSupplierAdd() async {
    final response = await Supabase.instance.client
        .from('supplierAddress')
        .select('pickUpAdd')
        .eq('supplierID', _selectedSupplier?['supplierID']);
    setState(() {
      _supplierAdd = response
          .map<Map<String, dynamic>>((supplierAdd) => {
                'supplierID': supplierAdd['supplierID'],
                'pickUpAdd': supplierAdd['pickUpAdd'],
              })
          .toList();

      if (_supplierAdd.isNotEmpty) {
        _selectedSupplierAdd = _supplierAdd.first;
      }
    });
  }

  Future<void> _fetchEmployeeData() async {
    if (_selectedTruck == null) return;
    try {
      final response = await Supabase.instance.client
          .from('employee')
          .select(
              'employeeID, lastName, firstName, isActive') // Include isActive
          .eq('truckID', truckID)
          .eq('positionID', 3);

      if (mounted) {
        setState(() {
          // Filter out inactive employees
          _employees = response
              .where((employee) =>
                  employee['isActive'] == true) // Only active employees
              .map<Map<String, dynamic>>((employee) => {
                    'employeeID': employee['employeeID'],
                    'fullName':
                        '${employee['lastName']}, ${employee['firstName']}',
                  })
              .toList();

          if (_employees.isNotEmpty) {
            _selectedEmployee = _employees.first;
            driversID = _selectedEmployee?['employeeID'];
          } else {
            _selectedEmployee = null;
          }
        });
      }
    } catch (e) {
      print('Error fetching employee data: $e');
    }
  }

  Future<void> _fetchTruckData() async {
    try {
      // Fetch trucks along with their drivers
      final response = await Supabase.instance.client
          .from('Truck')
          .select('truckID, plateNumber, employee!inner(employeeID)')
          .eq('isRepair', false);

      if (!mounted) return;

      setState(() {
        _trucks = response
            .where((truck) =>
                truck['employee'] != null &&
                (truck['employee'] as List).isNotEmpty)
            .map<Map<String, dynamic>>((truck) => {
                  'truckID': truck['truckID'],
                  'plateNumber': truck['plateNumber'],
                })
            .toList();

        if (_trucks.isNotEmpty) {
          _selectedTruck = _trucks.first;
        } else {
          _selectedTruck = null;
        }
      });
    } catch (e) {
      print('Error fetching truck data: $e');
    }
  }

  Future<void> fetchHelperData() async {
    final response = await Supabase.instance.client
        .from('employee')
        .select('employeeID, lastName, firstName')
        .eq('positionID', 4);
    if (mounted) {
      setState(() {
        _helpers = response
            .map<Map<String, dynamic>>((employee) => {
                  'employeeID': employee['employeeID'],
                  'fullName':
                      '${employee['lastName']}, ${employee['firstName']}',
                })
            .toList();
        if (_helpers.isNotEmpty) {
          _selectedHelper = _helpers.first;
        }
      });
    }
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
              '*, Truck!inner(plateNumber), driver:employee!haulingAdvice_driverID_fkey(firstName, lastName), helper:employee!haulingAdvice_helperID_fkey(firstName, lastName), salesOrder!inner(custName, deliveryAdd)')
          .eq('salesOrder_id', _salesOrderId as Object);

      if (mounted) {
        setState(() {
          _haulingAdviceList = response
              .map<Map<String, dynamic>>((advice) => {
                    'haulingAdviceId': advice['haulingAdviceId'],
                    'volumeDel': advice['volumeDel'],
                    'date': advice['date'],
                    'truckID': advice['truckID'] ?? "Truck not specified",
                    'driverName':
                        '${advice['driver']['firstName']} ${advice['driver']['lastName']}',
                    'helperName':
                        '${advice['helper']['firstName']} ${advice['helper']['lastName']}',
                    'plateNumber': advice['Truck']['plateNumber'] ?? "Unknown",
                    'customer': advice['salesOrder']['custName'] ?? "Unknown",
                    'supplier': advice['supplier'],
                    'deliveryAdd':
                        advice['salesOrder']['deliveryAdd'] ?? "Unknown",
                    'loadtype': advice['loadtype'],
                    'pickUpAdd': advice['pickUpAdd'],
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching Hauling Advices: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching Hauling Advices: ${e.toString()}'),
      ));
    }
  }

  void _updateSuppliersDropdown() {
    if (_selectedLoad != null) {
      // Get the supplier ID from the selected load
      final selectedSupplierID = _selectedLoad!['supplierID'];

      // Log the current suppliers
      print('Current Suppliers: $_suppliers');

      // Check if the selected supplier exists in the current suppliers list
      bool supplierExists = _suppliers.any((supplier) =>
          supplier['supplierID'].toString() == selectedSupplierID.toString());

      // If the supplier exists, set it as the selected supplier
      if (supplierExists) {
        _selectedSupplier = _suppliers.firstWhere(
          (supplier) =>
              supplier['supplierID'].toString() ==
              selectedSupplierID.toString(),
          orElse: () => _suppliers.first,
        );
      } else {
        // If the supplier does not exist, set selectedSupplier to null
        _selectedSupplier = null;
      }

      // Log the selected supplier
      print('Selected Supplier: $_selectedSupplier');

      // Update the state to reflect the changes
      setState(() {
        // No need to filter suppliers; we keep all suppliers
        supplierID = _selectedSupplier?['supplierID'];
      });
    }
  }

  Future<void> _createDataHA() async {
    // Data Validation
    if (_selectedDeliveryId == null ||
        _selectedEmployee == null ||
        _selectedTruck == null ||
        _salesOrderId == null ||
        _selectedHelper == null) {
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

    int? volumeDel = int.tryParse(_volumeDeliveredController.text);

    if (volumeDel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please insert a number for the volume delivered'),
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
    final helperID = _selectedHelper!['employeeID'];
    final volumeDelivered = int.tryParse(_volumeDeliveredController.text) ?? 0;
    final supplierName = _selectedSupplier!['companyName'];
    final loadID = _selectedLoad!['loadID'];

    try {
      // Check for existing placeholder hauling advice entries
      final placeholders = await Supabase.instance.client
          .from('haulingAdvice')
          .select('haulingAdviceId')
          .eq('salesOrder_id', _salesOrderId as Object)
          .eq('isPlaceHolder', true);

      // Delete placeholder entries if they exist
      if (placeholders.isNotEmpty) {
        await Supabase.instance.client
            .from('haulingAdvice')
            .delete()
            .eq('salesOrder_id', _salesOrderId as Object)
            .eq('isPlaceHolder', true);
      }

      // Insert the new actual hauling advice record
      await Supabase.instance.client.from('haulingAdvice').insert({
        'haulingAdviceId': _haulingAdviceNumController.text,
        'truckID': truckID,
        'driverID': employeeID,
        'helperID': helperID,
        'volumeDel': volumeDelivered,
        'salesOrder_id': _salesOrderId,
        'date': _dateController.text,
        'deliveryID': int.parse(_selectedDeliveryId!),
        'supplier': supplierName,
        'pickUpAdd': _selectedSupplierAdd?['pickUpAdd'],
        'loadtype': _selectedLoad?['loadtype'],
        'salesOrderLoadID': loadID, // Update salesOrderLoadID
      });
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
      // Proceed with your state update and success message
      setState(() {
        _haulingAdviceList.add({
          'haulingAdviceId': _haulingAdviceNumController.text,
          'truckID': truckID,
          'volumeDel': volumeDelivered,
          'helperID': helperID,
          'salesOrder_id': _salesOrderId,
          'date': _dateController.text,
          'deliveryID': int.parse(_selectedDeliveryId!),
          'supplier': supplierName,
          'pickUpAdd': _pickUpAddController.text,
          'loadtype': loadController.text,
        });
      });
      await Supabase.instance.client
          .from('salesOrderLoad')
          .update({'volumeDel': updatedVolumeDelivered})
          .eq('salesOrder_id', _salesOrderId!)
          .eq('loadID', loadID);

      setState(() {
        _haulingAdviceList.add({
          'haulingAdviceId': _haulingAdviceNumController.text,
          'deliveryID': int.parse(_selectedDeliveryId!),
          'supplier': supplierName,
          'pickUpAdd': _pickUpAddController.text,
          'loadtype': loadType,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hauling Advice saved successfully')));
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      print(e);
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

  List<CollapsibleItem> get _generateItems {
    return [
      CollapsibleItem(
        text: 'Dashboard',
        icon: Icons.dashboard_rounded,
        onPressed: () {
          setState(() => _currentIndex = 0); // Set index to Dashboard
        },
        isSelected: _currentIndex == 0,
      ),
      CollapsibleItem(
        text: 'Booking',
        icon: Icons.book_rounded,
        onPressed: () {
          setState(() => _currentIndex = 1);
          // Set index to New Order
        },
        isSelected: _currentIndex == 1,
      ),
      CollapsibleItem(
        text: 'Hauling Advice',
        icon: Icons.receipt_rounded,
        onPressed: () {
          setState(() => _currentIndex = 2); // Set index to Hauling Advice
        },
        isSelected: _currentIndex == 2,
      ),
      CollapsibleItem(
        text: 'Monitoring',
        icon: Icons.monitor_rounded,
        onPressed: () {
          setState(() => _currentIndex = 3); // Set index to Monitoring
        },
      ),
      CollapsibleItem(
        text: 'Profiling',
        icon: Icons.person_2_rounded,
        onPressed: () {
          setState(() => _currentIndex = 4); // Set index to Profiling
        },
      ),
      CollapsibleItem(
        text: 'Management',
        icon: Icons.price_change_rounded,
        onPressed: () {
          setState(() => _currentIndex = 5); // Set index to Management
        },
      ),
      CollapsibleItem(
        text: 'Logout',
        icon: Icons.eco,
        onPressed: () {
          // Handle logout
          supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        },
      ),
    ];
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

  Future<void> initializeData() async {
    await _fetchTruckData();
    await _fetchEmployeeData();
    await fetchHelperData();
    await _fetchDeliveryData();
    await _fetchSupplierInfo();
    _updateSuppliersDropdown();
    await _fetchSupplierAdd();
  }

  @override
  void initState() {
    super.initState();
    initializeData();
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

    return LayoutBuilderPage(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      page: haulingAdvice(screenWidth, screenHeight, context),
      label: "Hauling Advice",
    );
  }

  SizedBox haulingAdvice(
      double screenWidth, double screenHeight, BuildContext context) {
    return SizedBox(
      width: screenWidth,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: _selectedDeliveryId,
                        onChanged: (value) {
                          _onDeliverySelected(value);
                          _fetchHaulingAdvices();
                          buildHaulingAdviceList();
                          _updateDeliveredAndTotalVolume();
                        },
                        items: _deliveryData.map((delivery) {
                          final displayText =
                              '${delivery['salesOrder_id']} - ${delivery['custName']} - ${delivery['deliveryAdd']}';
                          return DropdownMenuItem<String>(
                            value: delivery['deliveryid'],
                            child: Text(displayText),
                          );
                        }).toList(),
                        hint: const Text('Select Delivery ID'),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: screenWidth * 0.1,
                        child: dropDown(
                          'Load List:',
                          _loadList,
                          _selectedLoad,
                          (Map<String, dynamic>? newValue) {
                            setState(() {
                              _selectedLoad = newValue;

                              // Update delivered and total volume
                              _updateDeliveredAndTotalVolume();

                              // Fetch hauling advice specific to the selected load
                              _fetchHaulingAdvices();

                              // Update suppliers based on the selected load type
                              _updateSuppliersDropdown();

                              // Automatically select the relevant supplier for the chosen load
                              if (_selectedLoad != null) {
                                final String selectedSupplierID =
                                    _selectedLoad!['supplierID'].toString();

                                // Find the supplier in the list of all suppliers
                                _selectedSupplier = _suppliers.firstWhere(
                                  (supplier) =>
                                      supplier['supplierID'].toString() ==
                                      selectedSupplierID,
                                  orElse: () => _suppliers
                                      .first, // Allow null if not found
                                );
                              } else {
                                _selectedSupplier =
                                    null; // Reset if no load is selected
                              }
                            });
                          },
                          'loadtype', // The key used for the dropdown label
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Supplier Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: SizedBox(
                            width: 200,
                            child: dropDown(
                              'Supplier',
                              _suppliers,
                              _selectedSupplier,
                              (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedSupplier = newValue;
                                  _fetchSupplierAdd();
                                });
                              },
                              'companyName',
                            ),
                          )),
                          const SizedBox(width: 25),
                          Flexible(
                            child: SizedBox(
                              width: 200,
                              child: dropDown(
                                  'Plate Number:', _trucks, _selectedTruck,
                                  (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedTruck = newValue;
                                  truckID = newValue?['truckID'];
                                });
                                _fetchEmployeeData();
                              }, 'plateNumber'),
                            ),
                          ),
                          const SizedBox(width: 25),
                          Flexible(
                            child: SizedBox(
                              width: 200,
                              child: dropDown(
                                'Truck Driver Assigned:',
                                _employees,
                                _selectedEmployee,
                                (Map<String, dynamic>? newValue) {
                                  setState(() {
                                    _selectedEmployee = newValue;
                                  });
                                },
                                'fullName',
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                          Flexible(
                              child:
                                  dropDown('Helper', _helpers, _selectedHelper,
                                      (Map<String, dynamic>? newValue) {
                            setState(() {
                              _selectedHelper = newValue;
                            });
                          }, 'fullName')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 500,
                              child: textField(_haulingAdviceNumController,
                                  'Hauling Advice #', context,
                                  enabled: true),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            child: SizedBox(
                              width: screenWidth * .15,
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 500,
                              child: dropDown('Pick Up Address', _supplierAdd,
                                  _selectedSupplierAdd,
                                  (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedSupplierAdd = newValue;
                                });
                              }, 'pickUpAdd'),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            child: SizedBox(
                              width: screenWidth * .15,
                              child: textField(_volumeDeliveredController,
                                  'Volume Delivered', context,
                                  enabled: true, width: .115),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            child: SizedBox(
                              width: screenWidth * .15,
                              child: textField(_deliveredAndTotalController,
                                  'Delivered / Total Volume', context,
                                  enabled: false, width: .115),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                padding: const EdgeInsets.all(15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _createDataHA();
                                _updateDeliveredAndTotalVolume();
                                _fetchHaulingAdvices();
                              },
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: ElevatedButton(
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
                          ),
                          const SizedBox(width: 25),
                          Flexible(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                padding: const EdgeInsets.all(15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _fetchHaulingAdvices();
                                _updateDeliveredAndTotalVolume();
                              },
                              child: const Icon(
                                Icons.replay,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      if (_showHaulingAdviceList) buildHaulingAdviceList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
    String dbItem,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButton<Map<String, dynamic>>(
            hint: const Text('Select an item',
                style: TextStyle(color: Colors.grey)),
            value: selectedItem,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<Map<String, dynamic>>>(
              (Map<String, dynamic> value) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: value,
                  child: Text(
                    value[dbItem] ?? '',
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              },
            ).toList(),
            dropdownColor: Colors.white,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            underline: const SizedBox(), // Remove underline
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget buildHaulingAdviceList() {
    return _haulingAdviceList.isNotEmpty
        ? Table(
            border: TableBorder.all(color: Colors.black),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Colors.orangeAccent),
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
                        child: Text('Helper',
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
                        child: Text('Supplier',
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
                        child: Text('Delivery Address',
                            style: TextStyle(color: Colors.white)),
                      )),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Pick-up Address',
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
                          haulingAdvice['driverName'] ?? 'N/A',
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          haulingAdvice['helperName'] ?? 'N/A',
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
                          haulingAdvice['supplier'] ?? 'N/A',
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
                          haulingAdvice['deliveryAdd'] ?? 'N/A',
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          haulingAdvice['pickUpAdd'] ?? 'N/A',
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
