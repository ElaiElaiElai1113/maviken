import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/main.dart';

List<Map<String, dynamic>> salesOrderList = [];
List<Map<String, dynamic>> haulingAdviceList = [];
int? salesOrderID;
int? haulingAdviceID;
final TextEditingController searchController = TextEditingController();
String selectedManagementPage = "Sales Orders";

class Reports extends StatefulWidget {
  static const routeName = '/reportsPage';
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  Future<void> fetchSalesOrder() async {
    final response = await supabase.from('salesOrder').select('*');

    if (!mounted) return;
    setState(() {
      salesOrderList = response
          .map<Map<String, dynamic>>((salesOrder) => {
                'salesOrder_id': salesOrder['salesOrder_id'],
                'custName': salesOrder['custName'],
                'salesOrderDate': salesOrder['date'].toString(),
                'status': salesOrder['status'],
                'deliveryAdd': salesOrder['deliveryAdd'],
              })
          .toList();
    });
  }

  Future<void> fetchHaulingAdvice() async {
    final response = await supabase
        .from('haulingAdvice')
        .select('*, Truck!inner(plateNumber)');

    if (!mounted) return;
    setState(() {
      haulingAdviceList = response
          .map<Map<String, dynamic>>((hA) => {
                'date': hA['date'],
                'haulingAdviceId': hA['haulingAdviceId'],
                'volumeDel': hA['volumeDel'],
                'loadtype': hA['loadtype'],
                'pickUp': hA['pickUpAdd'],
                'supplier': hA['supplier'],
                'salesOrderID': hA['salesOrder_id'],
                'plateNumber': hA['Truck']['plateNumber'],
              })
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSalesOrder();
    fetchHaulingAdvice();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: buildReports(screenWidth, screenHeight, context),
        label: 'Reports');
  }

  Widget buildReports(
      double screenWidth, double screenHeight, BuildContext context) {
    switch (selectedManagementPage) {
      case 'Sales Orders':
        return allSalesOrders(context);
      case 'Hauling Advices':
        return allHaulingAdvice(context);

      default:
        return allSalesOrders(context);
    }
  }

  Scaffold allSalesOrders(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            DropdownButton<String>(
              dropdownColor: Colors.orangeAccent,
              elevation: 16,
              value: selectedManagementPage,
              onChanged: (String? newValue) {
                setState(() {
                  selectedManagementPage = newValue!;
                });
              },
              items: <String>['Sales Orders', 'Hauling Advices']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                            child: Text('Date',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Sales Order ID',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Customer',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Delivery Address',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Status',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    // Generate rows dynamically based on filtered data
                    ...salesOrderList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final salesOrder = entry.value;

                      return TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${salesOrder['salesOrderDate']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${salesOrder['salesOrder_id']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${salesOrder['custName']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${salesOrder['deliveryAdd']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${salesOrder['status']}'),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold allHaulingAdvice(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            DropdownButton<String>(
              dropdownColor: Colors.orangeAccent,
              elevation: 16,
              value: selectedManagementPage,
              onChanged: (String? newValue) {
                setState(() {
                  selectedManagementPage = newValue!;
                });
              },
              items: <String>['Sales Orders', 'Hauling Advices']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                            child: Text('Date',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Hauling Advice ID',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Sales Order ID',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Supplier',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Pick-up Address',
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
                            child: Text('Volume Delivered',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    // Generate rows dynamically based on filtered data
                    ...haulingAdviceList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final hA = entry.value;

                      return TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${hA['date']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${hA['haulingAdviceId']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${hA['salesOrderID']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${hA['supplier']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${hA['pickUp']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${hA['loadtype']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${hA['volumeDel']}'),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
