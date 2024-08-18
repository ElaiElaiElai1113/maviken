import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/screens/billing_statement.dart';
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

  String? _salesOrderId;
  List<Map<String, dynamic>> _deliveryData = [];
  String? _selectedDeliveryId;
  List<Map<String, dynamic>> _employees = [];
  Map<String, dynamic>? _selectedEmployee;
  List<Map<String, dynamic>> _trucks = [];
  Map<String, dynamic>? _selectedTruck;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryData();
    _fetchEmployeeData();
    _fetchTruckData();
  }

  Future<void> _fetchDeliveryData() async {
    final response = await Supabase.instance.client
        .from('delivery')
        .select('deliveryid, salesOrder!inner(custName, address)');
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

  Future<void> _fetchEmployeeData() async {
    final response = await Supabase.instance.client
        .from('employee')
        .select('employeeID, lastName, firstName')
        .eq('positionID', 3);
    setState(() {
      _employees = response
          .map<Map<String, dynamic>>((employee) => {
                'employeeID': employee['employeeID'],
                'fullName': '${employee['lastName']}, ${employee['firstName']}',
              })
          .toList();
      if (_employees.isNotEmpty) {
        _selectedEmployee = _employees.first;
      }
    });
  }

  Future<void> _fetchTruckData() async {
    final response = await Supabase.instance.client
        .from('Truck')
        .select('truckID, plateNumber');
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
            'salesOrder_id, custName, address, date, typeofload, volumeDel, haulingAdvice!inner(deliveryID)')
        .eq('haulingAdvice.deliveryID', deliveryIdOnly);

    setState(() {
      if (response.isNotEmpty) {
        final order = response.first;
        _salesOrderId = order['salesOrder_id']?.toString();
        _customerNameController.text = order['custName'] ?? '';
        _addressController.text = order['address'] ?? '';
        _typeOfLoadController.text = order['typeofload'] ?? '';
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

    final truckID = _selectedTruck!['truckID'];
    final employeeID = _selectedEmployee!['employeeID'];
    final volumeDelivered = int.tryParse(_volumeDeliveredController.text) ?? 0;

    try {
      await Supabase.instance.client.from('haulingAdvice').insert({
        'haulingAdviceId': _haulingAdviceNumController.text,
        'truckID': truckID,
        'driverID': employeeID,
        'volumeDel': volumeDelivered,
        'salesOrder_id': _salesOrderId,
        'date': _dateController.text,
        'deliveryID': int.parse(_selectedDeliveryId!),
      });

      final currentSalesOrder = await Supabase.instance.client
          .from('salesOrder')
          .select('volumeDel')
          .eq('salesOrder_id', _salesOrderId as Object);
      final currentVolumeDelivered = currentSalesOrder.isNotEmpty
          ? currentSalesOrder.first['volumeDel']
          : 0;
      final updatedVolumeDelivered =
          (currentVolumeDelivered as int) + volumeDelivered;

      await Supabase.instance.client
          .from('salesOrder')
          .update({'volumeDel': updatedVolumeDelivered}).eq(
              'salesOrder_id', _salesOrderId!);

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
              'haulingAdviceId, volumeDel, truckID, date, Truck!inner(plateNumber), salesOrder!inner(typeofload, price)')
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const BarTop(),
      body: SidebarDrawer(
        drawer: const BarTop(),
        body: Container(
          color: Colors.white,
          width: screenWidth,
          height: screenHeight,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                leading: const DrawerIcon(),
                title: const Text("Hauling Advice"),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 50),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: _buildTitle('Input')),
                          const SizedBox(height: 20),
                          DropdownButton<String>(
                            value: _selectedDeliveryId,
                            onChanged: (value) {
                              setState(() {
                                _selectedDeliveryId = value;
                                _fetchSalesOrderInfo();
                              });
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
                          _buildTextField(
                              _haulingAdviceNumController, 'Hauling Advice #',
                              enabled: true),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTextField(
                                  _customerNameController, 'Customer Name'),
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
                                      lastDate: DateTime.now(),
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
                              _buildTextField(_addressController, 'Address'),
                              _buildTextField(_volumeDeliveredController,
                                  'Volume Delivered',
                                  enabled: true, width: .115),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildTextField(
                                  _typeOfLoadController, 'Description',
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
                                child: _buildDropdown('Truck Driver Assigned:',
                                    _employees, _selectedEmployee,
                                    (Map<String, dynamic>? newValue) {
                                  setState(() {
                                    _selectedEmployee = newValue;
                                  });
                                }),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildDropdown(
                                    'Plate Number:', _trucks, _selectedTruck,
                                    (Map<String, dynamic>? newValue) {
                                  setState(() {
                                    _selectedTruck = newValue;
                                  });
                                }),
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildTitle(String text) {
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

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool enabled = false, double width = .5}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      child: TextField(
        enabled: enabled,
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String labelText,
    List<Map<String, dynamic>> items,
    Map<String, dynamic>? selectedItem,
    ValueChanged<Map<String, dynamic>?> onChanged,
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
                value['fullName'] ?? value['plateNumber'],
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
