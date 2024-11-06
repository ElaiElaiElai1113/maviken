import 'package:flutter/material.dart';
import 'package:maviken/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllLoadPage extends StatefulWidget {
  static const routeName = '/loadPage';
  const AllLoadPage({super.key});

  @override
  State<AllLoadPage> createState() => _AllLoadPageState();
}

class _AllLoadPageState extends State<AllLoadPage> {
  List<dynamic> loadList = [];

  @override
  Future<void> fetchLoad() async {
    final response =
        await Supabase.instance.client.from('typeofload').select('*');

    setState(() {
      loadList = response.map((e) {
        return Map<String, dynamic>.from(e);
      }).toList();
    });
  }

  Future<void> deleteLoad(int index) async {
    final loadID = loadList[index]['loadID'];
    try {
      final response = await Supabase.instance.client
          .from('typeofload')
          .delete()
          .eq('loadID', loadID);
      setState(() {
        loadList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Load successfully deleted'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Load was not deleted $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void editLoad(int index) {
    final load = loadList[index];
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController loadTypeController =
            TextEditingController(text: load['loadtype']);

        return AlertDialog(
          title: const Text('Edit Load Data'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: loadTypeController,
                  decoration: const InputDecoration(labelText: 'Load Type'),
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
                      'loadtype': loadTypeController.text,
                    };
                    await supabase
                        .from('typeofload')
                        .update(updatedOrder)
                        .eq('loadID', load['loadID']);
                    setState(() {
                      loadList[index] = {...load, ...updatedOrder};
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Load updated successfully!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    print('Error updating Load: $e');
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
                }),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load List'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: SingleChildScrollView(
        child: Expanded(
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(color: Colors.black),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header
                const TableRow(
                  decoration: BoxDecoration(color: Colors.redAccent),
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Load ID',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Load Type',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Actions',
                              style: TextStyle(color: Colors.white)),
                        )),
                  ],
                ),
                // Generate rows dynamically based on filtered data
                ...loadList.asMap().entries.map((entry) {
                  int index = entry.key;
                  var supplier = entry.value;
                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['loadID']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${supplier['loadtype']}'),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    editLoad(index);
                                  },
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    deleteLoad(index);
                                  },
                                  icon: const Icon(Icons.delete)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
