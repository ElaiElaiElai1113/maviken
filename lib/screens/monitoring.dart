import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/monitor_card.dart';
import 'package:maviken/main.dart';

class Monitoring extends StatefulWidget {
  static const routeName = '/Monitoring';

  const Monitoring({Key? key}) : super(key: key);

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  List<Map<String, dynamic>> orders = [];

  Future<void> fetchData() async {
    final data = await supabase.from('salesOrder').select('*');
    setState(() {
      orders = data;
    });
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
        final TextEditingController quantityController =
            TextEditingController(text: order['quantity'].toString());

        DateTime selectedDate = DateTime.parse(order['date']);
        final TextEditingController dateController = TextEditingController(
            text: selectedDate.toLocal().toString().split(' ')[0]);
        return AlertDialog(
          title: Text('Edit Order'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: custNameController,
                    decoration: InputDecoration(labelText: 'Customer Name')),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
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
                    decoration: InputDecoration(labelText: 'Address')),
                TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Type of Load')),
                TextField(
                    controller: volumeController,
                    decoration: InputDecoration(labelText: 'Volume')),
                TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price')),
                TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'Quantity')),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                final updatedOrder = {
                  'salesOrder_id': order['salesOrder_id'],
                  'custName': custNameController.text,
                  'date': dateController.text,
                  'address': addressController.text,
                  'typeofload': descriptionController.text,
                  'totalVolume': int.parse(volumeController.text),
                  'price': double.parse(priceController.text),
                  'quantity': int.parse(quantityController.text),
                };
                await supabase
                    .from('salesOrder')
                    .update(updatedOrder)
                    .eq('salesOrder_id', order['salesOrder_id']);
                setState(() {
                  orders[index] = updatedOrder;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteOrder(int index) async {
    final orderId = orders[index]['salesOrder_id'];
    await supabase.from('salesOrder').delete().eq('salesOrder_id', orderId);
    setState(() {
      orders.removeAt(index);
    });
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
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 11, 14, 17),
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
