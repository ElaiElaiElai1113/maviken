import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:maviken/components/HaulingAdviceCard2.dart';
import 'package:maviken/components/haulingAdviceCard.dart';
import 'package:maviken/main.dart';

class MonitorCard extends StatelessWidget {
  final String id;
  final String custName;
  final String date;
  final String address;
  final String typeofload;
  final String totalVolume;
  final String price;
  final String volumeDel;
  final String status;

  final double screenWidth;
  final double initialHeight;
  final double initialWidth;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewLoad;
  final List<Map<String, dynamic>> loads;

  const MonitorCard({
    Key? key,
    required this.id,
    required this.custName,
    required this.date,
    required this.address,
    required this.typeofload,
    required this.totalVolume,
    required this.price,
    required this.volumeDel,
    required this.status,
    required this.screenWidth,
    required this.initialHeight,
    required this.initialWidth,
    required this.onEdit,
    required this.onDelete,
    required this.onViewLoad,
    required this.loads,
  }) : super(key: key);

  // Function to edit a load
  void onEditLoad(BuildContext context, Map<String, dynamic> load) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController volumeController =
            TextEditingController(text: load['totalVolume'].toString());
        final TextEditingController priceController =
            TextEditingController(text: load['price'].toString());

        return AlertDialog(
          title: const Text('Edit Load'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  // Create updated load object
                  final updatedLoad = {
                    'totalVolume': int.parse(volumeController.text),
                    'price': double.parse(priceController.text),
                  };

                  // Update the load in the database
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
                  // Delete the load from the database
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(custName),
            subtitle: Text('Address: $address\nStatus: $status'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          const Divider(),
          // ExpansionTile for expanding load details
          ExpansionTile(
            title: const Text('Load Details'),
            children: loads.map((load) {
              final billingAmount = load['price'] * load['volumeDel'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Load Type: ${load['typeofload']['loadtype']}'),
                    Text('Price: \$${load['price']}'),
                    Text('Total Volume: ${load['totalVolume']}'),
                    Text('${load['volumeDel']} / ${load['totalVolume']}'),
                    Text(
                        'Billing Amount: \$${billingAmount.toStringAsFixed(2)}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEditLoad(context, load),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onDeleteLoad(context, load),
                        ),
                        // New View Load button
                        ElevatedButton(
                          onPressed: () => onViewLoad(),
                          child: const Text('View Load'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
