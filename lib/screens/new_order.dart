import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/data_service.dart';
import 'package:maviken/functions.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';

final TextEditingController id = TextEditingController();
final TextEditingController custNameController = TextEditingController();
final TextEditingController dateController = TextEditingController();
final TextEditingController addressController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
final TextEditingController volumeController = TextEditingController();
final TextEditingController priceController = TextEditingController();
final TextEditingController quantityController = TextEditingController();

class NewOrder extends StatefulWidget {
  static const routeName = '/NewOrder';

  const NewOrder({super.key});

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final DataService dataService = DataService();

  Future<void> handleCreateOrderAndDelivery() async {
    await dataService.createSADELHA(
      custName: custNameController.text,
      date: dateController.text,
      address: addressController.text,
      typeofload: descriptionController.text,
      totalVolume: int.tryParse(volumeController.text) ?? 0,
      price: int.tryParse(priceController.text) ?? 0,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
              Container(
                color: Colors.red,
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(150),
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
                  child: Row(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: screenWidth * .5,
                            height: screenHeight * .1,
                            child: TextField(
                              style: const TextStyle(color: Colors.black),
                              controller: custNameController,
                              decoration: const InputDecoration(
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
                            width: screenWidth * .5,
                            height: screenHeight * .1,
                            child: TextField(
                              style: const TextStyle(color: Colors.black),
                              controller: addressController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                labelText: 'Site/Address',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: screenWidth * .35,
                                height: screenHeight * .1,
                                child: TextField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: descriptionController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                    labelText: 'Type of Load',
                                    labelStyle: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: screenWidth * .15,
                                height: screenHeight * .1,
                                child: TextField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: dateController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                    labelText: 'Date',
                                    labelStyle: TextStyle(color: Colors.black),
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
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
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: screenWidth * .08,
                            height: screenHeight * .1,
                            child: TextField(
                              style: const TextStyle(color: Colors.black),
                              controller: volumeController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                labelText: 'Cubic Metre',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * .08,
                            height: screenHeight * .1,
                            child: TextField(
                              style: const TextStyle(color: Colors.black),
                              controller: priceController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                labelText: 'Price',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Color.fromARGB(255, 111, 90, 53),
                              ),
                            ),
                            onPressed: () async {
                              await handleCreateOrderAndDelivery();
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
                        ],
                      ),
                    ],
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
