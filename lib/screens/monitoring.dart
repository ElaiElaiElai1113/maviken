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

  void editOrder(int index) {
    final salesOrder = filteredOrders[index]['salesOrder'];

    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController custNameController =
            TextEditingController(text: salesOrder['custName']);
        final TextEditingController addressController =
            TextEditingController(text: salesOrder['address']);

        DateTime selectedDate = DateTime.parse(salesOrder['date']);
        final TextEditingController dateController = TextEditingController(
            text: selectedDate.toLocal().toString().split(' ')[0]);

        //  status
        String selectedStatus = salesOrder['status'] ?? 'No Delivery';

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
                // Show confirmation dialog before saving changes
                final shouldSave = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm Save'),
                      content:
                          const Text('Are you sure you want to save changes?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
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
                      'address': addressController.text,
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
                                  final salesOrder =
                                      filteredOrders[index]['salesOrder'];
                                  final loads = filteredOrders[index]['loads'];

                                  return MonitorCard(
                                    id: salesOrder['salesOrder_id']
                                            ?.toString() ??
                                        'Unknown ID',
                                    custName:
                                        salesOrder['custName']?.toString() ??
                                            'Unknown Customer',
                                    date: salesOrder['date']?.toString() ??
                                        'Unknown Date',
                                    address:
                                        salesOrder['address']?.toString() ??
                                            'Unknown Address',
                                    typeofload: loads[0]['typeofload']
                                                ['loadtype']
                                            ?.toString() ??
                                        'Unknown Load Type',
                                    totalVolume:
                                        loads[0]['totalVolume']?.toString() ??
                                            '0',
                                    price:
                                        loads[0]['price']?.toString() ?? '0.0',
                                    volumeDel:
                                        loads[0]['volumeDel']?.toString() ??
                                            '0',
                                    status: salesOrder['status']?.toString() ??
                                        'No Status',
                                    screenWidth: screenWidth * .25,
                                    initialHeight: screenHeight * .30,
                                    initialWidth: screenWidth * .25,
                                    onEdit: () => editOrder(index),
                                    onDelete: () => deleteOrder(index),
                                    onViewLoad: () => viewLoadDetails(index),
                                    loads: loads,
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      )
                    : const Center(child: Text("No orders available")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
