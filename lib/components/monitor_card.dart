import 'package:flutter/material.dart';
import 'package:maviken/main.dart';

class MonitorCard extends StatelessWidget {
  final String id;
  final String custName;
  final String date;
  final String pickUpAdd;
  final String deliveryAdd;
  final String typeofload;
  final String totalVolume;
  final String price;
  final String volumeDel;
  final String status;

  final double screenWidth;
  final double initialHeight;
  final double initialWidth;
<<<<<<< Updated upstream
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewHA;
=======

>>>>>>> Stashed changes
  final List<Map<String, dynamic>> loads;

  const MonitorCard({
    super.key,
    required this.id,
    required this.custName,
    required this.date,
    required this.pickUpAdd,
    required this.deliveryAdd,
    required this.typeofload,
    required this.totalVolume,
    required this.price,
    required this.volumeDel,
    required this.status,
    required this.screenWidth,
    required this.initialHeight,
    required this.initialWidth,
<<<<<<< Updated upstream
    required this.onEdit,
    required this.onDelete,
=======
>>>>>>> Stashed changes
    required this.loads,
    required this.onViewHA,
  });

  void onEditLoad(BuildContext context, Map<String, dynamic> load) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController volumeController =
            TextEditingController(text: load['totalVolume'].toString());
        final TextEditingController priceController =
            TextEditingController(text: load['loadPrice'].toString());

        return AlertDialog(
          title: const Text('Edit Load'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                  controller: volumeController,
                  decoration: const InputDecoration(labelText: 'Volume'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ),
            ],
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
                  final updatedLoad = {
                    'totalVolume': int.parse(volumeController.text),
                    'price': double.parse(priceController.text),
                  };

                  await supabase
                      .from('salesOrderLoad')
                      .update(updatedLoad)
                      .eq('salesOrderLoad_id', load['salesOrderLoad_id']);

                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error updating load: $e');
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Failed to update the load.'),
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

  void onDeleteLoad(BuildContext context, Map<String, dynamic> load) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Load'),
          content: const Text('Are you sure you want to delete this load?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await supabase
                      .from('salesOrderLoad')
                      .delete()
                      .eq('salesOrderLoad_id', load['salesOrderLoad_id']);
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error deleting load: $e');
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Failed to delete the load.'),
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

  String determineStatus() {
    // Check if any load has volumeDel > 0
    bool isOnRoute = loads.any((load) {
      var volume = int.tryParse(load['volumeDel'].toString()) ?? 0;
      return volume > 0;
    });

    return isOnRoute ? 'On Route' : status;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$id - $custName',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pickup: $pickUpAdd',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Delivery: $deliveryAdd',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Status: ${determineStatus()}',
                        style: TextStyle(
                            color: determineStatus() == 'Complete'
                                ? Colors.green
                                : Colors.red),
                      ),
                      TextButton(
                        onPressed: onViewHA,
                        child: Text('View Hauling Advices'),
                      ),
                    ],
                  ),
                ),
<<<<<<< Updated upstream
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: determineStatus() == "Complete"
                            ? Colors.grey
                            : Colors.blueAccent,
                      ),
                      onPressed:
                          determineStatus() == "Complete" ? null : onEdit,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color:
                            determineStatus() == "Complete" ? null : Colors.red,
                      ),
                      onPressed:
                          determineStatus() == "Complete" ? null : onDelete,
                    ),
                  ],
                ),
=======
>>>>>>> Stashed changes
              ],
            ),
            const Divider(),
            ExpansionTile(
              title: const Text(
                'Load Details',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1.5),
                    2: FlexColumnWidth(1.5),
                  },
                  border: TableBorder.all(color: Colors.grey),
                  children: [
                    // Table header
                    const TableRow(
                      decoration: BoxDecoration(color: Colors.grey),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Type of Load',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Volume',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Billing',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Actions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    for (var load in loads)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${load['typeofload']['loadtype']}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '${load['volumeDel']} / ${load['totalVolume']}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                'PHP ${((load['loadPrice'] ?? 0) * (load['volumeDel'] ?? 0)).toStringAsFixed(2)}'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blueAccent),
                                  onPressed: () => onEditLoad(context, load),
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => onDeleteLoad(context, load),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
