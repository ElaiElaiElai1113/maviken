import 'package:maviken/main.dart';

class DataService {
  Future<int?> createDataSO({
    required String custName,
    required String date,
    required String deliveryAdd,
    required String pickUpAdd,
  }) async {
    try {
      final response = await supabase.from('salesOrder').insert([
        {
          'custName': custName,
          'date': date,
          'pickUpAdd': pickUpAdd,
          'deliveryAdd': deliveryAdd,
        }
      ]).select('salesOrder_id');

      final salesOrderId =
          response.isNotEmpty ? response[0]['salesOrder_id'] as int? : null;
      return salesOrderId;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<int?> createEmptyDelivery(int salesOrderId) async {
    try {
      final response = await supabase.from('delivery').insert([
        {
          'supplierinvoice': null,
          'unit': null,
          'driverid': null,
          'helperid': null,
          'truckid': null,
          'deliverydate': null,
          'deliveryvolume': null,
          'salesOrder': salesOrderId,
        }
      ]).select('deliveryid');

      final deliveryId =
          response.isNotEmpty ? response[0]['deliveryid'] as int? : null;
      return deliveryId;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> createEmptyHA(int deliveryId, int salesOrderId) async {
    try {
      final response = await supabase.from('haulingAdvice').insert([
        {
          'deliveryID': deliveryId, // Ensure column names match your schema
          'delivered': null,
          'driverID': null,
          'salesOrder_id': salesOrderId,
          'helperID': null,
          'volumeDel': null,
          'truckID': null,
        }
      ]);

      if (response.error != null) {
        print('Error creating hauling advice: ${response.error!.message}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> createSADELHA({
    required String custName,
    required String date,
    required String pickUpAdd,
    required String deliveryAdd,
    required String typeofload,
    required int totalVolume,
    required int price,
  }) async {
    final salesOrderId = await createDataSO(
      custName: custName,
      date: date,
      pickUpAdd: pickUpAdd,
      deliveryAdd: deliveryAdd,
    );

    if (salesOrderId != null) {
      final deliveryId = await createEmptyDelivery(salesOrderId);

      if (deliveryId != null) {
        await createEmptyHA(deliveryId, salesOrderId);
      } else {
        print('Failed to create delivery.');
      }
    } else {
      print('Failed to create sales order.');
    }
  }

  // One or Many load Types Sales Order
  Future<Map<String, dynamic>> createSO({
    required String custName,
    required String date,
    required String deliveryAdd,
  }) async {
    try {
      final response = await supabase
          .from('salesOrder')
          .insert({
            'custName': custName,
            'date': date,
            'deliveryAdd': deliveryAdd,
          })
          .select()
          .single();
      print('Response: $response');
      return response;
    } catch (e) {
      print('Error creating sales order: $e');
      return {};
    }
  }

  Future<void> createLoad({
    required int salesOrderID,
    required String loadID,
    required int totalVolume,
    required int supplierID,
    required double price,
  }) async {
    await supabase.from('salesOrderLoad').insert({
      'salesOrder_id': salesOrderID,
      'loadID': loadID,
      'supplierID': supplierID,
      'totalVolume': totalVolume,
      'price': price,
    });
  }

  Future<void> createAccountsReceivable({
    required String billingNo,
    required double totalAmount,
    required String billingDate,
    required int amountPaid,
    String? paymentDate,
    required bool paid,
    int? haulingAdviceID,
    required int salesOrderID,
    required String custName,
  }) async {
    await supabase.from('accountsReceivables').insert({
      'billingNo': billingNo,
      'totalAmount': totalAmount,
      'billingDate': billingDate,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate,
      'paid': paid,
      'haulingAdviceID': haulingAdviceID,
      'salesOrder_id': salesOrderID,
      'custName': custName,
    });
  }

  Future<Map<String, dynamic>?> checkExistingReceivable(
      int salesOrderId) async {
    try {
      final response = await supabase
          .from('accountsReceivables')
          .select('*')
          .eq('salesOrder_id', salesOrderId)
          .single();

      return response;
    } catch (error) {
      print('Error checking existing accounts receivable: $error');
      return null;
    }
  }
}
