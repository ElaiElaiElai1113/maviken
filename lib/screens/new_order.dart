import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/data_service.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collapsible_sidebar/collapsible_sidebar.dart';

final TextEditingController id = TextEditingController();
final TextEditingController custNameController = TextEditingController();
final TextEditingController dateController = TextEditingController();
final TextEditingController deliveryAddressController = TextEditingController();
final TextEditingController pickUpAddressController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
final TextEditingController priceController = TextEditingController();
final TextEditingController deliveryController = TextEditingController();
List<Map<String, dynamic>> customer = [];
Map<String, dynamic>? selectedCustomer;
final TextEditingController volumeController = TextEditingController();
final TextEditingController quantityController = TextEditingController();

List<Map<String, dynamic>> _suppliers = [];
Map<String, dynamic>? _selectedSupplier;
int? supplierID;

List<Map<String, dynamic>> _typeofload = [];
Map<String, dynamic>? _selectedLoad;
int? loadID;

List<Map<String, dynamic>> selectedLoads = [];
List<Map<String, dynamic>> pricing = [];

late List<CollapsibleItem> _items;
late String _headline;

class NewOrder extends StatefulWidget {
  static const routeName = '/NewOrder';

  const NewOrder({super.key});

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  int _currentIndex = 1;
  final DataService dataService = DataService();
  bool _isBarTopVisible = true;

  void toggleBarTop() {
    setState(() {
      _isBarTopVisible = !_isBarTopVisible;
    });
  }

  Future<void> handleCreateOrderAndDelivery() async {
    if (validateInputs()) {
      try {
        // Step 1: Create the Sales Order
        final salesOrderResponse = await dataService.createSO(
          custName: selectedCustomer?['companyOrFullName'],
          date: dateController.text.isNotEmpty
              ? dateController.text
              : DateTime.now().toString().split(' ')[0],
          deliveryAdd: deliveryAddressController.text.isNotEmpty
              ? deliveryAddressController.text
              : "No address provided",
        );

        final salesOrderID = salesOrderResponse['salesOrder_id'];
        if (salesOrderID == null || salesOrderID == 0) {
          throw Exception('Failed to retrieve a valid sales order ID');
        }

        // Step 2: Create Loads associated with the Sales Order
        for (var load in selectedLoads) {
          assert(load['typeofload'] != null, 'Load type is null');
          assert(load['volume'] != null, 'Volume is null');

          int supplierID = _selectedSupplier?['supplierID'] ?? 0;

          print(supplierID);

          await dataService.createLoad(
            salesOrderID: salesOrderID,
            loadID: load['loadID'].toString(),
            totalVolume: int.tryParse(load['volume'] ?? '0') ?? 0,
            price: int.tryParse(load['price'] ?? '0') ?? 0,
          );
        }
        // Step 3: Create Empty Delivery associated with the Sales Order
        final deliveryID = await createEmptyDelivery(salesOrderID);

        if (deliveryID != null) {
          // Step 4: Create Empty Hauling Advice associated with the Delivery and Sales Order
          createEmptyHaulingAdvice(deliveryID, salesOrderID);
        } else {
          throw Exception('Failed to create hauling advice');
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Order, Delivery, and Hauling Advice created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form after successful creation
        resetForm();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String generateBillingNo() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  double calculateTotalAmount(List<Map<String, dynamic>> loads) {
    return loads.fold(0, (sum, load) {
      int price = int.tryParse(load['price'] ?? '0') ?? 0;
      int volume = int.tryParse(load['volume'] ?? '0') ?? 0;
      return sum + (price * volume);
    });
  }

  bool validateInputs() {
    if (selectedCustomer == null) {
      showError('Customer name is required');
      return false;
    }

    if (deliveryAddressController.text.isEmpty) {
      showError('Delivery Address is required');
      return false;
    }
    if (selectedLoads.isEmpty) {
      showError('At least one load must be added');
      return false;
    }

    for (var load in selectedLoads) {
      if (int.tryParse(load['volume'] ?? '0') == null) {
        showError('Invalid volume value in load');
        return false;
      }

      if (int.tryParse(load['loadPrice'] ?? '0') == null) {
        showError('Invalid price value in load');
        return false;
      }
    }

    return true;
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    resetForm();
    super.dispose;
  }

  void resetForm() {
    selectedCustomer == null;
    dateController.clear();
    pickUpAddressController.clear();
    deliveryAddressController.clear();
    descriptionController.clear();
    priceController.clear();
    volumeController.clear();
    quantityController.clear();
    setState(() {
      selectedLoads.clear();
    });
  }

  Future<void> fetchSalesOrder() async {
    final response = await supabase.from('salesOrder').select('*');
  }

  Future<void> fetchLoad() async {
    final response =
        await Supabase.instance.client.from('typeofload').select('*');
    setState(() {
      _typeofload = response
          .map<Map<String, dynamic>>((typeofload) => {
                'loadID': typeofload['loadID'] ?? 'Unknown',
                'typeofload': typeofload['loadtype'] ?? 'Unknown Load',
              })
          .toList();
      if (_typeofload.isNotEmpty) {
        _selectedLoad = _typeofload.first;
      }
    });
  }

  void _addLoadEntry() {
    int? volume = int.tryParse(volumeController.text);

    if (volume == null || volume <= 0) {
      showError('Insert a valid number for volume');
      return;
    }

    setState(() {
      selectedLoads.add({
        'loadID': _selectedLoad?['loadID']?.toString() ?? 'No load ID selected',
        'typeofload':
            _selectedLoad?['typeofload']?.toString() ?? 'No load selected',
        'volume': volumeController.text,
        'price': _selectedLoad?['price']?.toString() ??
            '0', // Use the price from the selected load
      });

      volumeController.clear(); // Clear volume input after adding
    });
  }

  void _removeLoadEntry(int index) {
    setState(() {
      selectedLoads.removeAt(index);
    });
  }

  Future<void> fetchSupplier() async {
    try {
      final response = await supabase.from('supplier').select('*');

      if (!mounted) return;
      setState(() {
        _suppliers = response
            .map<Map<String, dynamic>>((supplier) => {
                  'supplierID': supplier['supplierID'],
                  'companyName': supplier['companyName'],
                })
            .toList();
        if (_suppliers.isNotEmpty) {
          _selectedSupplier = _suppliers.first;
          supplierID = _selectedSupplier?['supplierID'];
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchSupplierLoadPrice() async {
    if (supplierID == null) return;

    try {
      final response = await supabase
          .from('supplierLoadPrice')
          .select('*, typeofload!inner(*)')
          .eq('supplier_id', supplierID as Object);

      if (!mounted) return;
      setState(() {
        _typeofload = response.map<Map<String, dynamic>>((load) {
          return {
            'price': load['price'],
            'loadID': load['load_id'],
            'typeofload': load['typeofload']['loadtype'],
          };
        }).toList();

        if (_typeofload.isNotEmpty) {
          _selectedLoad = _typeofload.first;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchTypeOfLoad() async {
    try {
      final response = await supabase
          .from('typeofload')
          .select('*')
          .eq('loadID', loadID as Object);
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchCustomer() async {
    final response = await supabase.from('customer').select('*');

    if (!mounted) return;
    setState(() {
      customer = response
          .map<Map<String, dynamic>>((customer) => {
                'companyOrFullName': customer['company']?.isNotEmpty == true
                    ? customer['company']
                    : '${customer['repFirstName']} - ${customer['repLastName']}',
                'fullName':
                    '${customer['repFirstName']} - ${customer['repLastName']}'
              })
          .toSet()
          .toList();
      if (customer.isNotEmpty) {
        selectedCustomer = customer.first;
      }
    });
  }

  Future<void> fetchPricing() async {
    try {
      final response = await supabase.from('pricing').select('*');
      if (!mounted) return;
      setState(() {
        pricing = response
            .map<Map<String, dynamic>>((price) => {
                  'tollFee': price['tollFee'],
                  'driverFee': price['driver'],
                  'helperFee': price['helper'],
                  'miscFee': price['misc']
                })
            .toList();
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as int?;
    setState(() {
      _currentIndex = args ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchSalesOrder();
    fetchCustomer();
    fetchLoad();
    fetchSupplier();
    fetchSupplierLoadPrice();
    fetchTypeOfLoad();
    fetchPricing();
    _items = _generateItems;
    _headline = _items.firstWhere((item) => item.isSelected).text;
  }

  List<CollapsibleItem> get _generateItems {
    return [
      CollapsibleItem(
        text: 'Dashboard',
        icon: Icons.dashboard_rounded,
        onPressed: () {
          setState(() => _currentIndex = 0); // Set index to Dashboard
        },
        isSelected: _currentIndex == 0,
      ),
      CollapsibleItem(
        text: 'Booking',
        icon: Icons.book_rounded,
        onPressed: () {
          setState(() => _currentIndex = 1);
        },
        isSelected: _currentIndex == 1,
      ),
      CollapsibleItem(
        text: 'Hauling Advice',
        icon: Icons.receipt_rounded,
        onPressed: () {
          setState(() => _currentIndex = 2); // Set index to Hauling Advice
        },
        isSelected: _currentIndex == 2,
      ),
      CollapsibleItem(
        text: 'Monitoring',
        icon: Icons.monitor_rounded,
        onPressed: () {
          setState(() => _currentIndex = 3);
        },
        isSelected: _currentIndex == 3,
      ),
      CollapsibleItem(
        text: 'Profiling',
        icon: Icons.person_2_rounded,
        onPressed: () {
          setState(() => _currentIndex = 4); // Set index to Profiling
        },
        isSelected: _currentIndex == 4,
      ),
      CollapsibleItem(
        text: 'Management',
        icon: Icons.price_change_rounded,
        onPressed: () {
          setState(() => _currentIndex = 5); // Set index to Management
        },
        isSelected: _currentIndex == 5,
      ),
      CollapsibleItem(
        text: 'Logout',
        icon: Icons.eco,
        onPressed: () {
          // Handle logout
          supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: NewOrder(screenWidth, context),
        label: "Booking");
  }

  SizedBox NewOrder(double screenWidth, BuildContext context) {
    return SizedBox(
      width: screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: screenWidth * .15,
                        height: 50,
                        child: TextField(
                          style: const TextStyle(color: Colors.black),
                          controller: dateController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            labelText: 'Date',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2500),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dateController.text = pickedDate
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0];
                              });
                            }
                          },
                        ),
                      ),
                      Flexible(
                        child: dropDown(
                          'Customer Name',
                          customer,
                          selectedCustomer,
                          (Map<String, dynamic>? newValue) {
                            setState(() {
                              selectedCustomer = newValue;
                            });
                          },
                          'companyOrFullName',
                        ),
                      ),
                      const SizedBox(width: 20),
                      const SizedBox(height: 25),
                      TextField(
                        style: const TextStyle(color: Colors.black),
                        controller: deliveryAddressController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          labelText: 'Delivery Address',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Divider(),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          const SizedBox(width: 25),
                          Flexible(
                            child: dropDown(
                              'Supplier: ',
                              _suppliers,
                              _selectedSupplier,
                              (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedSupplier = newValue;
                                  supplierID = _selectedSupplier?['supplierID'];
                                  fetchSupplierLoadPrice();
                                });
                              },
                              'companyName',
                            ),
                          ),
                          Flexible(
                            child: dropDown(
                              'Load Type: ',
                              _typeofload,
                              _selectedLoad,
                              (Map<String, dynamic>? newValue) {
                                setState(() {
                                  _selectedLoad = newValue;
                                  fetchSupplierLoadPrice();
                                });
                              },
                              'typeofload',
                            ),
                          ),
                          // Display the selected load price
                          if (_selectedLoad != null) ...[
                            Text(
                              'Load Price: ${_selectedLoad?['price'] ?? '0'}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(width: 20),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          Flexible(
                            child: TextField(
                              style: const TextStyle(color: Colors.black),
                              controller: priceController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                labelText: 'Price',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: TextField(
                              style: const TextStyle(color: Colors.black),
                              controller: volumeController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                labelText: 'Volume (m³)',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.orangeAccent,
                        ),
                        onPressed: _addLoadEntry,
                        child: const Text(
                          textAlign: TextAlign.center,
                          'Add Load',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.grey[100],
                        elevation: 3,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: selectedLoads.length,
                          itemBuilder: (context, index) {
                            final load = selectedLoads[index];
                            return ListTile(
                              title: Text(
                                  'Load: ${load['typeofload']}, Volume: ${load['volume']}, Price: ${load['price']},'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeLoadEntry(index),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: const EdgeInsets.all(15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: handleCreateOrderAndDelivery,
                        child: const Text(
                          'Save',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
