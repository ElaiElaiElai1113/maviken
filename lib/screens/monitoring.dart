import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/monitor_card.dart';
import 'package:maviken/main.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

        // Group orders by salesOrder_id
        Map<int, List<Map<String, dynamic>>> salesOrderMap = {};

        for (var order in orders) {
          int salesOrderId = order['salesOrder']['salesOrder_id'];

          if (!salesOrderMap.containsKey(salesOrderId)) {
            salesOrderMap[salesOrderId] = [];
          }
          salesOrderMap[salesOrderId]!.add(order);
        }

        // Store grouped sales orders
        filteredOrders = [];
        salesOrderMap.forEach((salesOrderId, loads) {
          filteredOrders.add({
            'salesOrder': loads[0]['salesOrder'],
            'loads': loads,
          });
        });
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  Future<void> checkAndUpdateStatus(int salesOrderId) async {
    try {
      // Fetch volumeDel for the specific salesOrderId
      final response = await Supabase.instance.client
          .from('sales_orders')
          .select('volumeDel')
          .eq('id', salesOrderId)
          .single();

      if (response != null && response['volumeDel'] != null) {
        int volumeDel = response['volumeDel'];

        // Call the update function with the fetched volumeDel
        await updateSalesOrderStatus(salesOrderId, volumeDel);
      } else {
        print('No volumeDel data found for the sales order.');
      }
    } catch (error) {
      print('Error fetching volumeDel: $error');
    }
  }

  Future<void> updateSalesOrderStatus(int salesOrderId, int volumeDel) async {
    try {
      if (volumeDel > 0) {
        // Update the status to 'On Route' if volumeDel > 0
        await Supabase.instance.client
            .from('sales_orders')
            .update({'status': 'On Route'}).eq('id', salesOrderId);
        print('Sales order status updated to On Route');
      } else {
        print('No update needed. volumeDel is 0 or less.');
      }
    } catch (error) {
      print('Error updating sales order status: $error');
    }
  }

  void _filterOrders() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredOrders = orders.where((order) {
        // Extract sales order fields for filtering
        final salesOrder = order['salesOrder'];
        print('Sales Order: $salesOrder');
        final custName =
            (salesOrder['custName'] ?? '').toString().toLowerCase();
        final address = (salesOrder['address'] ?? '').toString().toLowerCase();
        final date = (salesOrder['date'] ?? '').toString().toLowerCase();
        final status = (salesOrder['status'] ?? '').toString().toLowerCase();

        // Extract load details for filtering
        final loads = order['salesOrderLoad'];
        print('Fetched loads: $loads');
        print('Full Order Data: $order');

        // Check if the query matches any of the fields
        return custName.contains(query) ||
            address.contains(query) ||
            status.contains(query) ||
            date.contains(query);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    // searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void deleteOrder(int index) async {
    final salesOrder = filteredOrders[index]['salesOrder'];
    if (salesOrder == null || salesOrder['salesOrder_id'] == null) {
      print('Error: salesOrder or salesOrder_id is null');
      return;
    }

    final salesOrderId = salesOrder['salesOrder_id'];

    // Show confirmation dialog before deleting
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this order? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false to cancel delete
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true to proceed with delete
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // If user confirmed the delete, proceed with deletion
      try {
        // Step 1: Delete related rows in haulingAdvice table first
        final deliveryIds = await supabase
            .from('delivery')
            .select('deliveryid')
            .eq('salesOrder', salesOrderId);

        if (deliveryIds.isNotEmpty) {
          for (var delivery in deliveryIds) {
            final deliveryId = delivery['deliveryid'];
            if (deliveryId != null) {
              await supabase
                  .from('haulingAdvice')
                  .delete()
                  .eq('deliveryID', deliveryId);
            }
          }
        }

        // Step 2: Now delete related rows in delivery table
        await supabase.from('delivery').delete().eq('salesOrder', salesOrderId);

        // Step 3: Delete related rows in salesOrderLoad table
        await supabase
            .from('salesOrderLoad')
            .delete()
            .eq('salesOrder_id', salesOrderId);

        // Step 4: Finally, delete from salesOrder table
        await supabase
            .from('salesOrder')
            .delete()
            .eq('salesOrder_id', salesOrderId);

        // Update UI after successful deletion
        setState(() {
          filteredOrders.removeAt(index);
          orders = filteredOrders;
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as int?;
    setState(() {
      var _currentIndex = args ?? 0;
    });
  }

  void editOrder(int index) {
    final salesOrder = filteredOrders[index]['salesOrder'];

    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController custNameController =
            TextEditingController(text: salesOrder['custName']);
        final TextEditingController pickUpAddController =
            TextEditingController(text: salesOrder['pickUpAdd']);
        final TextEditingController deliveryAddController =
            TextEditingController(text: salesOrder['deliveryAdd']);
        DateTime selectedDate = DateTime.parse(salesOrder['date']);
        final TextEditingController dateController = TextEditingController(
            text: selectedDate.toLocal().toString().split(' ')[0]);

        String selectedStatus = salesOrder['status'] ?? 'No Delivery';

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Order',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: custNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: pickUpAddController,
                      decoration: const InputDecoration(
                        labelText: 'Pick-up Address',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: deliveryAddController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
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
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF0a438f)),
              ),
              onPressed: () async {
                final shouldSave = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text('Confirm Save'),
                      content:
                          const Text('Are you sure you want to save changes?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.grey)),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Save'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (shouldSave == true) {
                  try {
                    final updatedOrder = {
                      'custName': custNameController.text,
                      'date': dateController.text,
                      'pickUpAdd': pickUpAddController.text,
                      'deliveryAdd': deliveryAddController.text,
                      'status': selectedStatus,
                    };
                    await supabase
                        .from('salesOrder')
                        .update(updatedOrder)
                        .eq('salesOrder_id', salesOrder['salesOrder_id']);
                    setState(() {
                      filteredOrders[index]['salesOrder'] = {
                        ...salesOrder,
                        ...updatedOrder,
                      };
                      orders = filteredOrders;
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('Error'),
                          content: const Text(
                              'Please ensure all fields are filled correctly.'),
                          actions: [
                            TextButton(
                              child: const Text('OK',
                                  style: TextStyle(color: Colors.grey)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: monitoring(screenWidth, screenHeight),
        label: "Monitoring");
  }

  Column monitoring(double screenWidth, double screenHeight) {
    return Column(
      children: [
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: TextField(
        //     controller: searchController,
        //     decoration: const InputDecoration(
        //       fillColor: Colors.black,
        //       labelText: 'Search',
        //       hintText: 'Search by name, location, or type of load',
        //       prefixIcon: Icon(Icons.search),
        //       border: OutlineInputBorder(),
        //     ),
        //   ),
        // ),
        Expanded(
          child: filteredOrders.isNotEmpty
              ? ListView(
                  children: [
                    Column(
                      children: List.generate(
                        (filteredOrders.length / 2).ceil(),
                        (rowIndex) {
                          return Row(
                            children: [
                              Expanded(
                                child: MonitorCard(
                                  id: filteredOrders[rowIndex * 2]['salesOrder']
                                              ['salesOrder_id']
                                          ?.toString() ??
                                      'Unknown ID',
                                  custName: filteredOrders[rowIndex * 2]
                                              ['salesOrder']['custName']
                                          ?.toString() ??
                                      'Unknown Customer',
                                  date: filteredOrders[rowIndex * 2]
                                              ['salesOrder']['date']
                                          ?.toString() ??
                                      'Unknown Date',
                                  pickUpAdd: filteredOrders[rowIndex * 2]
                                              ['salesOrder']['pickUpAdd']
                                          ?.toString() ??
                                      'Unknown Pickup Address',
                                  deliveryAdd: filteredOrders[rowIndex * 2]
                                              ['salesOrder']['deliveryAdd']
                                          ?.toString() ??
                                      'Unknown Delivery Address',
                                  typeofload: filteredOrders[rowIndex * 2]
                                                  ['loads'][0]['typeofload']
                                              ['loadtype']
                                          ?.toString() ??
                                      'Unknown Load Type',
                                  totalVolume: filteredOrders[rowIndex * 2]
                                              ['loads'][0]['totalVolume']
                                          ?.toString() ??
                                      '0',
                                  price: filteredOrders[rowIndex * 2]['loads']
                                              [0]['loadPrice']
                                          ?.toString() ??
                                      '0.0',
                                  volumeDel: filteredOrders[rowIndex * 2]
                                              ['loads'][0]['volumeDel']
                                          ?.toString() ??
                                      '0',
                                  status: filteredOrders[rowIndex * 2]
                                              ['salesOrder']['status']
                                          ?.toString() ??
                                      'No Status',
                                  screenWidth: screenWidth * .5,
                                  initialHeight: screenHeight * .30,
                                  initialWidth: screenWidth * .5,
                                  onEdit: () => editOrder(rowIndex * 2),
                                  onDelete: () => deleteOrder(rowIndex * 2),
                                  onViewLoad: () =>
                                      viewLoadDetails(rowIndex * 2),
                                  loads: filteredOrders[rowIndex * 2]['loads'],
                                ),
                              ),
                              if (rowIndex * 2 + 1 < filteredOrders.length)
                                Expanded(
                                  child: MonitorCard(
                                    id: filteredOrders[rowIndex * 2 + 1]
                                                ['salesOrder']['salesOrder_id']
                                            ?.toString() ??
                                        'Unknown ID',
                                    custName: filteredOrders[rowIndex * 2 + 1]
                                                ['salesOrder']['custName']
                                            ?.toString() ??
                                        'Unknown Customer',
                                    date: filteredOrders[rowIndex * 2 + 1]
                                                ['salesOrder']['date']
                                            ?.toString() ??
                                        'Unknown Date',
                                    pickUpAdd: filteredOrders[rowIndex * 2 + 1]
                                                ['salesOrder']['pickUpAdd']
                                            ?.toString() ??
                                        'Unknown Pickup Address',
                                    deliveryAdd:
                                        filteredOrders[rowIndex * 2 + 1]
                                                        ['salesOrder']
                                                    ['deliveryAdd']
                                                ?.toString() ??
                                            'Unknown Delivery Address',
                                    typeofload: filteredOrders[rowIndex * 2 + 1]
                                                    ['loads'][0]['typeofload']
                                                ['loadtype']
                                            ?.toString() ??
                                        'Unknown Load Type',
                                    totalVolume:
                                        filteredOrders[rowIndex * 2 + 1]
                                                    ['loads'][0]['totalVolume']
                                                ?.toString() ??
                                            '0',
                                    price: filteredOrders[rowIndex * 2 + 1]
                                                ['loads'][0]['loadPrice']
                                            ?.toString() ??
                                        '0.0',
                                    volumeDel: filteredOrders[rowIndex * 2 + 1]
                                                ['loads'][0]['volumeDel']
                                            ?.toString() ??
                                        '0',
                                    status: filteredOrders[rowIndex * 2 + 1]
                                                ['salesOrder']['status']
                                            ?.toString() ??
                                        'No Status',
                                    screenWidth: screenWidth * .5,
                                    initialHeight: screenHeight * .30,
                                    initialWidth: screenWidth * .5,
                                    onEdit: () => editOrder(rowIndex * 2 + 1),
                                    onDelete: () =>
                                        deleteOrder(rowIndex * 2 + 1),
                                    onViewLoad: () =>
                                        viewLoadDetails(rowIndex * 2 + 1),
                                    loads: filteredOrders[rowIndex * 2 + 1]
                                        ['loads'],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const Center(child: Text("No orders available")),
        ),
      ],
    );
  }
}
