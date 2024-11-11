import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/screens/profile_supplier.dart';

class Accountsreceivables extends StatefulWidget {
  static const routeName = '/accountsreceivable';

  const Accountsreceivables({Key? key}) : super(key: key);

  @override
  _AccountsReceivableState createState() => _AccountsReceivableState();
}

class _AccountsReceivableState extends State<Accountsreceivables> {
  final List<AccountReceivable> accountsReceivable = [
    AccountReceivable(
      custName: "Customer A",
      totalAmount: 5000.0,
      dateBilled: DateTime(2023, 5, 1),
      partialPayments: [
        PartialPayment(amountPaid: 3000.0, paymentDate: DateTime(2023, 5, 15)),
      ],
      isPaid: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
      page: buildAccountsList(screenWidth, screenHeight),
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
}

class PartialPayment {
  final double amountPaid;
  final DateTime paymentDate;

  PartialPayment({
    required this.amountPaid,
    required this.paymentDate,
  });
}
