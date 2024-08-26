import 'package:flutter/material.dart';
import 'package:maviken/main.dart';

class HaulingAdviceCard extends StatefulWidget {
  final String salesOrderId;

  const HaulingAdviceCard({super.key, required this.salesOrderId});

  @override
  _HaulingAdviceCardState createState() => _HaulingAdviceCardState();
}

class _HaulingAdviceCardState extends State<HaulingAdviceCard> {
  List<Map<String, dynamic>> haulingAdvices = [];

  @override
  void initState() {
    super.initState();
    fetchHaulingAdvice();
  }

  Future<void> fetchHaulingAdvice() async {
    try {
      final response = await supabase
          .from('haulingAdvice')
          .select('*')
          .eq('salesOrder_id', widget.salesOrderId);

      setState(() {
        haulingAdvices = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Error fetching hauling advice: $error');
    }
  }

  Future<void> updateHaulingAdvice(
      int index, Map<String, dynamic> updatedAdvice) async {
    try {
      final response = await supabase
          .from('haulingAdvice')
          .update(updatedAdvice)
          .eq('haulingAdvice_id', haulingAdvices[index]['haulingAdvice_id']);

      if (response.error != null) {
        throw response.error!;
      }

      setState(() {
        haulingAdvices[index] = updatedAdvice;
      });
    } catch (error) {
      print('Error updating hauling advice: $error');
    }
  }

  Future<void> addHaulingAdvice(Map<String, dynamic> newAdvice) async {
    try {
      final response = await supabase.from('haulingAdvice').insert(newAdvice);

      if (response.error != null) {
        throw response.error!;
      }

      setState(() {
        haulingAdvices.add(newAdvice);
      });
    } catch (error) {
      print('Error adding hauling advice: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                final TextEditingController descriptionController =
                    TextEditingController();
                final TextEditingController dateController =
                    TextEditingController();

                return AlertDialog(
                  title: const Text('Add New Hauling Advice'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                      TextField(
                        controller: dateController,
                        decoration: const InputDecoration(labelText: 'Date'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Add'),
                      onPressed: () {
                        final newAdvice = {
                          'salesOrder_id': widget.salesOrderId,
                          'description': descriptionController.text,
                          'date': dateController.text,
                        };
                        addHaulingAdvice(newAdvice);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Add Hauling Advice'),
        ),
        Column(
          children: haulingAdvices.map((advice) {
            int index = haulingAdvices.indexOf(advice);
            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text('Advice ID: ${advice['haulingAdvice_id']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${advice['description']}'),
                    Text('Date: ${advice['date']}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final TextEditingController descriptionController =
                            TextEditingController(text: advice['description']);
                        final TextEditingController dateController =
                            TextEditingController(text: advice['date']);

                        return AlertDialog(
                          title: const Text('Edit Hauling Advice'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                    labelText: 'Description'),
                              ),
                              TextField(
                                controller: dateController,
                                decoration:
                                    const InputDecoration(labelText: 'Date'),
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
                              onPressed: () {
                                final updatedAdvice = {
                                  'haulingAdvice_id':
                                      advice['haulingAdvice_id'],
                                  'description': descriptionController.text,
                                  'date': dateController.text,
                                };
                                updateHaulingAdvice(index, updatedAdvice);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
