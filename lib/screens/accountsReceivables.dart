import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class AccountReceivable {
  final String custName;
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
      haulingAdvices: json['haulingAdvice'] is List
          ? (json['haulingAdvice'] as List<dynamic>)
              .map((e) => HaulingAdvice.fromJson(e))
              .toList()
          : [],
      paid: json['paid'] ?? false,
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
          : DateTime.now(), // Provide a default value if null
    );
  }
}

class HaulingAdvice {
  final double volumeDelivered;

  HaulingAdvice({
    required this.volumeDelivered,
  });

  factory HaulingAdvice.fromJson(Map<String, dynamic> json) {
    return HaulingAdvice(
      volumeDelivered: json['volumeDel'],
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
    fetchAccountsReceivable();
  }

  Future<void> showHaulingAdviceDialog(AccountReceivable account) async {
    try {
      // Fetch hauling advice linked to this sales order (account).
      final response = await Supabase.instance.client
          .from('haulingAdvice')
          .select('*')
          .eq('salesOrder_id', account.salesOrderId);

      if (response != null && response is List) {
        final haulingAdvices =
            response.map((data) => HaulingAdvice.fromJson(data)).toList();

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Hauling Advice for ${account.custName}'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: haulingAdvices.length,
                  itemBuilder: (context, index) {
                    final advice = haulingAdvices[index];
                    return ListTile(
                      title: Text(
                          'Volume Delivered: ${advice.volumeDelivered.toStringAsFixed(2)}'),
                    );
                  },
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No hauling advice found for this sales order.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching hauling advice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void savePdfWeb(Uint8List pdfData, String filename) {
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = filename;
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }

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
              pw.Column(
                children: account.haulingAdvices.map((advice) {
                  return pw.Text(
                    'Volume: ${advice.volumeDelivered}',
                  );
                }).toList(),
              ),
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
  }

  Future<void> fetchHaulingAdvices() async {
    try {
      final response = await Supabase.instance.client
          .from('salesOrder')
          .select('*, haulingAdvice!inner(*)');

      setState(() {
        haulingAdviceList =
            response.map<Map<String, dynamic>>((haulingAdvice) => {}).toList();
      });

      print(response);
    } catch (e) {
      print('Error fetching hauling advices: $e');
    }
  }

  Future<void> fetchAccountsReceivable() async {
    try {
      final response = await Supabase.instance.client
          .from('accountsReceivables')
          .select('*');

      setState(() {
        accountsReceivable = (response as List<dynamic>)
            .map((e) => AccountReceivable.fromJson(e))
            .toList();
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
      final response = await Supabase.instance.client
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
      final response =
          await Supabase.instance.client.from('accountsReceivables').update({
        'amountPaid': amountPaid,
        'paymentDate': paymentDate.toIso8601String(),
      }).eq('billingNo', account.id);

      setState(() {
        fetchAccountsReceivable();
        account.amountPaid.add(
          AmountPaid(
            amountPaid: amountPaid,
            paymentDate: paymentDate,
          ),
        );
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
                        flex: 1,
                        child: Text(
                          'Total: \₱${account.totalAmount.toStringAsFixed(2)}',
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
                      ElevatedButton(
                        onPressed: () => showHaulingAdviceDialog(account),
                        child: const Text('View Hauling Advice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
                return ListTile(
                  title: Text(
                      'Hauling Advice - Volume: ${haulingAdvice.volumeDelivered}'),
                );
              }).toList(),
              Column(
                children: [
                  ...account.amountPaid.map<Widget>((payment) {
                    return ListTile(
                      title: Text('Partial Payment: \₱${payment.amountPaid}'),
                      subtitle: Text(
                          'Payment Date: ${_formatDate(payment.paymentDate)}'),
                    );
                  }).toList(),
                  _buildPaymentForm(account),
                  Text(
                      'Outstanding: ₱${calculateOutstanding(account).toStringAsFixed(2)}'),
                  ElevatedButton(
                    onPressed: () {
                      generateInvoice(account);
                      fetchHaulingAdvices();
                    },
                    child: const Text('Generate Invoice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                  ),
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
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              final amountPaid = double.tryParse(paymentController.text);
              if (amountPaid != null && selectedDate != null) {
                await addAmountPaid(account, amountPaid, selectedDate!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Please enter a valid amount and select a date.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Add Payment',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
            ),
          ),
        ],
      ),
    );
  }
}
