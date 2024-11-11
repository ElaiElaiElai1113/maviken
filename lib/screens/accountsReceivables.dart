import 'package:flutter/material.dart';
import 'package:maviken/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/layoutBuilderPage.dart';

class Accountsreceivables extends StatefulWidget {
  static const routeName = '/accountsreceivable';

  const Accountsreceivables({Key? key}) : super(key: key);

  @override
  _AccountsReceivableState createState() => _AccountsReceivableState();
}

class _AccountsReceivableState extends State<Accountsreceivables> {
  List<AccountReceivable> accountsReceivable = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAccountsReceivables();
  }

  //final datas = await supabase.from('salesOrder').select(

  Future<void> fetchAccountsReceivables() async {
    final data = await supabase.from('accountsReceivables').select("*");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
      page: isLoading
          ? Center(child: CircularProgressIndicator())
          : buildAccountsList(screenWidth, screenHeight),
      label: 'Account Receivable',
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );
  }

  Widget buildAccountsList(double screenWidth, double screenHeight) {
    return ListView.builder(
      itemCount: accountsReceivable.length,
      itemBuilder: (context, index) {
        final account = accountsReceivable[index];
        return Card(
          child: ExpansionTile(
            title: Text(account.custName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Total: \$${account.totalAmount.toStringAsFixed(2)}'),
                    const SizedBox(width: 16),
                    Text('Date Billed: ${_formatDate(account.dateBilled)}'),
                  ],
                ),
                CheckboxListTile(
                  title: Text('Paid: ${account.isPaid ? "Yes" : "No"}'),
                  value: account.isPaid,
                  onChanged: (value) {
                    setState(() => account.isPaid = value ?? false);
                  },
                ),
              ],
            ),
            children: [
              Column(
                children: [
                  ...account.partialPayments.map((payment) {
                    return ListTile(
                      title: Text('Partial Payment: \$${payment.amountPaid}'),
                      subtitle: Text(
                          'Payment Date: ${_formatDate(payment.paymentDate)}'),
                    );
                  }),
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
    final paymentController = TextEditingController();
    DateTime? selectedDate;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            controller: paymentController,
            decoration: InputDecoration(labelText: 'Amount Paid'),
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payment Date: ${selectedDate != null ? _formatDate(selectedDate!) : 'Select a date'}',
                ),
              ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
                child: Text('Select Date'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              final amountPaid = double.tryParse(paymentController.text);
              if (amountPaid != null && selectedDate != null) {
                setState(() {
                  account.partialPayments.add(
                    PartialPayment(
                        amountPaid: amountPaid, paymentDate: selectedDate!),
                  );
                });
              }
            },
            child: Text('Add Payment'),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class AccountReceivable {
  final String custName;
  final double totalAmount;
  final DateTime dateBilled;
  final List<PartialPayment> partialPayments;
  bool isPaid;

  AccountReceivable({
    required this.custName,
    required this.totalAmount,
    required this.dateBilled,
    required this.partialPayments,
    required this.isPaid,
  });

  factory AccountReceivable.fromJson(Map<String, dynamic> json) {
    return AccountReceivable(
      custName: json['custName'],
      totalAmount: json['totalAmount'],
      dateBilled: DateTime.parse(json['billingDate']),
      partialPayments: (json['partialPayments'] as List<dynamic>).map((e) {
        return PartialPayment.fromJson(e);
      }).toList(),
      isPaid: json['paid'],
    );
  }
}

class PartialPayment {
  final double amountPaid;
  final DateTime paymentDate;

  PartialPayment({
    required this.amountPaid,
    required this.paymentDate,
  });

  factory PartialPayment.fromJson(Map<String, dynamic> json) {
    return PartialPayment(
      amountPaid: json['amountPaid'],
      paymentDate: DateTime.parse(json['paymentDate']),
    );
  }
}
