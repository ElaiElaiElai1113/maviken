import 'package:flutter/material.dart';
<<<<<<< Updated upstream

import 'package:maviken/screens/profile_trucks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
=======
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
>>>>>>> Stashed changes
import 'dart:math';

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class AccountReceivable {
  final String custName;
  final String deliveryAdd;
  final int id;
  final double salesOrderId;
  final double totalAmount;
  final double amountPaids;
  final DateTime dateBilled;
  final List<AmountPaid> amountPaid;
  List<HaulingAdvice> haulingAdvices;
  bool paid;

  AccountReceivable({
    required this.id,
    required this.custName,
    required this.deliveryAdd,
    required this.salesOrderId,
    required this.totalAmount,
    required this.dateBilled,
    required this.amountPaids,
    required this.amountPaid,
    this.haulingAdvices = const [],
    required this.paid,
  });

  factory AccountReceivable.fromJson(Map<String, dynamic> json) {
    return AccountReceivable(
      id: json['billingNo'],
      custName: json['custName'] ?? '',
      deliveryAdd: json['salesOrder']['deliveryAdd'],
      salesOrderId: json['salesOrder_id'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      dateBilled: json['billingDate'] != null
          ? DateTime.parse(json['billingDate'])
          : DateTime.now(),
      amountPaids: (json['amountPaid'] ?? 0).toDouble(),
      amountPaid: json['amountPaid'] is List
          ? (json['amountPaid'] as List<dynamic>)
              .map((e) => AmountPaid.fromJson(e))
              .toList()
          : [],
      paid: json['paid'] ?? false,
      haulingAdvices: (json['salesOrder']['haulingAdvice'] as List<dynamic>?)
              ?.map((advice) => HaulingAdvice.fromJson(advice))
              .toList() ??
          [],
    );
  }
}

class AmountPaid {
  final double amountPaid;
  final DateTime paymentDate;

  AmountPaid({
    required this.amountPaid,
    required this.paymentDate,
  });

  factory AmountPaid.fromJson(Map<String, dynamic> json) {
    return AmountPaid(
      amountPaid: json['amountPaid'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
    );
  }
}

class HaulingAdvice {
  final double volumeDelivered;
  final String loadType;
  final String date;
  final String plateNumber;
  final double price; // Store individual price

  HaulingAdvice({
    required this.volumeDelivered,
    required this.loadType,
    required this.date,
    required this.plateNumber,
    required this.price, // Use a single price
  });

  factory HaulingAdvice.fromJson(Map<String, dynamic> json) {
    final truckData = json['Truck'] ?? {};
    final plateNumber = truckData['plateNumber'] ?? 'Unknown';

    // Extract price from salesOrderLoad
<<<<<<< Updated upstream
    final salesOrderLoad = json['salesOrderLoad'];
    double price = 0.0;

    // Collect price from salesOrderLoad
    if (salesOrderLoad is List && salesOrderLoad.isNotEmpty) {
      price = (salesOrderLoad[0]['price'] ?? 0).toDouble();
    } else if (salesOrderLoad is Map) {
      price = (salesOrderLoad['price'] ?? 0).toDouble();
=======
    double price = 0.0;
    if (json['salesOrderLoad'] != null) {
      price = (json['salesOrderLoad']['price'] ?? 0).toDouble();
>>>>>>> Stashed changes
    }

    return HaulingAdvice(
      volumeDelivered: json['volumeDel']?.toDouble() ?? 0.0,
      loadType: json['loadtype'] ?? 'Unknown',
      date: json['date'] ?? 'Unknown',
      plateNumber: plateNumber,
      price: price, // Set the price
    );
  }
}

class AccountsReceivables extends StatefulWidget {
  static const routeName = '/accountsreceivable';

  const AccountsReceivables({super.key});

  @override
  _AccountsReceivablesState createState() => _AccountsReceivablesState();
}

class _AccountsReceivablesState extends State<AccountsReceivables> {
  List<Map<String, dynamic>> haulingAdviceList = [];
  List<AccountReceivable> accountsReceivable = [];
  final paymentController = TextEditingController();
  DateTime? selectedDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
<<<<<<< Updated upstream
    fetchAccountsReceivableWithPrice(); // Fetch data with price
  }
=======
    fetchAccountsReceivableWithPrice();
  }

  Future<void> showHaulingAdviceDialog(
      BuildContext context, AccountReceivable account) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
>>>>>>> Stashed changes

    try {
      final response = await Supabase.instance.client
          .from('haulingAdvice')
          .select(
              '*, Truck(plateNumber), salesOrderLoad(price)') // Ensure proper inner join
          .eq('salesOrder_id', account.salesOrderId);

      if (response != null && response is List) {
        final haulingAdvices =
            response.map((data) => HaulingAdvice.fromJson(data)).toList();

        final groupedData = _groupHaulingAdvicesByLoadType(haulingAdvices);
        final totalAmount = _calculateTotalAmount(haulingAdvices);

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:
                  Center(child: Text('Hauling Advice for ${account.custName}')),
              content: SizedBox(
                width: screenWidth * .80,
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...groupedData.entries.map((entry) {
                          final loadType = entry.key;
                          final advices = entry.value;
                          final subtotal = _calculateSubtotal(advices);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Center(
                                  child: Text(
                                    'Load Type: $loadType',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: _buildDataColumns(),
                                  rows: _buildDataRows(advices),
                                ),
                              ),
                              SizedBox(
                                child: Center(
                                  child: Text(
                                    'Subtotal: ₱${subtotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                              Divider(),
                              SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                        Divider(),
                        SizedBox(
                          child: Center(
                            child: Text(
                              'Total Amount: ₱${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        _showSnackBar(
            'No hauling advice found for this sales order.', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Error fetching hauling advice: $e', Colors.red);
    }
  }

  Map<String, List<HaulingAdvice>> _groupHaulingAdvicesByLoadType(
      List<HaulingAdvice> haulingAdvices) {
    final Map<String, List<HaulingAdvice>> groupedData = {};

    for (var advice in haulingAdvices) {
      if (!groupedData.containsKey(advice.loadType)) {
        groupedData[advice.loadType] = [];
      }
      groupedData[advice.loadType]!.add(advice);
    }

    return groupedData;
  }

<<<<<<< Updated upstream
  void generateInvoice(AccountReceivable account) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice for ${account.custName}',
                  style: pw.TextStyle(fontSize: 24)),
              pw.Text('Billing No: ${account.id}'),
              pw.Text(
                  'Total Amount: ₱${account.totalAmount.toStringAsFixed(2)}'),
              pw.Text('Paid: ₱${account.amountPaids.toStringAsFixed(2)}'),
              pw.Text(
                  'Outstanding: ₱${calculateOutstanding(account).toStringAsFixed(2)}'),
              pw.Divider(),
              pw.Text('Hauling Advice Details:'),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Volume Delivered',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Load Type',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Plate Number',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Date',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ]),
                  ...account.haulingAdvices.map((advice) {
                    return pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child:
                            pw.Text(advice.volumeDelivered.toStringAsFixed(2)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(advice.loadType),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(advice.plateNumber),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(advice.date),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(advice.price.toStringAsFixed(2)),
                      ),
                    ]);
                  }).toList(),
                ],
              ),
              pw.Divider(),
              pw.Text(
                  'Total Amount: ${account.totalAmount.toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );

    final pdfData = await pdf.save();
    savePdfWeb(pdfData, 'invoice.pdf');
  }

  double calculateOutstanding(AccountReceivable account) {
    return account.totalAmount - account.amountPaids;
=======
  double _calculateSubtotal(List<HaulingAdvice> advices) {
    return advices.fold(
        0.0, (sum, advice) => sum + (advice.price * advice.volumeDelivered));
  }

  double _calculateTotalAmount(List<HaulingAdvice> advices) {
    return advices.fold(
        0.0, (sum, advice) => sum + (advice.price * advice.volumeDelivered));
  }

  List<DataColumn> _buildDataColumns() {
    return const [
      DataColumn(label: Text('Volume Delivered')),
      DataColumn(label: Text('Load Type')),
      DataColumn(label: Text('Date')),
      DataColumn(label: Text('Plate Number')),
      DataColumn(label: Text('Price')),
    ];
  }

  List<DataRow> _buildDataRows(List<HaulingAdvice> haulingAdvices) {
    return haulingAdvices.map((advice) {
      return DataRow(cells: [
        DataCell(Text(advice.volumeDelivered.toStringAsFixed(2))),
        DataCell(Text(advice.loadType)),
        DataCell(Text(advice.date)),
        DataCell(Text(advice.plateNumber)),
        DataCell(Text(
            '₱${(advice.price * advice.volumeDelivered).toStringAsFixed(2)}')),
      ]);
    }).toList();
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
>>>>>>> Stashed changes
  }

  Future<void> fetchAccountsReceivableWithPrice() async {
    try {
      final response =
          await Supabase.instance.client.from('accountsReceivables').select(
        '''
        *,
        salesOrder!inner(
          *,
          haulingAdvice(
            *,
<<<<<<< Updated upstream
            Truck(plateNumber),
            salesOrderLoad!inner(price)
          )
        )
        ''',
=======
            Truck!inner(plateNumber),
            salesOrderLoad!inner(price)
          )
        )
      ''',
>>>>>>> Stashed changes
      );

      setState(() {
        accountsReceivable = (response as List<dynamic>).map((e) {
          print('Fetched account with price: $e'); // Debug statement
          return AccountReceivable.fromJson(e);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateIsPaid(AccountReceivable account, bool paid) async {
    try {
      await Supabase.instance.client
          .from('accountsReceivables')
          .update({'paid': paid}).eq('billingNo', account.id);

      setState(() {
        account.paid = paid;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> addAmountPaid(AccountReceivable account, double amountPaid,
      DateTime paymentDate) async {
    try {
      await Supabase.instance.client.from('accountsReceivables').update({
        'amountPaid': amountPaid,
        'paymentDate': paymentDate.toIso8601String(),
      }).eq('billingNo', account.id);

      setState(() {
        account.amountPaid.add(
          AmountPaid(
            amountPaid: amountPaid,
            paymentDate: paymentDate,
          ),
        );
        fetchAccountsReceivableWithPrice();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double calculateOutstanding(AccountReceivable account) {
    return account.totalAmount - account.amountPaids;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
      page: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildAccountsList(screenWidth, screenHeight),
      label: 'Invoices',
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );
  }

  Widget buildAccountsList(double screenWidth, double screenHeight) {
    accountsReceivable.sort((a, b) => a.paid ? 1 : -1);

    return ListView.builder(
      itemCount: accountsReceivable.length,
      itemBuilder: (context, index) {
        final account = accountsReceivable[index];
        return Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ExpansionTile(
            title: Text(
              account.custName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orangeAccent),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          'Total: ₱${account.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        flex: 2,
                        child: Text(
                          'Date Billed: ${_formatDate(account.dateBilled)}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        flex: 1,
                        child: CheckboxListTile(
                          title: Text('Paid: ${account.paid ? "Yes" : "No"}'),
                          value: account.paid,
                          onChanged: (value) {
                            if (value != null) {
                              updateIsPaid(account, value);
                            }
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Text(
                          'Paid: ₱${account.amountPaids}',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Text(
                            'Outstanding: ₱${calculateOutstanding(account).toStringAsFixed(2)}'),
                      ),
                      Flexible(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () =>
                              showHaulingAdviceDialog(context, account),
                          child: const Text(
                            'View Hauling Advice',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            children: [
              ...account.haulingAdvices.map<Widget>((haulingAdvice) {
                return ListTile();
              }).toList(),
              Column(
                children: [
                  ...account.amountPaid.map<Widget>((payment) {
                    return ListTile(
                      title: Text('Partial Payment: ₱${payment.amountPaid}'),
                      subtitle: Text(
                          'Payment Date: ${_formatDate(payment.paymentDate)}'),
                    );
                  }).toList(),
                  _buildPaymentForm(account),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentForm(AccountReceivable account) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 3,
                child: TextFormField(
                  controller: paymentController,
                  decoration: const InputDecoration(labelText: 'Amount Paid'),
                  keyboardType: TextInputType.number,
                ),
              ),
              Flexible(
                flex: 2,
                child: Text(
                  'Payment Date: ${selectedDate != null ? _formatDate(selectedDate!) : 'Select a date'}',
                ),
              ),
              Flexible(
                flex: 1,
                child: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: const Text('Select Date'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final amountPaid = double.tryParse(paymentController.text);
                  if (amountPaid != null && selectedDate != null) {
                    await addAmountPaid(account, amountPaid, selectedDate!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Please enter a valid amount and select a date.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Add Payment',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
