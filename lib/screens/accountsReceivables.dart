import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';

class Accountsreceivables extends StatefulWidget {
  static const routeName = '/accountsreceivable';

  const Accountsreceivables({Key? key}) : super(key: key);

  @override
  _AccountsReceivableState createState() => _AccountsReceivableState();
}

class _AccountsReceivableState extends State<Accountsreceivables> {
// Mock data structure
  final List<AccountReceivable> accountsReceivable = [
    AccountReceivable(
      custName: "Customer A",
      totalAmount: 5000.0,
      dateBilled: DateTime(2023, 5, 1),
      amountPaid: 3000.0,
      paymentDate: DateTime(2023, 5, 15),
      isPaid: false,
      deliveryReceipts: [
        DeliveryReceipt(
          drNumber: "DR001",
          volume: 10.5,
          date: DateTime(2023, 4, 28),
          truckPlateNumber: "ABC123",
          price: 2500.0,
          description: "Sand",
        ),
        DeliveryReceipt(
          drNumber: "DR002",
          volume: 8.0,
          date: DateTime(2023, 4, 30),
          truckPlateNumber: "XYZ789",
          price: 2500.0,
          description: "Gravel",
        ),
      ],
    ),
    // Add more mock data as needed
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: AccountReceivables(context),
        label: 'AccountReceivable');
  }

  SizedBox AccountReceivables(
    BuildContext context,
  ) {
    return SizedBox(
      child: ListView.builder(
        itemCount: accountsReceivable.length,
        itemBuilder: (context, index) {
          final account = accountsReceivable[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ExpansionTile(
              title: Text(account.custName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total: \$${account.totalAmount.toStringAsFixed(2)}'),
                  Text('Date Billed: ${_formatDate(account.dateBilled)}'),
                  Text(
                      'Amount Paid: \$${account.amountPaid.toStringAsFixed(2)}'),
                  Text('Payment Date: ${_formatDate(account.paymentDate)}'),
                  Text('Paid: ${account.isPaid ? "Yes" : "No"}'),
                ],
              ),
              children: account.deliveryReceipts
                  .map((dr) => _buildDeliveryReceiptTile(dr))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildDeliveryReceiptTile(DeliveryReceipt dr) {
  return ListTile(
    title: Text('DR#: ${dr.drNumber}'),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Volume: ${dr.volume.toStringAsFixed(2)} cubic meters'),
        Text('Date: ${_formatDate(dr.date)}'),
        Text('Truck/Plate Number: ${dr.truckPlateNumber}'),
        Text('Price: \$${dr.price.toStringAsFixed(2)}'),
        Text('Description: ${dr.description}'),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class AccountReceivable {
  final String custName;
  final double totalAmount;
  final DateTime dateBilled;
  final double amountPaid;
  final DateTime paymentDate;
  final bool isPaid;
  final List<DeliveryReceipt> deliveryReceipts;

  AccountReceivable({
    required this.custName,
    required this.totalAmount,
    required this.dateBilled,
    required this.amountPaid,
    required this.paymentDate,
    required this.isPaid,
    required this.deliveryReceipts,
  });
}

class DeliveryReceipt {
  final String drNumber;
  final double volume;
  final DateTime date;
  final String truckPlateNumber;
  final double price;
  final String description;

  DeliveryReceipt({
    required this.drNumber,
    required this.volume,
    required this.date,
    required this.truckPlateNumber,
    required this.price,
    required this.description,
  });
}
