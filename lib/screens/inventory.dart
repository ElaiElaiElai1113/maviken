import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/main.dart';
import 'package:intl/intl.dart';

class Inventory extends StatefulWidget {
  static const routeName = '/inventoryPage';
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

List<Map<String, dynamic>> inventoryItems = [];
List<Map<String, dynamic>> serviceTypes = [];
Map<String, dynamic>? selectedService;

class _InventoryState extends State<Inventory> {
  Future<void> fetchService() async {
    final response = await supabase.from('serviceTypes').select('*');

    serviceTypes = response
        .map<Map<String, dynamic>>((serviceType) => {
              'id': serviceType['id'],
              'serviceType': serviceType['serviceType'],
            })
        .toList();
  }

  Future<void> fetchInventory() async {
    final response = await supabase
        .from('inventory')
        .select('*, serviceTypes!inner(serviceType)');

    inventoryItems = response
        .map<Map<String, dynamic>>((inventory) => {
              'id': inventory['id'],
              'itemName': inventory['itemName'],
              'quantity': inventory['quantity'],
              'lastUpdated': inventory['lastUpdated'],
              'category': inventory['category'],
              'serviceType': inventory['serviceTypes']['serviceType'],
            })
        .toList();
  }

  Future<void> createItem(Map<String, dynamic> newItem) async {
    await supabase.from('inventory').insert(newItem);
    fetchInventory();
  }

  Future<void> updateItem(int id, Map<String, dynamic> updatedFields) async {
    await supabase.from('inventory').update(updatedFields).eq('id', id);
    fetchInventory();
  }

  Future<void> deleteItem(int id) async {
    await supabase.from('inventory').delete().eq('id', id);
    fetchInventory();
  }

  void _showAddItemDialog(BuildContext context) {
    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 25),
              dropDown('Category', serviceTypes, selectedService,
                  (Map<String, dynamic>? newValue) {
                selectedService = newValue;
              }, 'serviceType'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newItem = {
                  'itemName': itemNameController.text,
                  'quantity': int.tryParse(quantityController.text) ?? 0,
                  'category': selectedService?['id'],
                  'lastUpdated': DateTime.now().toIso8601String(),
                };
                createItem(newItem);
                fetchInventory();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(BuildContext context, Map<String, dynamic> item) {
    final TextEditingController itemNameController =
        TextEditingController(text: item['itemName']);
    final TextEditingController quantityController =
        TextEditingController(text: item['quantity'].toString());
    final TextEditingController categoryController =
        TextEditingController(text: item['category']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedItem = {
                  'itemName': itemNameController.text,
                  'quantity': int.tryParse(quantityController.text) ?? 0,
                  'category': categoryController.text,
                  'lastUpdated': DateTime.now().toIso8601String(),
                };
                updateItem(item['id'], updatedItem);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addStockIn(
      int inventoryId, int quantity, String description, int poNumber) async {
    final newStockIn = {
      'inventoryID': inventoryId,
      'quantity': quantity,
      'description': description,
      'date': DateTime.now().toIso8601String(),
      'PO#': poNumber,
    };

    // Insert new stock-in record
    await supabase.from('stockIn').insert(newStockIn);

    // Update the inventory quantity
    final inventoryItem =
        inventoryItems.firstWhere((item) => item['id'] == inventoryId);
    final updatedQuantity = inventoryItem['quantity'] + quantity;

    await updateItem(inventoryId, {'quantity': updatedQuantity});

    // Fetch updated inventory and refresh UI
    await fetchInventory();
  }

  void _showStockInDialog(BuildContext context, int inventoryId) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController purchaseOrderController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Stock-In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: purchaseOrderController,
                decoration: InputDecoration(labelText: 'Purchase Order #'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                final poNumber =
                    int.tryParse(purchaseOrderController.text) ?? 0;
                final description = descriptionController.text;

                await addStockIn(inventoryId, quantity, description, poNumber);

                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Stock successfully added'),
                  backgroundColor: Colors.green,
                ));

                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchService().then((_) {
      fetchInventory().then((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: inventoryPage(screenWidth, screenHeight, context),
        label: ('Inventory'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add Item',
      ),
    );
  }

  SingleChildScrollView inventoryPage(
    double screenWidth,
    double screenHeight,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: Colors.black),
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
                  child: Text('ID', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text('Item Name', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text('Quantity', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text('Category', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Last Updated',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Actions', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),

          ...inventoryItems.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;
            return TableRow(
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${item['id']}'),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${item['itemName']}'),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${item['quantity']}'),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${item['serviceType']}'),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(DateFormat('MMMM d, y')
                        .format(DateTime.parse(item['lastUpdated']))),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditItemDialog(context, item),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.green),
                        onPressed: () =>
                            _showStockInDialog(context, item['id']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteItem(item['id']),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
