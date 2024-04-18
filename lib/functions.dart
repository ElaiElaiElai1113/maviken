import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profile_employee.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/profile_supplier.dart';

Future<void> createDataPO() async {
  final response = await supabase.from('purchaseOrder').insert([
    {
      'custName': custNameController.text,
      'date': dateController.text,
      'address': addressController.text,
      'description': descriptionController.text,
      'volume': int.tryParse(volumeController.text) ?? 0,
      'price': int.tryParse(priceController.text) ?? 0,
      'quantity': int.tryParse(quantityController.text) ?? 0,
    }
  ]);
}

Future<void> createDataHA() async {
  final response = await supabase.from('purchaseOrder').insert([{}]);
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
  final data = await supabase.from('purchaseOrder').select('*');
  orders = data;
}

Future<void> deleteData() async {
  final response =
      await supabase.from('purchaseOrder').delete().match({'id': id});
}
