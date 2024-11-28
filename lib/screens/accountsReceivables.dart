import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:maviken/screens/profile_trucks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'dart:typed_data';
import 'dart:html' as html;
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
  final DateTime? paymentDate; // Add this field
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
    this.paymentDate, // Initialize this field
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

class HaulingAdvice {
  final double volumeDelivered;
  final String loadType;
  final String date;
  final String plateNumber;
  final double price;

  HaulingAdvice({
    required this.volumeDelivered,
    required this.loadType,
    required this.date,
    required this.plateNumber,
    required this.price,
  });

  static HaulingAdvice fromJson(Map<String, dynamic> json) {
    final truckData = json['Truck'] ?? {};
    final plateNumber = truckData['plateNumber'] ?? 'N/A';

    final salesOrderLoad = json['salesOrderLoad'];
    double price = 0.0;

    if (salesOrderLoad is List && salesOrderLoad.isNotEmpty) {
      price = (salesOrderLoad[0]['price'] ?? 0).toDouble();
    } else if (salesOrderLoad is Map) {
      price = (salesOrderLoad['price'] ?? 0).toDouble();
    }

    return HaulingAdvice(
      volumeDelivered: json['volumeDel']?.toDouble() ?? 0.0,
      loadType: json['loadtype'] ?? 'Unknown',
      date: json['date'] ?? 'Unknown',
      plateNumber: plateNumber,
      price: price,
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
  List<Map<String, dynamic>> haulingAdviceList = [];
  List<AccountReceivable> accountsReceivable = [];
  final paymentController = TextEditingController();
  DateTime? selectedDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAccountsReceivableWithPrice();
  }

  pw.Table buildHaulingAdviceTable(List<HaulingAdvice> advices) {
    return pw.Table(
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
        ...advices.map((advice) {
          return pw.TableRow(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(advice.volumeDelivered.toStringAsFixed(2)),
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
              child: pw.Text(
                  (advice.price * advice.volumeDelivered).toStringAsFixed(2)),
            ),
          ]);
        }).toList(),
      ],
    );
  }

  Future<void> showHaulingAdviceDialog(AccountReceivable account) async {
    try {
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
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Volume Delivered')),
                      DataColumn(label: Text('Load Type')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Plate Number')),
                    ],
                    rows: haulingAdvices
                        .map(
                          (advice) => DataRow(cells: [
                            DataCell(Text(
                                advice.volumeDelivered.toStringAsFixed(2))),
                            DataCell(Text(advice.loadType)),
                            DataCell(Text(advice.date)),
                            DataCell(Text(advice.plateNumber)),
                          ]),
                        )
                        .toList(),
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

  String convertAmountToWords(double amount) {
    final List<String> ones = [
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
    final List<String> teens = [
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
    final List<String> tens = [
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
    final List<String> thousands = [
      '',
      'Thousand',
      'Million',
      'Billion',
      'Trillion'
    ];

    if (amount == 0) return 'Zero';

    String numberToWords(int num) {
      if (num == 0) return '';
      if (num < 10) return ones[num];
      if (num < 20) return teens[num - 10];
      if (num < 100) {
        return tens[num ~/ 10] + (num % 10 > 0 ? ' ${ones[num % 10]}' : '');
      }
      if (num < 1000) {
        return '${ones[num ~/ 100]} Hundred' +
            (num % 100 > 0 ? ' ${numberToWords(num % 100)}' : '');
      }

      for (int i = 0; i < thousands.length; i++) {
        int unit = pow(1000, i).toInt();
        if (num < unit * 1000) {
          return '${numberToWords(num ~/ unit)} ${thousands[i]}' +
              (num % unit > 0 ? ' ${numberToWords(num % unit)}' : '');
        }
      }

      throw Exception('Number too large');
    }

    int integerPart = amount.floor();
    int fractionalPart = ((amount - integerPart) * 100).round();

    String integerWords = numberToWords(integerPart);
    String fractionalWords = fractionalPart > 0
        ? '${numberToWords(fractionalPart)} Cent${fractionalPart > 1 ? 's' : ''}'
        : '';

    return fractionalWords.isNotEmpty
        ? '$integerWords Pesos and $fractionalWords Only'
        : '$integerWords Pesos Only';
  }

  void generateInvoice(AccountReceivable account) async {
    final pdf = pw.Document();

    final ByteData bytes = await rootBundle.load('lib/assets/mavikenlogo1.png');
    final Uint8List logo = bytes.buffer.asUint8List();

    // Debug print to check if haulingAdvices are populated
    print('Hauling Advices: ${account.haulingAdvices}');

    account.haulingAdvices.sort((a, b) => a.date.compareTo(b.date));

    final Map<String, List<HaulingAdvice>> groupedByLoadType = {};
    for (var advice in account.haulingAdvices) {
      if (!groupedByLoadType.containsKey(advice.loadType)) {
        groupedByLoadType[advice.loadType] = [];
      }
      groupedByLoadType[advice.loadType]!.add(advice);
    }

    // Debug print to check if groupedByLoadType is populated
    print('Grouped By Load Type: $groupedByLoadType');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(pw.MemoryImage(logo), width: 500, height: 80),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text('Customer:',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 10),
                  pw.Text('${account.custName}',
                      style: pw.TextStyle(fontSize: 18)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Text('Billing No:',
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 10),
                      pw.Text('${account.id}',
                          style: const pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Text('Date:',
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 10),
                      pw.Text('${_formatDate(account.dateBilled)}',
                          style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text('Delivery Address:',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 10),
                  pw.Text('${account.deliveryAdd}',
                      style: pw.TextStyle(fontSize: 18)),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              buildHaulingAdviceTable(account.haulingAdvices),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    'Total Amount: Php ${account.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Received by: _______________",
                  ),
                  pw.Text(
                    "Date: __________",
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Noted by: Vince S. Fernandez",
                  ),
                  pw.Text(
                    "Prepared by: Ethel Grace M. Martil",
                  ),
                ],
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
                Truck(plateNumber),
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
        'amountPaid': account.amountPaids + amountPaid,
        'paymentDate': paymentDate.toIso8601String(),
      }).eq('billingNo', account.id);

      setState(() {
        account.amountPaid.add(
          AmountPaid(
            amountPaid: amountPaid,
            paymentDate: paymentDate,
          ),
        );
        fetchAccountsReceivableWithPrice(); // Refresh the data
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
                        flex: 2,
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
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paid: ₱${account.amountPaids}',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Payment Date: ${account.paymentDate != null ? _formatDate(account.paymentDate!) : 'N/A'}',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Balance: ₱${calculateOutstanding(account).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () => showHaulingAdviceDialog(account),
                          child: const Text(
                            'Hauling Advices',
                            style: TextStyle(
                                fontSize: 12,
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
              Column(
                children: [
                  ...account.amountPaid.map<Widget>((payment) {
                    return ListTile(
                      title: Text(
                          'Partial Payment: ₱${payment.amountPaid.toStringAsFixed(2)}'),
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
                flex: 2,
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final amountPaid = double.tryParse(paymentController.text);
                  if (amountPaid != null &&
                      amountPaid > 0 &&
                      selectedDate != null) {
                    await addAmountPaid(account, amountPaid, selectedDate!);
                    paymentController.clear();
                    setState(() {
                      selectedDate = null;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Please enter a valid positive amount and select a date.'),
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
              ElevatedButton(
                onPressed: () {
                  generateInvoice(account);
                },
                child: const Text(
                  'Generate Invoice',
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
