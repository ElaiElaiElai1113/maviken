import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart'; // Replace with the actual path
import 'package:supabase_flutter/supabase_flutter.dart'; // For Supabase integration

class Payroll extends StatefulWidget {
  static const routeName = '/payRoll';

  const Payroll({super.key});

  @override
  State<Payroll> createState() => _PayrollState();
}

class _PayrollState extends State<Payroll> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> payrollLog = [];

  @override
  void initState() {
    super.initState();
    fetchPayrollData();
  }

  Future<void> fetchPayrollData() async {
    final response = await supabase.from('payroll').select();
    if (response == null) {
      setState(() {
        payrollLog = List<Map<String, dynamic>>.from(response);
      });
    } else {
      print('Error fetching payroll data: ${response}');
    }
  }

  Future<void> resolvePayrollEntry(int payrollID) async {
    final response = await supabase
        .from('payroll')
        .update({'status': 'Resolved'}) // Example field
        .eq('id', payrollID);

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payroll entry resolved!')),
      );
      fetchPayrollData();
    } else {
      print('Error resolving payroll entry: ${response.error!.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      page: payrollPage(context),
      label: "Payroll Management",
    );
  }

  SizedBox payrollPage(BuildContext context) {
    return SizedBox(
      child: Table(
        border: TableBorder.all(color: Colors.black),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header
          const TableRow(
            decoration: BoxDecoration(color: Colors.orangeAccent),
            children: [
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Date', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text('Insurance', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Bonus', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('SSS', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text('Pag-IBIG', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text('PhilHealth', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Total', style: TextStyle(color: Colors.white)),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Action', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          // Dynamic Rows
          ...payrollLog.asMap().entries.map((entry) {
            final index = entry.key;
            final payroll = entry.value;

            return TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${payroll['dateGiven']}'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${payroll['insurance']}'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${payroll['bonus']}'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${payroll['sss']}'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${payroll['pagibig']}'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${payroll['philHealth']}'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${payroll['total']}'),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: payroll['status'] == 'Resolved'
                          ? null
                          : () => resolvePayrollEntry(payroll['id']),
                      child: Text(payroll['status'] == 'Resolved'
                          ? 'Resolved'
                          : 'Resolve'),
                    ),
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
