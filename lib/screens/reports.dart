import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
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
  List<Map<String, dynamic>> filteredSalesOrderList = [];
  List<Map<String, dynamic>> filteredHaulingAdviceList = [];

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchSalesOrder();
    fetchHaulingAdvice();
    searchController.addListener(() {
      filterData();
    });
  }

  void filterData() {
    final searchQuery = searchController.text.toLowerCase();

    setState(() {
      // Filter Sales Orders
      filteredSalesOrderList = salesOrderList.where((order) {
        final orderDate = DateTime.parse(order['salesOrderDate']);
        bool withinDateRange =
            (startDate == null || orderDate.isAfter(startDate!)) &&
                (endDate == null ||
                    orderDate.isBefore(endDate!.add(Duration(days: 1))));
        return (order['salesOrder_id'].toString().contains(searchQuery) ||
                order['custName'].toLowerCase().contains(searchQuery) ||
                order['salesOrderDate'].toLowerCase().contains(searchQuery) ||
                order['status'].toLowerCase().contains(searchQuery) ||
                order['deliveryAdd'].toLowerCase().contains(searchQuery)) &&
            withinDateRange;
      }).toList();

      // Filter Hauling Advice
      filteredHaulingAdviceList = haulingAdviceList.where((haulingAdvice) {
        final adviceDate = DateTime.parse(haulingAdvice['date']);
        bool withinDateRange =
            (startDate == null || adviceDate.isAfter(startDate!)) &&
                (endDate == null ||
                    adviceDate.isBefore(endDate!.add(Duration(days: 1))));
        return (haulingAdvice['haulingAdviceId']
                    .toString()
                    .contains(searchQuery) ||
                haulingAdvice['date']
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery) ||
                haulingAdvice['salesOrderID']
                    .toString()
                    .contains(searchQuery) ||
                haulingAdvice['supplier'].toLowerCase().contains(searchQuery) ||
                haulingAdvice['pickUp'].toLowerCase().contains(searchQuery) ||
                haulingAdvice['loadtype'].toLowerCase().contains(searchQuery) ||
                haulingAdvice['volumeDel'].toString().contains(searchQuery)) &&
            withinDateRange;
      }).toList();
    });
  }

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
      filteredSalesOrderList = salesOrderList; // Initially, show all data
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
      filteredHaulingAdviceList = haulingAdviceList;
    });
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
                  searchController.clear(); // Reset search field
                  startDate = null; // Clear date when switching pages
                  endDate = null; // Clear date when switching pages
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
            // Date Range Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedStartDate = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedStartDate != null) {
                      setState(() {
                        startDate = pickedStartDate;
                      });
                      filterData(); // Re-filter data after date selection
                    }
                  },
                  child: Text(startDate == null
                      ? 'Select Start Date'
                      : 'Start: ${DateFormat('MMMM d, y').format(startDate!)}'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedEndDate = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedEndDate != null) {
                      setState(() {
                        endDate = pickedEndDate;
                      });
                      filterData(); // Re-filter data after date selection
                    }
                  },
                  child: Text(endDate == null
                      ? 'Select End Date'
                      : 'End: ${DateFormat('MMMM d, y').format(endDate!)}'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      startDate = null; // Clear start date
                      endDate = null; // Clear end date
                    });
                    filterData(); // Re-filter data after clearing dates
                  },
                  child: const Text('Clear Dates'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
              ],
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
                    ...filteredSalesOrderList.map((salesOrder) {
                      return TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(DateFormat('MMMM d, y').format(
                                  DateTime.parse(
                                      salesOrder['salesOrderDate']))),
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
                  searchController.clear(); // Reset search field
                  startDate = null; // Clear date when switching pages
                  endDate = null; // Clear date when switching pages
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
            // Date Range Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedStartDate = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedStartDate != null) {
                      setState(() {
                        startDate = pickedStartDate;
                      });
                      filterData(); // Re-filter data after date selection
                    }
                  },
                  child: Text(startDate == null
                      ? 'Select Start Date'
                      : 'Start: ${DateFormat('MMMM d, y').format(startDate!)}'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedEndDate = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedEndDate != null) {
                      setState(() {
                        endDate = pickedEndDate;
                      });
                      filterData(); // Re-filter data after date selection
                    }
                  },
                  child: Text(endDate == null
                      ? 'Select End Date'
                      : 'End: ${DateFormat('MMMM d, y').format(endDate!)}'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      startDate = null; // Clear start date
                      endDate = null; // Clear end date
                    });
                    filterData(); // Re-filter data after clearing dates
                  },
                  child: const Text('Clear Dates'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
              ],
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
                    ...filteredHaulingAdviceList.map((haulingAdvice) {
                      return TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(DateFormat('MMMM d, y').format(
                                  DateTime.parse(haulingAdvice['date']))),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Text('${haulingAdvice['haulingAdviceId']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${haulingAdvice['salesOrderID']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${haulingAdvice['supplier']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${haulingAdvice['pickUp']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${haulingAdvice['loadtype']}'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${haulingAdvice['volumeDel']}'),
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
