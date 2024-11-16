import 'package:flutter/material.dart';
import 'package:maviken/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/components/layoutBuilderPage.dart';

class Accountsreceivables extends StatefulWidget {
  static const routeName = '/accountsreceivable';

  const Accountsreceivables({super.key});

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
    final data = await Supabase.instance.client
        .from('accountsReceivables')
        .select("*, haulingAdvice(*)");

    print("Fetched data: $data");

    if (data != null && data is List) {
      accountsReceivable = data.map((json) {
        final account = AccountReceivable.fromJson(json);
        account.haulingAdvices = (json['haulingAdvice'] as List<dynamic>?)
                ?.map((ha) => HaulingAdvice.fromJson(ha))
                .toList() ??
            [];
        return account;
      }).toList();
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
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
    return ListView.builder(
      itemCount: accountsReceivable.length,
      itemBuilder: (context, index) {
        final account = accountsReceivable[index];
        return Card(
          child: ExpansionTile(
            title: Text(
              account.custName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orangeAccent),
            ),
            subtitle: Column(
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
                        title: Text('Paid: ${account.isPaid ? "Yes" : "No"}'),
                        value: account.isPaid,
                        onChanged: (value) {
                          setState(() => account.isPaid = value ?? false);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              ...account.haulingAdvices.map((haulingAdvice) {
                return ListTile(
                  title: Text(
                      'Hauling Advice - Volume: ${haulingAdvice.volumeDelivered}'),
                  subtitle: Text(
                      'Amount: \$${haulingAdvice.calculatedAmount.toStringAsFixed(2)}'),
                );
              }).toList(),
              Column(
                children: [
                  ...account.partialPayments.map((payment) {
                    return ListTile(
                      title: Text('Partial Payment: \₱${payment.amountPaid}'),
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
                  'Payment Date: ${selectedDate != null ? _formatDate(selectedDate) : ' '}',
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
                    if (date != null) setState(() => selectedDate = date);
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
            child: const Text(
              'Add Payment',
              style: TextStyle(color: Colors.white),
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

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class AccountReceivable {
  final String custName;
  final double totalAmount;
  final DateTime dateBilled;
  final List<PartialPayment> partialPayments;
  List<HaulingAdvice> haulingAdvices;
  bool isPaid;

  AccountReceivable({
    required this.custName,
    required this.totalAmount,
    required this.dateBilled,
    required this.partialPayments,
    this.haulingAdvices = const [],
    required this.isPaid,
  });

  factory AccountReceivable.fromJson(Map<String, dynamic> json) {
    return AccountReceivable(
      custName: json['custName'],
      totalAmount: json['totalAmount'],
      dateBilled: DateTime.parse(json['billingDate']),
      partialPayments: (json['partialPayments'] as List<dynamic>?)
              ?.map((e) => PartialPayment.fromJson(e))
              .toList() ??
          [],
      haulingAdvices: (json['haulingAdvice'] as List<dynamic>?)
              ?.map((e) => HaulingAdvice.fromJson(e))
              .toList() ??
          [],
      isPaid: json['paid'],
    );
  }
}

class HaulingAdvice {
  final double volumeDelivered;
  final double pricePerUnit;

  HaulingAdvice({
    required this.volumeDelivered,
    required this.pricePerUnit,
  });

  double get calculatedAmount => volumeDelivered * pricePerUnit;

  factory HaulingAdvice.fromJson(Map<String, dynamic> json) {
    return HaulingAdvice(
      volumeDelivered: json['volumeDelivered'],
      pricePerUnit: json['pricePerUnit'],
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
