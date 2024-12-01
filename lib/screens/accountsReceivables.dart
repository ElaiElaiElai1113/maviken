import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/layoutBuilderPage.dart';

import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:printing/printing.dart';

class HaulingAdvice {
  final String adviceDetail;

  HaulingAdvice({required this.adviceDetail});

  static HaulingAdvice fromJson(Map<String, dynamic> json) {
    return HaulingAdvice(
      adviceDetail: json['adviceDetail'] ?? '',
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    accountsReceivable.sort((a, b) {
      if (a.paid && !b.paid) return 1;
      if (!a.paid && b.paid) return -1;
      return 0;
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
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(paymentController.text);
              if (amount != null && amount > 0 && selectedDate != null) {
                await addPayment(account, amount, selectedDate!);
                paymentController.clear();
                setState(() {
                  selectedDate = null;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Please enter a valid positive amount and select a date.'),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
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
        label: "Monitoring");
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
