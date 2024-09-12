import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/data_service.dart';
import 'package:maviken/functions.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController id = TextEditingController();
final TextEditingController custNameController = TextEditingController();
final TextEditingController dateController = TextEditingController();
final TextEditingController addressController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
final TextEditingController volumeController = TextEditingController();
final TextEditingController priceController = TextEditingController();
final TextEditingController quantityController = TextEditingController();

List<Map<String, dynamic>> _typeofload = [];
Map<String, dynamic>? _selectedLoad;

class NewOrder extends StatefulWidget {
  static const routeName = '/NewOrder';

  const NewOrder({super.key});

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final DataService dataService = DataService();
  bool isDropdownDisabled = false;

  Future<void> handleCreateOrderAndDelivery() async {
    await dataService.createSADELHA(
      custName: custNameController.text,
      date: dateController.text,
      address: addressController.text,
      typeofload: _selectedLoad as String,
      totalVolume: int.tryParse(volumeController.text) ?? 0,
      price: int.tryParse(priceController.text) ?? 0,
    );
  }

  Future<void> _fetchLoad() async {
    final response =
        await Supabase.instance.client.from('typeofload').select('*');
    setState(() {
      _typeofload = response
          .map<Map<String, dynamic>>((typeofload) => {
                'loadID': typeofload['loadID'] ?? "",
                'typeofload': typeofload['loadtype'],
              })
          .toList();
      if (_typeofload.isNotEmpty) {
        _selectedLoad = _typeofload.first;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchLoad();

    descriptionController.addListener(() {
      setState(() {
        isDropdownDisabled = descriptionController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    descriptionController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                title: const Text("New Order"),
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
                    child: Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Flexible(
                                      child: TextField(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        controller: custNameController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                          ),
                                          labelText: 'Customer Name',
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Flexible(
                                      child: TextField(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        controller: volumeController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                          ),
                                          labelText: 'Cubic Metre',
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: TextField(
                                    style: const TextStyle(color: Colors.black),
                                    controller: addressController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      labelText: 'Site/Address',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: dropDown(
                                        'Load Type: ',
                                        _typeofload,
                                        _selectedLoad,
                                        (Map<String, dynamic>? newValue) {
                                          setState(() {
                                            _selectedLoad = newValue;
                                          });
                                        },
                                        'typeofload',
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Flexible(
                                      child: TextField(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        controller: dateController,
                                        decoration: const InputDecoration(
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
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2500),
                                          );
                                          if (pickedDate != null) {
                                            dateController.text = pickedDate
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0];
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: SizedBox(
                                    width: screenWidth * .08,
                                    height: screenHeight * .05,
                                    child: ElevatedButton(
                                      style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                          Colors.orangeAccent,
                                        ),
                                      ),
                                      onPressed: () async {
                                        await handleCreateOrderAndDelivery();
                                      },
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}
