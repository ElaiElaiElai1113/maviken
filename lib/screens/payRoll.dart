import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/screens/profiling.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For Supabase integration
import 'package:intl/intl.dart'; // For date formatting
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Payroll extends StatefulWidget {
  static const routeName = '/payRoll';

  const Payroll({super.key});

  @override
  State<Payroll> createState() => _PayrollState();
}

class _PayrollState extends State<Payroll> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pricing = [];
  List<Map<String, dynamic>> payrollLog = [];
  List<Map<String, dynamic>> employees = [];
  String? selectedEmployeeID;

  // Controllers for input fields
  final TextEditingController daysWorkedController = TextEditingController();
  final TextEditingController bonusController = TextEditingController();
  final TextEditingController sssController = TextEditingController();
  final TextEditingController pagibigController = TextEditingController();
  final TextEditingController philHealthController = TextEditingController();
  final TextEditingController miscController = TextEditingController();
  final TextEditingController deductionsController = TextEditingController();
  final TextEditingController ratePayDayController = TextEditingController();
  final TextEditingController dateGivenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPricing(); // Load the constant values
    fetchPayrollData();
    fetchEmployees();
    // fetchEmployeePositions(); // Ensure this is being called
  }

  double sssAmount = 0.0;
  double pagibigAmount = 0.0;
  double philHealthAmount = 0.0;

  Future<void> generatePayslipPDF(Map<String, dynamic> payroll) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Payslip', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Employee ID: ${payroll['employeeID']}'),
              pw.Text('Name: ${payroll['firstName']} ${payroll['lastName']}'),
              pw.Text('Date Given: ${payroll['dateGiven']}'),
              pw.Text('Days Worked: ${payroll['daysWorked']}'),
              pw.Text('Bonus: ${payroll['Bonus']}'),
              pw.Text('Misc: ${payroll['misc']}'),
              pw.Text('Gross Pay: ${payroll['grossPay']}'),
              pw.Text('SSS: ${payroll['SSS']}'),
              pw.Text('Pag-IBIG: ${payroll['pagIbig']}'),
              pw.Text('PhilHealth: ${payroll['philHealth']}'),
              pw.Text('Deductions: ${payroll['deductions']}'),
              pw.Text('Total Pay: ${payroll['total']}'),
            ],
          );
        },
      ),
    );

    // Print the PDF or save it
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<double> fetchHaulingAdvices(
      String driverID, DateTime startDate, DateTime endDate) async {
    try {
      final response = await supabase
          .from('haulingAdvice')
          .select('*')
          .eq('driverID', driverID) // Use driverID
          .gte('date',
              startDate.toIso8601String()) // Assuming date is in ISO format
          .lte('date', endDate.toIso8601String());

      if (response != null && response.isNotEmpty) {
        // Assuming the response contains a field that represents the amount
        double totalHaulingAdvice = 0.0;

        for (var advice in response) {
          // Replace 'amount' with the actual field name that contains the value you want to sum
          totalHaulingAdvice += advice['delnumber'] ??
              0.0; // Adjust this line based on your schema
        }

        // Multiply the total by 350
        double totalAmount = totalHaulingAdvice * 350;

        print(driverID);
        print(totalHaulingAdvice);

        return totalAmount;
      } else {
        print('No hauling advices found for the given date range.');
        return 0.0;
      }
    } catch (e) {
      print('Exception fetching hauling advices: $e');
      return 0.0;
    }
  }

  Future<void> fetchPricing() async {
    try {
      final response = await supabase.from('payRollConst').select('*');
      setState(() {
        pricing = response
            .map<Map<String, dynamic>>((price) => {
                  'payRollConstID': price['payRollConstID'],
                  'payRollConst': price['payRollConst'],
                  'amount': price['amount'],
                })
            .toList();

        for (var item in pricing) {
          switch (item['payRollConst']) {
            case 'SSS':
              sssAmount = item['amount'];
              break;
            case 'pagIbig':
              pagibigAmount = item['amount'];
              break;
            case 'philHealth':
              philHealthAmount = item['amount'];
              break;
          }
        }
      });
    } catch (e) {
      print('Exception fetching PayRollConst: $e');
    }
  }

  // Future<void> fetchEmployeePositions() async {
  //   final response = await supabase
  //       .from('employeePosition')
  //       .select('*'); // Fetch all positions
  //   if (response != null) {
  //     setState(() {
  //       // Store positions in a map for easy access
  //       employeePositions = Map.fromIterable(
  //         response,
  //         key: (item) =>
  //             item['positionID'].toString(), // Ensure the key is a String
  //         value: (item) {
  //           print(item); // Debug: print each item to ensure correct structure
  //           return item['positionName'] ??
  //               'Unknown Position'; // Handle case where positionName might be missing
  //         },
  //       );
  //     });
  //   } else {
  //     print('Error fetching employee positions.');
  //   }
  // }

  Future<void> fetchPayrollData() async {
    final response = await supabase.from('payRoll').select(
        '*, employee (firstName, lastName, positionID)'); // Fetching employee details
    if (response != null) {
      setState(() {
        payrollLog = List<Map<String, dynamic>>.from(response);
      });
    } else {
      print('Error fetching payroll data.');
    }
  }

  Future<void> addPayrollRecord(Map<String, dynamic> newRecord) async {
    final response = await supabase.from('payRoll').insert(newRecord);

    if (response == null) {
      print('Error: No response received from the server.');
      return;
    }

    if (response.error != null) {
      print('Error adding payroll record: ${response.error!.message}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payroll record added successfully!')),
      );
      fetchPayrollData(); // Refresh the data
    }
  }

  Future<void> resolvePayrollEntry(int payrollID) async {
    final response = await supabase
        .from('payRoll')
        .update({'status': 'Resolved'}).eq('id', payrollID);

    if (response == null) {
      print('Error: No response received from the server.');
      return;
    }

    if (response.error != null) {
      print('Error resolving payroll entry: ${response.error!.message}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payroll entry resolved!')),
      );
      fetchPayrollData();
    }
  }

  Future<void> fetchEmployees() async {
    final response = await supabase
        .from('employee')
        .select("*"); // Assuming 'employees' table holds employee details
    if (response != null) {
      setState(() {
        employees = List<Map<String, dynamic>>.from(response);
      });
    } else {
      print('Error fetching employees.');
    }
  }

  Future<void> fetchRatePerDay() async {
    try {
      final response = await supabase
          .from('employee')
          .select('*')
          .eq("employeeID", selectedEmployeeID as Object);

      setState(() {
        pricing = response
            .map<Map<String, dynamic>>((rate) => {
                  'ratePerDay': rate['ratePerDay'],
                })
            .toList();
      });
    } catch (e) {
      print('Exception fetching ratePerDay: $e');
    }
  }

  void showAddPayrollDialog() {
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    String? selectedEmployeeFirstName;
    String? selectedEmployeeLastName;
    sssController.text = sssAmount.toString();
    pagibigController.text = pagibigAmount.toString();
    philHealthController.text = philHealthAmount.toString();
    ratePayDayController.text = sssAmount.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Payroll Record'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedEmployeeID,
                  onChanged: (newValue) {
                    setState(() {
                      selectedEmployeeID = newValue;
                      fetchRatePerDay();
                      final selectedEmployee = employees.firstWhere(
                        (employee) =>
                            employee['employeeID'].toString() == newValue,
                        orElse: () => {},
                      );
                      selectedEmployeeFirstName = selectedEmployee['firstName'];
                      selectedEmployeeLastName = selectedEmployee['lastName'];
                    });
                  },
                  items: employees.map((employee) {
                    return DropdownMenuItem<String>(
                      value: employee['employeeID'].toString(),
                      child: Text(
                        '${employee['employeeID']} ${employee['firstName']} ${employee['lastName']}',
                      ),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Employee',
                  ),
                ),
                TextField(
                  controller: daysWorkedController,
                  decoration: const InputDecoration(labelText: 'Days Worked'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: startDateController,
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        startDateController.text =
                            "${selectedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
                TextField(
                  controller: endDateController,
                  decoration: const InputDecoration(labelText: 'End Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        endDateController.text =
                            "${selectedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
                TextField(
                  controller: bonusController,
                  decoration: const InputDecoration(labelText: 'Bonus'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: miscController,
                  decoration: const InputDecoration(labelText: 'Misc'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sssController,
                  decoration: const InputDecoration(labelText: 'SSS'),
                  readOnly: true, // Make the field non-editable
                ),
                TextField(
                  controller: pagibigController,
                  decoration: const InputDecoration(labelText: 'Pag-IBIG'),
                  readOnly: true, // Make the field non-editable
                ),
                TextField(
                  controller: philHealthController,
                  decoration: const InputDecoration(labelText: 'PhilHealth'),
                  readOnly: true, // Make the field non-editable
                ),
                TextField(
                  controller: deductionsController,
                  decoration: const InputDecoration(labelText: 'Deductions'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: dateGivenController,
                  decoration: const InputDecoration(labelText: 'Date Given'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        dateGivenController.text =
                            "${selectedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                double totalHaulingAmount = 0.0;

                // Only fetch hauling advice if both dates are provided
                if (startDateController.text.isNotEmpty &&
                    endDateController.text.isNotEmpty) {
                  DateTime? startDate =
                      DateTime.tryParse(startDateController.text);
                  DateTime? endDate = DateTime.tryParse(endDateController.text);

                  if (startDate != null && endDate != null) {
                    // Fetch hauling advices and get the total amount
                    totalHaulingAmount = await fetchHaulingAdvices(
                        selectedEmployeeID!, startDate, endDate);
                  }
                }

                // Now you can use totalHaulingAmount in your payroll calculations
                final bonus = double.tryParse(bonusController.text) ?? 0;
                final misc = double.tryParse(miscController.text) ?? 0;
                final deductions =
                    double.tryParse(deductionsController.text) ?? 0;
                double ratePerDay = pricing.isNotEmpty
                    ? double.tryParse(pricing[0]['ratePerDay'].toString()) ?? 0
                    : 0;

                final daysWorked = int.tryParse(daysWorkedController.text) ?? 0;
                final grossPay = ratePerDay * daysWorked +
                    bonus +
                    misc +
                    totalHaulingAmount; // Include totalHaulingAmount in gross pay calculation
                final total = grossPay -
                    deductions -
                    sssAmount -
                    pagibigAmount -
                    philHealthAmount;

                addPayrollRecord({
                  'employeeID': selectedEmployeeID,
                  'firstName': selectedEmployeeFirstName,
                  'lastName': selectedEmployeeLastName,
                  'Bonus': bonus,
                  'SSS': sssAmount,
                  'pagIbig': pagibigAmount,
                  'philHealth': philHealthAmount,
                  'misc': misc,
                  'ratePerDay': ratePerDay,
                  'daysWorked': daysWorked,
                  'grossPay': grossPay,
                  'deductions': deductions,
                  'total': total,
                  'dateGiven': dateGivenController.text,
                });

                // Clear the fields and close the dialog
                bonusController.clear();
                miscController.clear();
                deductionsController.clear();
                dateGivenController.clear();
                startDateController.clear();
                endDateController.clear();
                Navigator.of(context).pop();

                fetchPricing(); // Load the constant values
                fetchPayrollData();
                fetchEmployees();
              },
              child: const Text('Add'),
            )
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
      page: Column(
        children: [
          ElevatedButton(
            onPressed: showAddPayrollDialog,
            child: const Text('Add Payroll Record'),
          ),
          Expanded(child: payrollPage(context)),
        ],
      ),
      label: "Payroll Management",
    );
  }

  SizedBox payrollPage(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Expanded(
            child: Table(
              border: TableBorder.all(color: Colors.black),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header Row
                const TableRow(
                  decoration: BoxDecoration(color: Colors.orangeAccent),
                  children: [
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Employee ID',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('First Name',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Last Name',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Payslip Date',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Bonus',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Misc',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Gross Pay',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('SSS',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Pag-IBIG',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('PhilHealth',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Deductions',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Total Pay',
                                style: TextStyle(color: Colors.white)))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Generate Payslip',
                                style: TextStyle(color: Colors.white)))),
                  ],
                ),
                // Payroll Data Rows
                ...payrollLog.map((payroll) {
                  return TableRow(
                    children: [
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['employeeID'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['firstName'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['lastName'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['dateGiven'] ?? '-'))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['Bonus'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['misc'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['grossPay'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['SSS'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['pagIbig'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['philHealth'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['deductions'].toString()))),
                      TableCell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(payroll['total'].toString()))),
                      TableCell(
                        child: IconButton(
                          icon: Icon(Icons.picture_as_pdf),
                          onPressed: () {
                            // Pass the specific payroll record to generate the PDF
                            generatePayslipPDF(payroll);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
