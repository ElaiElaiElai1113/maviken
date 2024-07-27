import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/main.dart';

final TextEditingController haulingAdviceNum = TextEditingController();

final TextEditingController hcustomerName = TextEditingController();
final TextEditingController haddress = TextEditingController();
final TextEditingController htypeofload = TextEditingController();
final TextEditingController hplatenumber = TextEditingController();
final TextEditingController hdate = TextEditingController();
final TextEditingController hvolumeDel = TextEditingController();
final TextEditingController htotalVolume = TextEditingController();

class HaulingAdvice extends StatefulWidget {
  static const routeName = '/HaulingAdvice';
  const HaulingAdvice({super.key});

  @override
  State<HaulingAdvice> createState() => _HaulingAdviceState();
}

class _HaulingAdviceState extends State<HaulingAdvice> {
  String? salesOrder_id;
  List<Map<String, dynamic>> orders = [];
  List<String> data = [];
  String? _selectedValue;
  List<Map<String, dynamic>> edata = [];
  Map<String, dynamic>? _eselectedValue;
  List<Map<String, dynamic>> pdata = [];
  Map<String, dynamic>? _pselectedValue;

  Future<void> fetchEmployeeData() async {
    final eresponse = await supabase
        .from('employee')
        .select(
          'employeeID, lastName, firstName',
        )
        .eq('positionID', 3);
    setState(() {
      edata = eresponse
          .map<Map<String, dynamic>>((employee) => {
                'employeeID': employee['employeeID'],
                'fullName': '${employee['lastName']}, ${employee['firstName']}',
              })
          .toList();
      if (edata.isNotEmpty) {
        _eselectedValue = edata.first;
      }
    });
  }

  Future<void> fetchPlateNumbers() async {
    final presponse = await supabase.from('Truck').select(
          'truckID, plateNumber',
        );
    setState(() {
      pdata = presponse
          .map<Map<String, dynamic>>((Truck) => {
                'truckID': Truck['truckID'],
                'plateNumber': '${Truck['plateNumber']}',
              })
          .toList();
      if (pdata.isNotEmpty) {
        _pselectedValue = pdata.first;
      }
    });
  }

  Future<void> fetchData() async {
    final response = await supabase.from('delivery').select('deliveryid');
    setState(() {
      data = response
          .map<String>((delivery) => delivery['deliveryid'].toString())
          .toList();
      if (data.isNotEmpty) {
        _selectedValue = data.first;
        if (_selectedValue != null) {
          fetchInfo();
        }
      }
    });
  }

  Future<void> fetchInfo() async {
    if (_selectedValue == null) return;

    final response = await supabase
        .from('salesOrder')
        .select(
            'salesOrder_id, custName, address, date, typeofload, volumeDel, haulingAdvice!inner(deliveryID)')
        .eq('haulingAdvice.deliveryID', _selectedValue as String);

    print('fetchInfo response for deliveryID $_selectedValue: $response');

    setState(() {
      if (response.isNotEmpty) {
        final order = response.first;
        if (order['salesOrder_id'] is int) {
          salesOrder_id = order['salesOrder_id'].toString();
        } else {
          salesOrder_id = null;
        }
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

  @override
  void initState() {
    super.initState();
    fetchData();

    fetchEmployeeData();
    fetchPlateNumbers();
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
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 150, right: 150),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 236, 223, 196),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
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
                    value: _selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedValue = newValue;
                        print('Selected deliveryID: $_selectedValue');
                        fetchInfo();
                      });
                    },
                    items: data.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * .5,
                        height: screenHeight * .1,
                        child: TextField(
                          enabled: false,
                          controller: hcustomerName,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Customer Name',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * .15,
                        height: screenHeight * .1,
                        child: TextField(
                          enabled: false,
                          controller: hdate,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Date',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth * .14,
                    height: screenHeight * .02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: screenWidth * .5,
                        height: screenHeight * .1,
                        child: TextField(
                          enabled: false,
                          controller: haddress,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Address',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * .115,
                        height: screenHeight * .1,
                        child: TextField(
                          controller: hvolumeDel,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Volume Delivered',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth * .14,
                    height: screenHeight * .02,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * .35,
                        height: screenHeight * .1,
                        child: TextField(
                          enabled: false,
                          controller: htypeofload,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: screenWidth * .14,
                        height: screenHeight * .1,
                      ),
                      SizedBox(
                        width: screenWidth * .1,
                        height: screenHeight * .1,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Color.fromARGB(255, 111, 90, 53),
                              ),
                            ),
                            onPressed: () {
                              createDataHA();
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            const Text('Truck Driver Assigned: '),
                            DropdownButton<Map<String, dynamic>>(
                              hint: const Text('Select an employee'),
                              value: _eselectedValue,
                              onChanged: (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _eselectedValue = newValue;
                                  print('Selected employee: $_eselectedValue');
                                });
                              },
                              items: edata
                                  .map<DropdownMenuItem<Map<String, dynamic>>>(
                                      (Map<String, dynamic> value) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: value,
                                  child: Text(value['fullName']),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 50),
                      Container(
                        child: Column(
                          children: [
                            const Text('Plate Number: '),
                            DropdownButton<Map<String, dynamic>>(
                              hint: const Text('Select a truck'),
                              value: _pselectedValue,
                              onChanged: (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _pselectedValue = newValue;
                                  print('Selected employee: $_pselectedValue');
                                });
                              },
                              items: pdata
                                  .map<DropdownMenuItem<Map<String, dynamic>>>(
                                      (Map<String, dynamic> value) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: value,
                                  child: Text(value['plateNumber']),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
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

  Future<void> createDataHA() async {
    if (_selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a Delivery ID'),
      ));
      return;
    }
    if (_eselectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select an Employee'),
      ));
      return;
    }
    if (_pselectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a truck'),
      ));
      return;
    }

    final truckID = _pselectedValue!['truckID'];
    final employeeID = _eselectedValue!['employeeID'];

    if (truckID == null || employeeID == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a valid truck and employee'),
      ));
      return;
    }

    final volumeDel = int.tryParse(hvolumeDel.text) ?? 0;

    try {
      final response = await supabase.from('haulingAdvice').insert({
        'truckID': truckID,
        'driverID': employeeID,
        'volumeDel': volumeDel,
        'salesOrder_id': salesOrder_id,
        'deliveryID': int.parse(_selectedValue!),
      });

      final currentSalesOrder = await supabase
          .from('salesOrder')
          .select('volumeDel')
          .eq('salesOrder_id', salesOrder_id as Object);

      final currentVolumeDel = currentSalesOrder.isNotEmpty
          ? currentSalesOrder.first['volumeDel']
          : 0;

      final updatedVolumeDel = (currentVolumeDel as int) + volumeDel;

      await supabase.from('salesOrder').update({
        'volumeDel': updatedVolumeDel,
      }).eq('salesOrder_id', salesOrder_id!);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Hauling Advice saved successfully'),
      ));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$salesOrder_id-$volumeDel'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
      ));
      print('Error in createDataHA: $e');
    }
  }
}
