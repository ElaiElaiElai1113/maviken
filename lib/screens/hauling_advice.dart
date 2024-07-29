import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/main.dart';

class HaulingAdvice extends StatefulWidget {
  static const routeName = '/HaulingAdvice';
  const HaulingAdvice({super.key});

  @override
  State<HaulingAdvice> createState() => _HaulingAdviceState();
}

class _HaulingAdviceState extends State<HaulingAdvice> {
  final TextEditingController haulingAdviceNum = TextEditingController();
  final TextEditingController hcustomerName = TextEditingController();
  final TextEditingController haddress = TextEditingController();
  final TextEditingController htypeofload = TextEditingController();
  final TextEditingController hplatenumber = TextEditingController();
  final TextEditingController hdate = TextEditingController();
  final TextEditingController hvolumeDel = TextEditingController();
  final TextEditingController htotalVolume = TextEditingController();

  String? salesOrderId;
  List<String> deliveryIds = [];
  String? selectedDeliveryId;
  List<Map<String, dynamic>> employees = [];
  Map<String, dynamic>? selectedEmployee;
  List<Map<String, dynamic>> trucks = [];
  Map<String, dynamic>? selectedTruck;

  @override
  void initState() {
    super.initState();
    fetchDeliveryData();
    fetchEmployeeData();
    fetchTruckData();
  }

  Future<void> fetchDeliveryData() async {
    final response = await supabase.from('delivery').select('deliveryid');
    setState(() {
      deliveryIds = response
          .map<String>((delivery) => delivery['deliveryid'].toString())
          .toList();
      if (deliveryIds.isNotEmpty) {
        selectedDeliveryId = deliveryIds.first;
        fetchSalesOrderInfo();
      }
    });
  }

  Future<void> fetchEmployeeData() async {
    final response = await supabase
        .from('employee')
        .select('employeeID, lastName, firstName')
        .eq('positionID', 3);
    setState(() {
      employees = response
          .map<Map<String, dynamic>>((employee) => {
                'employeeID': employee['employeeID'],
                'fullName': '${employee['lastName']}, ${employee['firstName']}',
              })
          .toList();
      if (employees.isNotEmpty) {
        selectedEmployee = employees.first;
      }
    });
  }

  Future<void> fetchTruckData() async {
    final response =
        await supabase.from('Truck').select('truckID, plateNumber');
    setState(() {
      trucks = response
          .map<Map<String, dynamic>>((truck) => {
                'truckID': truck['truckID'],
                'plateNumber': truck['plateNumber'],
              })
          .toList();
      if (trucks.isNotEmpty) {
        selectedTruck = trucks.first;
      }
    });
  }

  Future<void> fetchSalesOrderInfo() async {
    if (selectedDeliveryId == null) return;

    final response = await supabase
        .from('salesOrder')
        .select(
            'salesOrder_id, custName, address, date, typeofload, volumeDel, haulingAdvice!inner(deliveryID)')
        .eq('haulingAdvice.deliveryID', selectedDeliveryId as String);

    setState(() {
      if (response.isNotEmpty) {
        final order = response.first;
        salesOrderId = order['salesOrder_id']?.toString();
        hcustomerName.text = order['custName'] ?? '';
        haddress.text = order['address'] ?? '';
        hdate.text = order['date'] ?? '';
        htypeofload.text = order['typeofload'] ?? '';
      } else {
        hcustomerName.clear();
        haddress.clear();
        hdate.clear();
        htypeofload.clear();
        hvolumeDel.clear();
        hplatenumber.clear();
      }
    });
  }

  Future<void> createDataHA() async {
    if (selectedDeliveryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Delivery ID')));
      return;
    }
    if (selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an Employee')));
      return;
    }
    if (selectedTruck == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a Truck')));
      return;
    }

    final truckID = selectedTruck!['truckID'];
    final employeeID = selectedEmployee!['employeeID'];
    final volumeDelivered = int.tryParse(hvolumeDel.text) ?? 0;

    try {
      await supabase.from('haulingAdvice').insert({
        'haulingAdviceId': int.tryParse(haulingAdviceNum.text),
        'truckID': truckID,
        'driverID': employeeID,
        'volumeDel': volumeDelivered,
        'salesOrder_id': salesOrderId,
        'deliveryID': int.parse(selectedDeliveryId!),
      });

      final currentSalesOrder = await supabase
          .from('salesOrder')
          .select('volumeDel')
          .eq('salesOrder_id', salesOrderId as Object);
      final currentVolumeDelivered = currentSalesOrder.isNotEmpty
          ? currentSalesOrder.first['volumeDel']
          : 0;
      final updatedVolumeDelivered =
          (currentVolumeDelivered as int) + volumeDelivered;

      await supabase
          .from('salesOrder')
          .update({'volumeDel': updatedVolumeDelivered}).eq(
              'salesOrder_id', salesOrderId!);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hauling Advice saved successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      print('Error in createDataHA: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const BarTop(),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: const Color(0xFFFCF7E6),
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 150),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 236, 223, 196),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: screenWidth * .3,
                    height: screenHeight * .1,
                    child: const Text(
                      'Delivery ID',
                      style: TextStyle(fontSize: 52),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DropdownButton<String>(
                    hint: const Text('Select an item'),
                    value: selectedDeliveryId,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDeliveryId = newValue;
                        fetchSalesOrderInfo();
                      });
                    },
                    items: deliveryIds
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(haulingAdviceNum, 'Hauling Advice #',
                      enabled: true),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTextField(hcustomerName, 'Customer Name'),
                      _buildTextField(hdate, 'Date', width: .15),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTextField(haddress, 'Address'),
                      _buildTextField(hvolumeDel, 'Volume Delivered',
                          enabled: true, width: .115),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildTextField(htypeofload, 'Description', width: .35),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 111, 90, 53),
                          padding: const EdgeInsets.all(10.0),
                        ),
                        onPressed: createDataHA,
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildDropdown(
                          'Truck Driver Assigned:', employees, selectedEmployee,
                          (Map<String, dynamic>? newValue) {
                        setState(() {
                          selectedEmployee = newValue;
                        });
                      }),
                      const SizedBox(width: 50),
                      _buildDropdown('Plate Number:', trucks, selectedTruck,
                          (Map<String, dynamic>? newValue) {
                        setState(() {
                          selectedTruck = newValue;
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool enabled = false, double width = .5}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      height: MediaQuery.of(context).size.height * .1,
      child: TextField(
        enabled: enabled,
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFFCF7E6),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.black),
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
      children: [
        Text(labelText),
        DropdownButton<Map<String, dynamic>>(
          hint: const Text('Select an item'),
          value: selectedItem,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<Map<String, dynamic>>>(
              (Map<String, dynamic> value) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: value,
              child: Text(value['fullName'] ?? value['plateNumber']),
            );
          }).toList(),
        ),
      ],
    );
  }
}
