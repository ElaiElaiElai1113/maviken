import 'package:flutter/material.dart';

class BillingStatement extends StatelessWidget {
  final String customerName;
  final List<Map<String, dynamic>> haulingAdviceDetails;

  const BillingStatement({
    super.key,
    required this.customerName,
    required this.haulingAdviceDetails,
  });

  @override
  Widget build(BuildContext context) {
    double totalAmount = haulingAdviceDetails.fold(
        0, (sum, item) => sum + double.parse(item['calculatedPrice']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Billing Statement for $customerName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Name: $customerName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: haulingAdviceDetails.length,
                itemBuilder: (context, index) {
                  final item = haulingAdviceDetails[index];
                  return SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.9, // Adjust the width as needed
                    child: Card(
                      child: ListTile(
                        title: Text(
                          'Hauling Advice ID: ${item['haulingAdviceId']}',
                        ),
                        subtitle: Text(
                          'Date: ${item['date']}\n'
                          'Type of Load: ${item['typeofload']}\n'
                          'Volume Delivered: ${item['volumeDel']}\n'
                          'Price per Unit: ${item['price']}\n'
                          'Calculated Price: ${item['calculatedPrice']}\n'
                          'Plate Number: ${item['plateNumber']}',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              'Total Amount: $totalAmount',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
