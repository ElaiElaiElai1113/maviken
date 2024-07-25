import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController haulingAdviceNum = TextEditingController();
final TextEditingController hcustomerName = TextEditingController();
final TextEditingController haddress = TextEditingController();
final TextEditingController htypeofload = TextEditingController();
final TextEditingController hplatenumber = TextEditingController();
final TextEditingController hdate = TextEditingController();
final TextEditingController hquantity = TextEditingController();

class HaulingAdvice extends StatefulWidget {
  static const routeName = '/HaulingAdvice';
  const HaulingAdvice({super.key});

  @override
  State<HaulingAdvice> createState() => _HaulingAdviceState();
}

class _HaulingAdviceState extends State<HaulingAdvice> {
  List<Map<String, dynamic>> orders = [];
  List<String> data = [];
  String? _selectedValue;
  List<String> edata = [];
  String? _eselectedValue;

  Future<void> fetchEmployeeData() async {
    final eresponse = await supabase.from('employee').select(
          'employeeID, lastName, firstName',
        );
    setState(() {
      edata = eresponse
          .map<String>((employee) =>
              '${employee['lastName']} - (${employee['employeeID']})')
          .toList();
      if (edata.isNotEmpty) {
        _eselectedValue = edata.first;
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
        fetchInfo();
      }
    });
  }

  Future<void> fetchInfo() async {
    if (_selectedValue == null) return;

    final response = await supabase
        .from('salesOrder')
        .select(
            'custName, address, date, typeofload, haulingAdvice!inner(deliveryID)')
        .eq('haulingAdvice.deliveryID', _selectedValue as String);

    print('fetchInfo response for deliveryID $_selectedValue: $response');

    setState(() {
      if (response.isNotEmpty) {
        final order = response.first;
        hcustomerName.text = order['custName'] ?? '';
        haddress.text = order['address'] ?? '';
        hdate.text = order['date'] ?? '';
        htypeofload.text = order['typeofload'] ?? '';
        hquantity.text = order['quantity'].toString() ?? '';

        // hplatenumber.text = order['platenumber'] ?? '';
      } else {
        hcustomerName.clear();
        haddress.clear();
        hdate.clear();
        htypeofload.clear();
        hquantity.clear();
        hplatenumber.clear();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchEmployeeData();
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
                        print(
                            'Selected deliveryID: $_selectedValue'); // Debugging
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
                          controller: hquantity,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Quantity',
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
                        child: TextField(
                          controller: hplatenumber,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFCF7E6),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Plate Number',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
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
                              backgroundColor: MaterialStatePropertyAll(
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
                  DropdownButton<String>(
                    hint: const Text('Select an employee'),
                    value: _eselectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _eselectedValue = newValue;
                        print('Selected employee: $_eselectedValue');
                      });
                    },
                    items: edata.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
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

    final employeeID = int.tryParse(
      _eselectedValue!.substring(
          _eselectedValue!.indexOf('(') + 1, _eselectedValue!.indexOf(')')),
    );
    if (employeeID == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid Employee Selection'),
      ));
      return;
    }

    final response = await supabase.from('haulingAdvice').insert({
      'deliveryID': _selectedValue,
      'date': hdate.text,
      'customerName': hcustomerName.text,
      'address': haddress.text,
      'typeofload': htypeofload.text,
      'platenumber': hplatenumber.text,
      'employeeID': employeeID,
      'quantity': hquantity.text,
    });
    print('createDataHA response: $response');
    if (response.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Hauling Advice saved successfully'),
      ));
      // Reset the form after successful submission
      hcustomerName.clear();
      haddress.clear();
      hdate.clear();
      htypeofload.clear();
      hquantity.clear();
      hplatenumber.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to save Hauling Advice'),
      ));
    }
  }
}
