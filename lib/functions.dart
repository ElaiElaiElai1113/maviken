import 'package:maviken/screens/create_account.dart';
import 'package:maviken/screens/newOrderOwner.dart';
import 'package:maviken/screens/monitoring.dart';

Future<void> createData() async {
  final response = await supabase.from('purchaseOrder').insert([
    {
      'custName': custNameController.text,
      'address': addressController.text,
      'description': descriptionController.text,
      'volume': int.tryParse(volumeController.text) ?? 0,
      'price': int.tryParse(priceController.text) ?? 0,
      'quantity': int.tryParse(quantityController.text) ?? 0,
    }
  ]);
}

Future<void> createEmployee() async {
  final response = await supabase.from('employee').insert([
    {
      'lastName': lastName.text,
      'firstName': firstName.text,
      'addressLine': addressLine.text,
      'city': city.text,
      'barangay': barangay.text,
      'contactNo': int.tryParse(contactNum.text) ?? 0,
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
  }).catchError((error) {
    print('Error during sign-up: $error');
    throw error;
  });
}

List<dynamic>? positions;
String? selectedPosition = "";

Future<List<dynamic>> fetchEmployeePositions() async {
  try {
    final response = await supabase.from('employeePosition').select('*');
    print(response);
    positions = response;
    return response;
  } catch (error) {
    print('Error fetching employee positions: $error');
    return [];
  }
}

List<Map<String, dynamic>> orders = [];

Future<void> fetchData() async {
  try {
    final data = await supabase.from('purchaseOrder').select('*');
    orders = data;
  } catch (error) {
    print('Nothing to print');
  }
}
