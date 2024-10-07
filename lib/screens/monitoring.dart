import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/monitor_card.dart';
import 'package:maviken/main.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';

class Monitoring extends StatefulWidget {
  static const routeName = '/Monitoring';

  const Monitoring({super.key});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  TextEditingController searchController = TextEditingController();

  void viewLoadDetails(int index) {
    final order = filteredOrders[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Load Details for ${order['salesOrder']['custName']?.toString() ?? 'Unknown Customer'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Load Type: ${order['typeofload']['loadtype']?.toString() ?? 'Unknown'}'),
              Text('Volume: ${order['totalVolume']?.toString() ?? '0'}'),
              Text('Price: \$${order['price']?.toString() ?? '0.0'}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchData() async {
    try {
      final data = await supabase
          .from('salesOrderLoad')
          .select('*, salesOrder!inner(*), typeofload!inner(*)');
      setState(() {
        orders = List<Map<String, dynamic>>.from(data);
        filteredOrders = orders;
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
    searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterOrders() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredOrders = orders.where((order) {
        final custName =
            (order['salesOrder']['custName'] ?? '').toString().toLowerCase();
        final address =
            (order['salesOrder']['address'] ?? '').toString().toLowerCase();
        final typeofload =
            (order['typeofload']['loadtype'] ?? '').toString().toLowerCase();
        final status =
            (order['salesOrder']['status'] ?? '').toString().toLowerCase();
        return custName.contains(query) ||
            address.contains(query) ||
            typeofload.contains(query) ||
            status.contains(query);
      }).toList();
    });
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

        //  status
        String selectedStatus = order['status'] ?? 'Not Delivery';

        return AlertDialog(
          title: const Text('Edit Order'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: custNameController,
                      decoration:
                          const InputDecoration(labelText: 'Customer Name'),
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
                          lastDate: DateTime(3000),
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
                      decoration:
                          const InputDecoration(labelText: 'Type of Load'),
                    ),
                    TextField(
                      controller: volumeController,
                      decoration: const InputDecoration(labelText: 'Volume'),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: ['No Delivery', 'On Route', 'Complete']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
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
                    'status': selectedStatus,
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
    final orderId = filteredOrders[index]['salesOrder_id'];
    try {
      // Delete related rows in delivery table first
      await supabase.from('delivery').delete().eq('salesOrder_id', orderId);

      // Delete related rows in salesOrderLoad table
      await supabase
          .from('salesOrderLoad')
          .delete()
          .eq('salesOrder_id', orderId);

      // Proceed to delete from salesOrder
      await supabase.from('salesOrder').delete().eq('salesOrder_id', orderId);

      // Update UI after successful deletion
      setState(() {
        orders.removeWhere((order) => order['salesOrder_id'] == orderId);
        filteredOrders = orders;
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

    return Scaffold(
      drawer: const BarTop(),
      body: SidebarDrawer(
        drawer: const BarTop(),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                leading: const DrawerIcon(),
                title: const Text("Monitoring"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    fillColor: Colors.black,
                    labelText: 'Search',
                    hintText: 'Search by name, location, or type of load',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: filteredOrders.isNotEmpty
                    ? ListView(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              alignment: WrapAlignment.start,
                              children: List.generate(
                                filteredOrders.length,
                                (index) {
                                  return MonitorCard(
                                    id: filteredOrders[index]['salesOrder']
                                                ['salesOrder_id']
                                            ?.toString() ??
                                        'Unknown ID',
                                    custName: filteredOrders[index]
                                                ['salesOrder']['custName']
                                            ?.toString() ??
                                        'Unknown Customer',
                                    date: filteredOrders[index]['salesOrder']
                                                ['date']
                                            ?.toString() ??
                                        'Unknown Date',
                                    address: filteredOrders[index]['salesOrder']
                                                ['address']
                                            ?.toString() ??
                                        'Unknown Address',
                                    typeofload: filteredOrders[index]
                                                ['typeofload']['loadtype']
                                            ?.toString() ??
                                        'Unknown Load Type',
                                    totalVolume: filteredOrders[index]
                                                ['totalVolume']
                                            ?.toString() ??
                                        '0',
                                    price: filteredOrders[index]['price']
                                            ?.toString() ??
                                        '0.0',
                                    volumeDel: filteredOrders[index]
                                                ['volumeDel']
                                            ?.toString() ??
                                        '0',
                                    status: filteredOrders[index]['salesOrder']
                                                ['status']
                                            ?.toString() ??
                                        'No Status',
                                    screenWidth: screenWidth * .25,
                                    initialHeight: screenHeight * .30,
                                    initialWidth: screenWidth * .25,
                                    onEdit: () => editOrder(index),
                                    onDelete: () => deleteOrder(index),
                                    onViewLoad: () => viewLoadDetails(index),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      )
                    : const Center(child: Text("No orders available")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
