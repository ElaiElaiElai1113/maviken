import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:math';
import 'package:printing/printing.dart';

class HaulingAdvice {
  final String adviceDetail;
  final String loadType;
  final double volumeDelivered;
  final String plateNumber;
  final DateTime date;
  final double price;

  HaulingAdvice({
    required this.adviceDetail,
    required this.loadType,
    required this.volumeDelivered,
    required this.plateNumber,
    required this.date,
    required this.price,
  });

  // Convert JSON to HaulingAdvice object
  static HaulingAdvice fromJson(Map<String, dynamic> json) {
    final truckData = json['Truck'] ?? {};
    final plateNumber = truckData['plateNumber'] ?? 'N/A';
    final salesOrderLoadData = json['salesOrderLoad'] ?? {};
    final price = salesOrderLoadData['price']?.toDouble() ?? 0.0;

    return HaulingAdvice(
      adviceDetail: json['adviceDetail'] ?? '',
      loadType: json['loadtype'] ?? '',
      volumeDelivered: json['volumeDel']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] ?? '1970-01-01'),
      price: price,
      plateNumber: plateNumber,
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String formatShortDate(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
}

class AccountReceivable {
  final String custName;
  final String deliveryAdd;
  final int id;
  final double salesOrderId;
  final double totalAmount;
  double amountPaids;
  final DateTime? paymentDate;
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
    this.paymentDate,
  });

  static AccountReceivable fromJson(Map<String, dynamic> json) {
    return AccountReceivable(
      id: json['billingNo'],
      custName: json['custName'] ?? '',
      deliveryAdd: json['salesOrder']['deliveryAdd'],
      salesOrderId: json['salesOrder_id'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
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

  DateTime? get latestPaymentDate {
    if (amountPaid.isEmpty) {
      return null; // No payments made
    }
    return amountPaid
        .map((payment) => payment.paymentDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

class AmountPaid {
  final double amountPaid;
  final DateTime paymentDate;

  AmountPaid({
    required this.amountPaid,
    required this.paymentDate,
  });

  static AmountPaid fromJson(Map<String, dynamic> json) {
    return AmountPaid(
      amountPaid: json['amountPaid'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
    );
  }
}

class PaymentHistory extends StatelessWidget {
  final List<AmountPaid> payments;

  PaymentHistory({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('No payment history available.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: payments.map((payment) {
        return ListTile(
          title: Text('Amount Paid: ₱${payment.amountPaid.toStringAsFixed(2)}'),
          subtitle: Text('Payment Date: ${_formatDate(payment.paymentDate)}'),
        );
      }).toList(),
    );
  }
}

class AccountsReceivables extends StatefulWidget {
  static const routeName = '/accountsreceivable';

  const AccountsReceivables({Key? key}) : super(key: key);

  @override
  _AccountsReceivablesState createState() => _AccountsReceivablesState();
}

class _AccountsReceivablesState extends State<AccountsReceivables> {
  List<AccountReceivable> accountsReceivable = [];
  final paymentController = TextEditingController();
  DateTime? selectedDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAccountsReceivableWithPrice();
  }

  Future<List<AmountPaid>> fetchPaymentHistory(String billingNo) async {
    try {
      final response = await Supabase.instance.client
          .from('arpayment')
          .select()
          .eq('billingNo', billingNo);

      // Parse response into a list of AmountPaid objects
      return (response as List<dynamic>).map((e) {
        return AmountPaid(
          amountPaid: e['amountPaid'],
          paymentDate: DateTime.parse(e['paymentDate']),
        );
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching payment history: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
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
            Truck!inner(plateNumber),
            salesOrderLoad!inner(price)
          )
        )
      ''',
      );

      setState(() {
        accountsReceivable = (response as List<dynamic>).map((e) {
          return AccountReceivable.fromJson(e);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data with price: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildAccountsList(double screenWidth, double screenHeight) {
    // Sort accountsReceivable by dateBilled in descending order
    accountsReceivable.sort((a, b) => b.dateBilled.compareTo(a.dateBilled));

    accountsReceivable.sort((a, b) {
      if (a.paid && !b.paid) return 1; // Paid accounts go to the bottom
      if (!a.paid && b.paid) return -1; // Unpaid accounts go to the top
      return 0; // Maintain relative order if both are paid or unpaid
    });

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
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orangeAccent),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Billing No: ${account.id}'),
                  Text(
                      'Total Amount: ₱${account.totalAmount.toStringAsFixed(2)}'),
                  Text('Paid: ${account.paid ? "Yes" : "No"}'),
                  Text(
                      'Balance: ₱${(account.totalAmount - account.amountPaids).toStringAsFixed(2)}'),
                ],
              ),
            ),
            children: [
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Payment History',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  // Dynamic Payment History from Database
                  FutureBuilder<List<AmountPaid>>(
                    future: fetchPaymentHistory(
                        account.id.toString()), // Fetch by billingNo
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No payments found.'),
                        );
                      }

                      // Build a list of payment history
                      final payments = snapshot.data!;
                      return Column(
                        children: payments.map((payment) {
                          return ListTile(
                            title: Text(
                                '₱${payment.amountPaid.toStringAsFixed(2)}'),
                            subtitle: Text(
                                'Payment Date: ${_formatDate(payment.paymentDate)}'),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  // Existing Payment Form
                  _buildPaymentForm(account),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Function to save the generated PDF for download in the browser
  void savePdfWeb(Uint8List pdfData, String filename) {
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = filename;
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }

  /// Function to convert a double amount into words (e.g., for total amounts in words)
  String convertAmountToWords(double amount) {
    final ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine'
    ];
    final teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];
    final thousands = ['', 'Thousand', 'Million', 'Billion', 'Trillion'];

    if (amount == 0) return 'Zero';

    String numberToWords(int num) {
      if (num == 0) return '';
      if (num < 10) return ones[num];
      if (num < 20) return teens[num - 10];
      if (num < 100)
        return '${tens[num ~/ 10]}${num % 10 > 0 ? ' ${ones[num % 10]}' : ''}';
      if (num < 1000) {
        return '${ones[num ~/ 100]} Hundred${num % 100 > 0 ? ' ${numberToWords(num % 100)}' : ''}';
      }

      for (int i = 0; i < thousands.length; i++) {
        final unit = pow(1000, i).toInt();
        if (num < unit * 1000) {
          return '${numberToWords(num ~/ unit)} ${thousands[i]}${num % unit > 0 ? ' ${numberToWords(num % unit)}' : ''}';
        }
      }

      throw Exception('Number too large');
    }

    final integerPart = amount.floor();
    final fractionalPart = ((amount - integerPart) * 100).round();

    final integerWords = numberToWords(integerPart);
    final fractionalWords = fractionalPart > 0
        ? '${numberToWords(fractionalPart)} Cent${fractionalPart > 1 ? 's' : ''}'
        : '';

    return fractionalWords.isNotEmpty
        ? '$integerWords Pesos and $fractionalWords Only'
        : '$integerWords Pesos Only';
  }

  /// Function to format dates for display
  String formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  Future<void> generateInvoice(AccountReceivable account) async {
    final pdf = pw.Document();

    // Load logo image
    final ByteData bytes = await rootBundle.load('lib/assets/mavikenlogo1.png');
    final Uint8List logo = bytes.buffer.asUint8List();

    // Group hauling advices by load type
    final groupedAdvices =
        _groupHaulingAdvicesByLoadType(account.haulingAdvices);

    // Fetch prices from salesOrderLoad table
    final response = await Supabase.instance.client
        .from('salesOrderLoad')
        .select('price')
        .eq('salesOrder_id', account.salesOrderId);
    final prices = response.map((load) => load['price']).toList();

    // Fetch payment history
    final paymentHistory = await fetchPaymentHistory(account.id.toString());

    // Calculate total payments made
    double totalPayments =
        paymentHistory.fold(0.0, (sum, payment) => sum + payment.amountPaid);

    // Calculate the remaining balance
    double remainingBalance = account.totalAmount - totalPayments;

    // Create PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(pw.MemoryImage(logo), width: 150, height: 50),
              pw.SizedBox(height: 20),
              pw.Text('Invoice',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Text('Customer Name: ${account.custName}'),
              pw.Text('Billing Number: ${account.id}'),
              pw.Text('Delivery Address: ${account.deliveryAdd}'),
              pw.Text('Date: ${formatDate(account.dateBilled)}'),
              pw.Divider(),
              pw.Text(
                'Hauling Advice Details',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              buildHaulingAdviceTable(groupedAdvices, prices),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    'Total Amount: ₱${account.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14)),
              ),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    'Total Payments: ₱${totalPayments.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14)),
              ),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    'Remaining Balance: ₱${remainingBalance.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14)),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Amount in Words: ${convertAmountToWords(account.totalAmount)}',
                style:
                    pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Payment History',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Amount Paid',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Payment Date',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...paymentHistory.map((payment) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                              '₱ ${payment.amountPaid.toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(formatShortDate(payment.paymentDate)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Prepared by: Vince S. Fernandez'),
            ],
          );
        },
      ),
    );

    // Save PDF
    final pdfData = await pdf.save();
    savePdfWeb(pdfData, 'invoice.pdf');
  }

  /// Build hauling advice table grouped by load type
  pw.Table buildHaulingAdviceTable(
      Map<String, List<HaulingAdvice>> groupedAdvices, List<dynamic> prices) {
    return pw.Table(
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Load Type',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Volume Delivered',
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
          ],
        ),
        ...groupedAdvices.entries.expand((entry) {
          final loadType = entry.key;
          final advices = entry.value;
          final subtotal = _calculateSubtotal(advices);

          return [
            pw.TableRow(children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text('$loadType',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
            ]),
            ...advices.map((advice) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text(loadType),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text(advice.volumeDelivered.toStringAsFixed(2)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text(advice.plateNumber),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text(formatShortDate(advice.date)),
                  ),
                  pw.Text(
                      '${(advice.price * advice.volumeDelivered).toStringAsFixed(2)}'),
                ],
              );
            })
            // .toList(),
            // pw.TableRow(children: [
            //   pw.Padding(
            //     padding: const pw.EdgeInsets.all(8.0),
            //     child: pw.Text(
            //       'Subtotal: ${subtotal.toStringAsFixed(2)}',
            //       style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            //     ),
            //   ),
            // ]),
          ];
        }),
      ],
    );
  }

  /// Group hauling advices by load type
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

  /// Calculate subtotal for hauling advices
  double _calculateSubtotal(List<HaulingAdvice> advices) {
    return advices.fold(
        0.0, (sum, advice) => sum + (advice.price * advice.volumeDelivered));
  }

  Widget _buildPaymentForm(AccountReceivable account) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: paymentController,
            decoration: InputDecoration(
              labelText: 'Enter Payment Amount',
              border: OutlineInputBorder(),
              errorText: _validatePaymentAmount(account),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Select Payment Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
              errorText: _validatePaymentDate(),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            controller: TextEditingController(
              text: selectedDate != null ? _formatDate(selectedDate!) : '',
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _validatePaymentAmount(account) == null
                    ? () async {
                        final amount = double.tryParse(paymentController.text);
                        if (amount != null && amount > 0) {
                          // Removed date check here
                          await addPayment(account, amount, selectedDate!);
                          paymentController.clear();
                          setState(() {
                            selectedDate = null;
                          });
                        }
                      }
                    : null, // Disable button if validation fails
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
              ElevatedButton(
                onPressed: () {
                  generateInvoice(account);
                },
                child: Text("Generate Invoice",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
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

  String? _validatePaymentAmount(AccountReceivable account) {
    final amount = double.tryParse(paymentController.text);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid positive amount.';
    } else if (amount > (account.totalAmount - account.amountPaids)) {
      return 'Payment cannot exceed the outstanding balance.';
    }
    return null; // No error
  }

  String? _validatePaymentDate() {
    // No validation needed for the payment date
    return null; // No error
  }

  Future<void> addPayment(
      AccountReceivable account, double amount, DateTime paymentDate) async {
    try {
      // Insert the new payment record into the arpayment table
      await Supabase.instance.client.from('arpayment').insert({
        'billingNo': account.id,
        'amountPaid': amount,
        'paymentDate': paymentDate.toIso8601String(),
      });

      // Update the account's amountPaid and paid status in accountsReceivables
      final updatedPaidStatus =
          account.amountPaids + amount >= account.totalAmount;
      await Supabase.instance.client.from('accountsReceivables').update({
        'amountPaid': account.amountPaids + amount,
        'paid': updatedPaidStatus,
      }).eq('billingNo', account.id);

      // Update local state
      setState(() {
        account.amountPaids += amount;
        account.paid = updatedPaidStatus;
        account.amountPaid
            .add(AmountPaid(amountPaid: amount, paymentDate: paymentDate));
      });

      await fetchAccountsReceivableWithPrice();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment added successfully'),
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
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: buildAccountsList(screenWidth, screenHeight),
        label: "Invoices");
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
