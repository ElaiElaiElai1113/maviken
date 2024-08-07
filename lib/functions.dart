// ignore_for_file: unused_local_variable, avoid_print, unused_element

import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profile_employee.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/profile_supplier.dart';

Future<int?> createDataSO() async {
  try {
    final response = await supabase.from('salesOrder').insert([
      {
        'custName': custNameController.text,
        'date': dateController.text,
        'address': addressController.text,
        'typeofload': descriptionController.text,
        'totalVolume': int.tryParse(volumeController.text),
        'price': int.tryParse(priceController.text),
      }
    ]).select('salesOrder_id');
    final salesOrderId = response[0]['id'] as int?;
    return salesOrderId;
  } catch (e) {
    print('Error: $e');
  }
  return null;
}

Future<int?> createEmptyDelivery(int salesOrderId) async {
  final response = await supabase.from('delivery').insert({
    'supplierinvoice': null,
    'unit': null,
    'driverid': null,
    'helperid': null,
    'truckid': null,
    'deliverydate': null,
    'deliveryvolume': null,
    'salesOrder_id': salesOrderId,
  }).select('deliveryid');
  final deliveryid = response[0]['id'] as int?;
  return deliveryid;
}

void createEmptyHaulingAdvice(int deliveryid, int salesOrderId) async {
  final response = await supabase.from('haulingAdvice').insert({
    'deliveryID': deliveryid,
    'delivered': null,
    'driverID': null,
    'salesOrder_id': salesOrderId,
    'helperID': null,
    'quantityDel': null,
    'truckID': null,
  });
}

void createSalesOrderDeliveryHaulingAdvice() async {
  final salesOrderId = await createDataSO();

  if (salesOrderId != null) {
    final deliveryId = createEmptyDelivery(salesOrderId);
    createEmptyHaulingAdvice(deliveryid, salesOrderId) {}
  } else {
    print('Failed to create sales order');
  }
}

Future<void> createDataHA() async {
  final response = await supabase.from('salesOrder').insert([{}]);
}

Future<void> createEmployee() async {
  final response = await supabase.from('employee').insert([
    {
      'lastName': lastName.text,
      'firstName': firstName.text,
      'addressLine': eaddressLine.text,
      'city': ecity.text,
      'barangay': ebarangay.text,
      'contactNo': int.tryParse(econtactNum.text) ?? 0,
    }
  ]);
}

Future<void> createDelivery() async {
  final response = await supabase.from('delivery').insert([{}]);
}

Future<void> createSupplier() async {
  final response = await supabase.from('employee').insert([
    {
      'lastName': comName.text,
      'firstName': firstName.text,
      'addressLine': saddressLine.text,
      'city': scity.text,
      'barangay': sbarangay.text,
      'contactNo': int.tryParse(scontactNum.text) ?? 0,
    }
  ]);
}

Future<void> createCustomer() async {
  final response = await supabase.from('employee').insert([
    {
      'lastName': comName.text,
      'firstName': repName.text,
      'addressLine': cDescription.text,
      'city': ccity.text,
      'barangay': caddressLine.text,
      'contactNo': int.tryParse(ccontactNum.text) ?? 0,
    }
  ]);
}

Future<String> signUpEmailAndPassword(String email, String password) async {
  return supabase.auth
      .signUp(email: email, password: password)
      .then((response) {
    final userID = response.user?.id;

    if (userID == null) {
      throw Exception('Failed to sign up: User ID is null');
    }
    return userID;
  });
}

List<dynamic>? positions;
String? selectedPosition = "";

Future<List<dynamic>> fetchEmployeePositions() async {
  final response = await supabase.from('employeePosition').select('*');

  return response;
}

List<Map<String, dynamic>> orders = [];

Future<void> fetchData() async {
  final data = await supabase.from('salesOrder').select('*');
  orders = data;
}

Future<void> deleteData() async {
  final response = await supabase.from('salesOrder').delete().match({'id': id});
}
