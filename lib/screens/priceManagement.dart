import 'package:flutter/material.dart';
import 'package:maviken/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PriceManagement extends StatefulWidget {
  static const routeName = '/PriceManagement';
  const PriceManagement({super.key});

  @override
  State<PriceManagement> createState() => PriceManagementState();
}

class PriceManagementState extends State<PriceManagement> {
  List<Map<String, dynamic>> supplierLoadPrice = [];
  List<Map<String, dynamic>> supplier = [];
  Map<String, dynamic>? selectedSupplier;

  Future<void> getSupplierLoadPrice() async {
    final response = await supabase
        .from('supplierLoadPrice')
        .select('*, typeofload!inner(loadtype), supplier!inner(companyName)');

    setState(() {
      supplierLoadPrice = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> fetchSupplier() async {
    final response =
        await Supabase.instance.client.from('supplier').select('*');

    if (!mounted) return;
    setState(() {
      supplier = response
          .map<Map<String, dynamic>>((supplier) => {
                'supplier_id': supplier['supplier_id'],
                'companyName': supplier['companyName'],
                'fullName': '${supplier['firstName']} - ${'lastName'}',
              })
          .toList();
      if (supplier.isNotEmpty) {
        selectedSupplier = supplier.first;
      }
    });

    @override
    void initState() {
      super.initState();
      getSupplierLoadPrice();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Management'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                String reloaded = 'Price List Reloaded!';

                getSupplierLoadPrice();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(reloaded),
                  backgroundColor: Colors.green,
                ));
              },
              icon: const Icon(Icons.replay)),
        ],
      ),
      body: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(color: Colors.white30),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header
            const TableRow(
              decoration: BoxDecoration(color: Colors.redAccent),
              children: [
                const TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Supplier ID',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Load Type',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Price', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            // Generate rows dynamically
            ...supplierLoadPrice.map((supplierPrice) {
              return TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text('${supplierPrice['supplier']['companyName']}'),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${supplierPrice['typeofload']['loadtype']}'),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${supplierPrice['price']}'),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
