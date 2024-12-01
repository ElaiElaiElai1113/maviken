import 'package:maviken/screens/new_order.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:maviken/screens/profile_trucks.dart';

Future<int?> createDataSO() async {
  try {
    final response = await supabase.from('salesOrder').insert([
      {
        'custName': custNameController.text,
        'date': dateController.text,
        'pickUpAdd': pickUpAddressController.text,
        'deliveryAdd': deliveryAddressController.text,
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
    'salesOrder': salesOrderId,
  }).select('deliveryid');
  final deliveryid = response[0]['deliveryid'] as int?;
  return deliveryid;
}

Future<void> createEmptyHaulingAdvice(int deliveryID, int salesOrderID) async {
  try {
    print(
        'Creating Hauling Advice with deliveryID: $deliveryID and salesOrderID: $salesOrderID');

    // Insert the empty hauling advice
    final response = await supabase.from('haulingAdvice').insert({
      'deliveryID': deliveryID,
      'delivered': null,
      'driverID': null,
      'salesOrder_id': salesOrderID,
      'helperID': null,
      'volumeDel': null,
      'truckID': null,
      'isPlaceHolder': true,
    });

    print('Hauling advice created successfully for deliveryID: $deliveryID');
  } catch (e) {
    print('Error while creating hauling advice: $e');
    throw Exception('Failed to create hauling advice: $e');
  }
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

Future<void> createDelivery() async {
  final response = await supabase.from('delivery').insert([{}]);
}

Future<void> createTruck() async {
  final response = await supabase.from('Truck').insert([
    {
      'plateNumber': plateNumber.text,
      'brand': tbrand.text,
      'model': tmodel.text,
      'year': int.tryParse(tyear.text) ?? 0,
      'color': tcolor.text,
    }
  ]);
}

Future<void> createSupplier() async {
  final response = await supabase.from('supplier').insert([
    {
      'companyName': sCompanyName.text.isNotEmpty ? sCompanyName.text : "",
      'lastName': slastName.text.isNotEmpty ? slastName.text : "",
      'firstName': sfirstName.text.isNotEmpty ? sfirstName.text : "",
      'description': sdescription.text.isNotEmpty ? sdescription.text : "",
      'addressLine': saddressLine.text.isNotEmpty ? saddressLine.text : "",
      'city': scity.text.isNotEmpty ? scity.text : "",
      'barangay': sbarangay.text.isNotEmpty ? sbarangay.text : "",
      'contactNo':
          int.tryParse(scontactNum.text) ?? 0, // Default to 0 if not provided
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
