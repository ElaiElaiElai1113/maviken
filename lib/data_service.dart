// ignore_for_file: avoid_print

import 'package:maviken/main.dart';

class DataService {
  Future<int?> createDataSO({
    required String custName,
    required String date,
    required String address,
    required String typeofload,
    required int totalVolume,
    required int price,
  }) async {
    try {
      final response = await supabase.from('salesOrder').insert([
        {
          'custName': custName,
          'date': date,
          'address': address,
          'typeofload': typeofload,
          'totalVolume': totalVolume,
          'price': price,
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
    required String address,
    required String typeofload,
    required int totalVolume,
    required int price,
  }) async {
    final salesOrderId = await createDataSO(
      custName: custName,
      date: date,
      address: address,
      typeofload: typeofload,
      totalVolume: totalVolume,
      price: price,
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
    required String address,
  }) async {
    try {
      final response = await supabase
          .from('salesOrder')
          .insert({
            'custName': custName,
            'date': date,
            'address': address,
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
    required int price,
  }) async {
    await supabase.from('salesOrderLoad').insert({
      'salesOrder_id': salesOrderID,
      'loadID': loadID,
      'totalVolume': totalVolume,
      'price': price,
    });
  }
}
