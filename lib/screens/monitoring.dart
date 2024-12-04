import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/monitor_card.dart';
import 'package:maviken/main.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/data_service.dart';

final DataService dataService = DataService();
Map<String, dynamic>? selectedCustomer;

class Monitoring extends StatefulWidget {
  static const routeName = '/Monitoring';

  const Monitoring({super.key});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> haulingAdvice = [];
  List<Map<String, dynamic>> filteredOrders = [];
  int salesOrderId = 0;
  TextEditingController searchController = TextEditingController();
  double calculateTotalAmount(List<dynamic> selectedLoads) {
    double total = 0.0;
    for (var load in selectedLoads) {
      total += load['volumeDel'] * double.parse(load['price'].toString());
    }
    return total;
  }

  String generateBillingNo() {
    // Implement your logic to generate a billing number
    return '${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> createAccountsReceivable(
      int salesOrderId, List<dynamic> selectedLoads, String custName) async {
    try {
      final existingReceivable =
          await dataService.checkExistingReceivable(salesOrderId);
      Future<Map<String, dynamic>?> checkExistingReceivable(
          int salesOrderId) async {
        try {
          final response = await supabase
              .from('accountsReceivables')
              .select('*')
              .eq('salesOrder_id', salesOrderId)
              .single();

          return response;
        } catch (error) {
          print('Error checking existing accounts receivable: $error');
          return null;
        }
      }

      if (existingReceivable != null) {
        return;
      }

      double totalAmount = calculateTotalAmount(selectedLoads);

      await dataService.createAccountsReceivable(
        billingNo: generateBillingNo(),
        totalAmount: totalAmount,
        billingDate: DateTime.now().toString(),
        amountPaid: 0,
        paymentDate: null,
        paid: false,
        haulingAdviceID: null,
        salesOrderID: salesOrderId,
        custName: custName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Accounts Receivable created successfully for Sales ID: $salesOrderId, Customer: $custName')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error creating Accounts Receivable: ${error.toString()}')),
      );
    }
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

        // Sort orders to move "Complete" status to the bottom
        filteredOrders.sort((a, b) {
          String statusA = a['salesOrder']['status'] ?? '';
          String statusB = b['salesOrder']['status'] ?? '';

          if (statusA == 'Complete' && statusB != 'Complete') {
            return 1; // Move "Complete" to the bottom
          } else if (statusB == 'Complete' && statusA != 'Complete') {
            return -1; // Keep other statuses above
          }
          return 0; // Maintain relative order for others
        });
      });

      // Automatically create accounts receivable for completed orders
      for (var order in filteredOrders) {
        final salesOrder = order['salesOrder'];
        final status = salesOrder['status'];

        if (status == 'Complete') {
          String custName =
              salesOrder['custName']?.toString() ?? 'Unknown Customer';
          await createAccountsReceivable(
            salesOrder['salesOrder_id'],
            order['loads'],
            custName,
          );
        }
      }
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

      if (response['volumeDel'] != null) {
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
        await Supabase.instance.client
            .from('sales_orders')
            .update({'status': 'Active'}).eq('id', salesOrderId);
      } else {
        await Supabase.instance.client
            .from('sales_orders')
            .update({'status': 'Complete'}).eq('id', salesOrderId);
      }

      // Fetch updated data after status change
      fetchData();
    } catch (error) {
      print('Error updating sales order status: $error');
    }
  }

  List<Map<String, dynamic>> haulingAdviceData = [];

  Future<void> fetchDataHA(int salesOrderId) async {
    try {
      final data = await supabase
          .from('haulingAdvice')
          .select(
              '*, salesOrder!inner(*, salesOrderLoad(price, typeofload(*)))')
          .eq('salesOrder_id', salesOrderId);

      haulingAdviceData = List<Map<String, dynamic>>.from(data);

      // Sort haulingAdviceData by loadtype to group them together
      haulingAdviceData.sort((a, b) {
        final loadTypeA = a['loadtype'] ?? '';
        final loadTypeB = b['loadtype'] ?? '';
        return loadTypeA.compareTo(loadTypeB);
      });

      showHaulingAdviceDialog();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  void showHaulingAdviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hauling Advice Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 5000,
              height: 500,
              child: Table(
                // border: TableBorder.all(color: Colors.black),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Header
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.orangeAccent),
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Hauling Advice ID',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Date',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Volume Delivered',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Price',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Total Price',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Load Type',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )),
                      TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Pick Up Address',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )),
                      TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Delivery Address',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )),
                    ],
                  ),

                  ...buildGroupedRows(),
                ],
              ),
            ),
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

  List<TableRow> buildGroupedRows() {
    List<TableRow> rows = [];
    String? currentLoadType;

    for (var haulingAdvice in haulingAdviceData) {
      if (haulingAdvice['loadtype'] != currentLoadType) {
        currentLoadType = haulingAdvice['loadtype'];

        rows.add(
          TableRow(
            decoration: const BoxDecoration(color: Colors.black),
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    currentLoadType!,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              for (int i = 0; i < 7; i++)
                const TableCell(
                  child: SizedBox(),
                ),
            ],
          ),
        );
      }

      // Extract price based on the load type within salesOrderLoad
      double price = 0.0;
      if (haulingAdvice['salesOrder']?['salesOrderLoad'] != null) {
        var salesOrderLoads = haulingAdvice['salesOrder']['salesOrderLoad'];

        // Find the matching loadtype price
        var matchingLoad = salesOrderLoads.firstWhere(
          (load) => load['typeofload']['loadtype'] == haulingAdvice['loadtype'],
          orElse: () => null,
        );

        if (matchingLoad != null) {
          price = double.tryParse(matchingLoad['price'].toString()) ?? 0.0;
        }
      }

      var volumeDel = haulingAdvice['volumeDel'] ?? 0;
      double totalPrice = volumeDel * price; // Calculate total price
      print(totalPrice);
      rows.add(
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${haulingAdvice['haulingAdviceId']}'),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${haulingAdvice['date']}'),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${haulingAdvice['volumeDel']}'),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('₱ ${price.toStringAsFixed(2)}'),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('₱ ${totalPrice.toStringAsFixed(2)}'),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${haulingAdvice['loadtype']}'),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${haulingAdvice['pickUpAdd']}'),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${haulingAdvice['salesOrder']['deliveryAdd']}'),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  void _filterOrders() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredOrders = orders.where((order) {
        // Extract sales order fields for filtering
        final salesOrder = order['salesOrder'];

        final custName =
            (salesOrder['custName'] ?? '').toString().toLowerCase();
        final address = (salesOrder['address'] ?? '').toString().toLowerCase();
        final date = (salesOrder['date'] ?? '').toString().toLowerCase();
        final status = (salesOrder['status'] ?? '').toString().toLowerCase();

        // Extract load details for filtering
        final loads = order['salesOrderLoad'];

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
      var currentIndex = args ?? 0;
    });
  }

  void editOrder(int index) {
    final salesOrder = filteredOrders[index]['salesOrder'];
    String selectedStatus = salesOrder['status'] ?? 'No Delivery';

    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController custNameController =
            TextEditingController(text: salesOrder['custName']);
        final TextEditingController deliveryAddController =
            TextEditingController(text: salesOrder['deliveryAdd']);
        DateTime selectedDate = DateTime.parse(salesOrder['date']);
        final TextEditingController dateController = TextEditingController(
            text: selectedDate.toLocal().toString().split(' ')[0]);

        // Generate dropdown options dynamically
        List<String> dropdownOptions = ['No Delivery', 'Active', 'Complete'];
        if (selectedStatus == 'Active') {
          dropdownOptions = dropdownOptions
              .where((status) => status != 'No Delivery')
              .toList();
        }

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
                    // Customer Name (Always ReadOnly)
                    TextField(
                      controller: custNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      readOnly: true, // Always non-editable
                    ),
                    const SizedBox(height: 10),

                    // Date Field
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      readOnly: true, // Always readonly; handled by date picker
                      onTap: () async {
                        if (selectedStatus != 'No Delivery') {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(3000),
                          );
                          if (pickedDate != null &&
                              pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                              dateController.text =
                                  pickedDate.toLocal().toString().split(' ')[0];
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // Delivery Address
                    TextField(
                      controller: deliveryAddController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: dropdownOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: selectedStatus == 'No Delivery'
                          ? null
                          : (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedStatus = newValue;
                                });
                              }
                            },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            // Cancel Button
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // Save Button
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
                if (selectedStatus == "Active") {
                  Navigator.of(context).pop();
                  return;
                }

                final updatedOrder = {
                  'custName': custNameController.text, // Will remain unchanged
                  'date': dateController.text,
                  'deliveryAdd': deliveryAddController.text,
                  'status': selectedStatus,
                };
                try {
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
                        title: const Text('Error'),
                        content:
                            const Text('Failed to save changes. Try again.'),
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
        Expanded(
          child: filteredOrders.isNotEmpty
              ? ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final salesOrder = order['salesOrder'];
                    final salesOrderId = salesOrder['salesOrder_id'];
                    final status = salesOrder['status'];

                    // Debug print to check the status
                    print('Order ID: $salesOrderId, Status: $status');

                    return Column(
                      children: [
                        MonitorCard(
                          id: salesOrderId?.toString() ?? 'Unknown ID',
                          custName: salesOrder['custName']?.toString() ??
                              'Unknown Customer',
                          date:
                              salesOrder['date']?.toString() ?? 'Unknown Date',
                          deliveryAdd: salesOrder['deliveryAdd']?.toString() ??
                              'Unknown Delivery Address',
                          typeofload: order['loads'][0]['typeofload']
                                      ['loadtype']
                                  ?.toString() ??
                              'Unknown Load Type',
                          totalVolume:
                              order['loads'][0]['totalVolume']?.toString() ??
                                  '0',
                          price:
                              order['loads'][0]['price']?.toString() ?? '0.0',
                          volumeDel:
                              order['loads'][0]['volumeDel']?.toString() ?? '0',
                          status: status?.toString() ?? 'No Status',
                          screenWidth: screenWidth,
                          initialHeight: screenHeight * .30,
                          initialWidth: screenWidth,
                          onEdit: () => editOrder(index),
                          onDelete: () => deleteOrder(index),
                          loads: order['loads'],
                          onViewHA: () => fetchDataHA(salesOrderId),
                        ),
                      ],
                    );
                  },
                )
              : const Center(child: Text("No orders available")),
        ),
      ],
    );
  }
}
