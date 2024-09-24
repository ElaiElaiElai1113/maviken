import 'package:auto_size_text/auto_size_text.dart';
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
final TextEditingController priceController = TextEditingController();
final TextEditingController volumeController = TextEditingController();
final TextEditingController quantityController = TextEditingController();

List<Map<String, dynamic>> _typeofload = [];
Map<String, dynamic>? _selectedLoad;

List<Map<String, dynamic>> selectedLoads = [];

class NewOrder extends StatefulWidget {
  static const routeName = '/NewOrder';

  const NewOrder({super.key});

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final DataService dataService = DataService();

  Future<void> handleCreateOrderAndDelivery() async {
    for (var load in selectedLoads) {
      await dataService.createSADELHA(
        custName: custNameController.text.isNotEmpty
            ? custNameController.text
            : 'Unknown',
        date: dateController.text.isNotEmpty
            ? dateController.text
            : DateTime.now().toString().split(' ')[0],
        address: addressController.text.isNotEmpty
            ? addressController.text
            : 'No address provided',
        typeofload: load['typeofload']?.toString() ?? 'No load selected',
        totalVolume: int.tryParse(load['volume']) ?? 0,
        price: int.tryParse(load['price']) ?? 0,
      );
    }
  }

  Future<void> _fetchLoad() async {
    final response =
        await Supabase.instance.client.from('typeofload').select('*');
    setState(() {
      _typeofload = response
          .map<Map<String, dynamic>>((typeofload) => {
                'loadID': typeofload['loadID'],
                'typeofload': typeofload['loadtype'],
              })
          .toList();
      if (_typeofload.isNotEmpty) {
        _selectedLoad = _typeofload.first;
      }
    });
  }

  void _addLoadEntry() {
    setState(() {
      selectedLoads.add({
        'typeofload': _selectedLoad?['typeofload'] ?? '',
        'volume': volumeController.text,
        'price': priceController.text,
      });

      quantityController.clear();
      priceController.clear();
    });
  }

  void _removeLoadEntry(int index) {
    setState(() {
      selectedLoads.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchLoad();
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
              Expanded(
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
                      children: [
                        Row(
                          children: [
                            Flexible(
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
                            const SizedBox(width: 20),
                            Flexible(
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
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        TextField(
                          style: const TextStyle(color: Colors.black),
                          controller: addressController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            labelText: 'Site/Address',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.orangeAccent,
                          ),
                          onPressed: _addLoadEntry,
                          child: const Text('Add Load',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: selectedLoads.length,
                            itemBuilder: (context, index) {
                              final load = selectedLoads[index];
                              return ListTile(
                                title: Text(
                                    'Load: ${load['typeofload']}, Volume: ${load['volume']}, Price: ${load['price']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeLoadEntry(index),
                                ),
                              );
                            },
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            padding: const EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: handleCreateOrderAndDelivery,
                          child: const AutoSizeText(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}
