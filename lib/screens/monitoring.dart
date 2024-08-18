// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/monitor_card.dart';
import 'package:maviken/main.dart';

class Monitoring extends StatefulWidget {
  static const routeName = '/Monitoring';

  const Monitoring({super.key});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  List<Map<String, dynamic>> orders = [];

  Future<void> fetchData() async {
    try {
      final data = await supabase.from('salesOrder').select('*');
      setState(() {
        orders = List<Map<String, dynamic>>.from(data);
        print('Orders: $orders');
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void editOrder(int index) {
    final order = orders[index];
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController custNameController =
            TextEditingController(text: order['custName']);
        final TextEditingController addressController =
            TextEditingController(text: order['address']);
        final TextEditingController descriptionController =
            TextEditingController(text: order['typeofload']);
        final TextEditingController volumeController =
            TextEditingController(text: order['totalVolume'].toString());
        final TextEditingController priceController =
            TextEditingController(text: order['price'].toString());

        DateTime selectedDate = DateTime.parse(order['date']);
        final TextEditingController dateController = TextEditingController(
            text: selectedDate.toLocal().toString().split(' ')[0]);

        return AlertDialog(
          title: const Text('Edit Order'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: custNameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                        dateController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Type of Load'),
                ),
                TextField(
                  controller: volumeController,
                  decoration: const InputDecoration(labelText: 'Volume'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  final updatedOrder = {
                    'salesOrder_id': order['salesOrder_id'],
                    'custName': custNameController.text,
                    'date': dateController.text,
                    'address': addressController.text,
                    'typeofload': descriptionController.text,
                    'totalVolume': int.parse(volumeController.text),
                    'price': double.parse(priceController.text),
                    'volumeDel': order['volumeDel'],
                  };
                  await supabase
                      .from('salesOrder')
                      .update(updatedOrder)
                      .eq('salesOrder_id', order['salesOrder_id']);
                  setState(() {
                    orders[index] = updatedOrder;
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error updating order: $e');

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'Please ensure all fields are filled correctly.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void deleteOrder(int index) async {
    final orderId = orders[index]['salesOrder_id'];
    try {
      final haulingAdviceResponse = await supabase
          .from('haulingAdvice')
          .delete()
          .eq('salesOrder_id', orderId);

      final deliveryResponse =
          await supabase.from('delivery').delete().eq('salesOrder', orderId);

      final salesOrderResponse = await supabase
          .from('salesOrder')
          .delete()
          .eq('salesOrder_id', orderId);

      setState(() {
        orders.removeAt(index);
      });
    } catch (error) {
      print('Error deleting order: $error');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete order: $error'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = MediaQuery.of(context).size.height < 600;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(size: 20),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      drawerEnableOpenDragGesture: false,
      drawer: const BarTop(),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 11, 14, 17),
        ),
        child: ListView(
          children: [
            Align(
              alignment: Alignment.center,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                alignment: WrapAlignment.start,
                children: List.generate(
                  orders.length,
                  (index) {
                    return MonitorCard(
                      id: orders[index]['salesOrder_id'].toString(),
                      custName: orders[index]['custName'],
                      date: orders[index]['date'].toString(),
                      address: orders[index]['address'],
                      typeofload: orders[index]['typeofload'],
                      totalVolume: orders[index]['totalVolume'].toString(),
                      price: orders[index]['price'].toString(),
                      quantity: orders[index]['quantity'].toString(),
                      volumeDel: orders[index]['volumeDel'].toString(),
                      screenWidth: screenWidth * .25,
                      initialHeight: screenHeight * .30,
                      initialWidth: screenWidth * .25,
                      onEdit: () => editOrder(index),
                      onDelete: () => deleteOrder(index),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
