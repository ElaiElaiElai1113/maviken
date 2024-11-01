import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:maviken/components/dropdownbutton.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/data_service.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/priceManagement.dart';
import 'package:maviken/screens/profiling.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';
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

List<Map<String, dynamic>> _typeofload = [];
Map<String, dynamic>? _selectedLoad;

List<Map<String, dynamic>> selectedLoads = [];

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
          pickUpAdd: pickUpAddressController.text.isNotEmpty
              ? pickUpAddressController.text
              : 'No address provided',
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
          assert(load['loadPrice'] != null, 'Price is null');

          await dataService.createLoad(
            salesOrderID: salesOrderID,
            loadID: load['loadID'].toString(),
            totalVolume: int.tryParse(load['volume'] ?? '0') ?? 0,
            price: int.tryParse(load['loadPrice'] ?? '0') ?? 0,
            deliveryFee: int.tryParse(load['deliveryFee'] ?? '0') ?? 0,
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

  bool validateInputs() {
    if (selectedCustomer == null) {
      showError('Customer name is required');
      return false;
    }

    if (pickUpAddressController.text.isEmpty) {
      showError('Pickup Address is required');
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

  void resetForm() {
    custNameController.clear();
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

  Future<void> fetchLoad(int supplierID) async {
    final response = await Supabase.instance.client
        .from('typeofload')
        .select('*, supplier!inner(supplierID)')
        .eq('supplierID', supplierID);
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
      print('Supplier ID: $supplierID');
    });
  }

  Future<void> fetchSupplierLoad(int supplierID) async {
    final response = await Supabase.instance.client
        .from('supplierLoadPrice')
        .select('*, supplier!inner(*), typeofload(*)')
        .eq('supplier_id', supplierID);
    setState(() {
      _typeofload = response
          .map<Map<String, dynamic>>((typeofload) => {
                'loadID': typeofload['typeofload']['loadID'] ?? 'Unknown',
                'typeofload':
                    typeofload['typeofload']['loadtype'] ?? 'Unknown Load',
                'price': typeofload['price'] ?? 0,
              })
          .toList();

      if (_typeofload.isNotEmpty) {
        _selectedLoad = _typeofload.first;
        priceController.text = _selectedLoad?['loadPrice'].toString() ?? '0';
      }
    });
  }

  void fetchSupplier() async {
    final response =
        await Supabase.instance.client.from('supplier').select('*');

    setState(() {
      _suppliers = response
          .map<Map<String, dynamic>>((supplier) => {
                'supplierID': supplier['supplierID'] ?? 'Unknown',
                'company': supplier['companyName'] ?? 'Unknown',
              })
          .toList();

      if (_suppliers.isNotEmpty) {
        _selectedSupplier = _suppliers.first;
      }
    });
  }

  void _addLoadEntry() {
    int? volume = int.tryParse(volumeController.text);
    int? price = int.tryParse(priceController.text);
    int? delivery = int.tryParse(deliveryController.text);

    if (volume == null || volume <= 0) {
      showError('Insert a valid number for volume');
      return;
    }

    if (price == null || price <= 0) {
      showError('Insert a valid number for price');
      return;
    }
    if (delivery == null || price <= 0) {
      showError('Insert a valid number for price');
      return;
    }

    setState(() {
      selectedLoads.add({
        'loadID': _selectedLoad?['loadID']?.toString() ?? 'No load ID selected',
        'typeofload':
            _selectedLoad?['typeofload']?.toString() ?? 'No load selected',
        'volume': volumeController.text,
        'loadPrice': priceController.text,
        'deliveryFee': deliveryController.text,
      });

      quantityController.clear();
      volumeController.clear();
      priceController.clear();
    });
  }

  void _removeLoadEntry(int index) {
    setState(() {
      selectedLoads.removeAt(index);
    });
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
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchSalesOrder();
    fetchCustomer();
    fetchSupplier();
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
          // Set index to New Order
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
          setState(() => _currentIndex = 3); // Set index to Monitoring
        },
      ),
      CollapsibleItem(
        text: 'Profiling',
        icon: Icons.person_2_rounded,
        onPressed: () {
          setState(() => _currentIndex = 4); // Set index to Profiling
        },
      ),
      CollapsibleItem(
        text: 'Management',
        icon: Icons.price_change_rounded,
        onPressed: () {
          setState(() => _currentIndex = 5); // Set index to Management
        },
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

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;
        bool isSmallScreen = constraints.maxWidth < 600;
        if (!isWideScreen) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Booking"),
              backgroundColor: Colors.white,
            ),
            body: Row(
              children: [
                if (isSmallScreen)
                  NavigationRail(
                    backgroundColor: const Color(0xFFeab557),
                    selectedIndex: 1, // Set the selected index appropriately
                    onDestinationSelected: (int index) {
                      switch (index) {
                        case 0:
                          Navigator.pushReplacementNamed(
                              context, DashBoard.routeName);
                          break;
                        case 1:
                          // Current page, do nothing
                          break;
                        case 2:
                          Navigator.pushReplacementNamed(
                              context, HaulingAdvice.routeName);
                          break;
                        case 3:
                          Navigator.pushReplacementNamed(
                              context, Monitoring.routeName);
                          break;
                        case 4:
                          Navigator.pushReplacementNamed(
                              context, Profiling.routeName);
                          break;
                        case 5:
                          Navigator.pushReplacementNamed(
                              context, PriceManagement.routeName);
                          break;
                        case 6:
                          // Handle logout
                          supabase.auth.signOut();
                          Navigator.pushReplacementNamed(
                              context, LoginScreen.routeName);
                          break;
                      }
                    },
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add_box),
                        label: Text('New Order'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.car_crash_rounded),
                        label: Text('Hauling Advice'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.monitor),
                        label: Text('Monitoring'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.account_circle),
                        label: Text('Profiling'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.price_change),
                        label: Text('Management'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.logout),
                        label: Text('Logout'),
                      ),
                    ],
                  ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(50),
                    color: Colors.white,
                    child: NewOrder(screenWidth, context),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Booking'),
                backgroundColor: Colors.white,
                leading: IconButton(
                    onPressed: toggleBarTop,
                    icon: Icon(
                      _isBarTopVisible ? Icons.arrow_back : Icons.menu,
                    )),
              ),
              body: Row(
                children: [
                  if (_isBarTopVisible) const BarTop(),
                  Expanded(
                      child: Container(
                          color: Colors.white,
                          height: screenHeight,
                          width: screenWidth,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: NewOrder(screenWidth, context),
                          ))),
                ],
              ));
        }
      },
    );
  }

  Column NewOrder(double screenWidth, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
                child: dropDown('Customer Name', customer, selectedCustomer,
                    (Map<String, dynamic>? newValue) {
              setState(() {
                selectedCustomer = newValue;
              });
            }, 'companyOrFullName')),
            const SizedBox(width: 20),
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
                    borderRadius: BorderRadius.all(Radius.circular(15)),
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
                    dateController.text =
                        pickedDate.toLocal().toString().split(' ')[0];
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        TextField(
          style: const TextStyle(color: Colors.black),
          controller: pickUpAddressController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            labelText: 'Pick-up Address',
            labelStyle: TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(height: 25),
        TextField(
          style: const TextStyle(color: Colors.black),
          controller: deliveryAddressController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
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
            Expanded(
              child: dropDown(
                'Supplier: ',
                _suppliers,
                _selectedSupplier,
                (Map<String, dynamic>? newValue) {
                  setState(() {
                    _selectedLoad = newValue;
                  });

                  fetchSupplierLoad(_selectedSupplier?['supplierID']);
                },
                'company',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: dropDown(
                'Load Type: ',
                _typeofload,
                _selectedLoad,
                (Map<String, dynamic>? newValue) {
                  setState(() {
                    _selectedLoad = newValue;
                    priceController.text = newValue?['price'].toString() ?? "";
                  });
                },
                'typeofload',
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: priceController,
                decoration: const InputDecoration(
                  enabled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  labelText: 'Load Price (not input auto)',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: deliveryController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  labelText: 'Delivery price',
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
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  labelText: 'Volume (m³)',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.orangeAccent,
          ),
          onPressed: _addLoadEntry,
          child: const Text('Add Load',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            color: Colors.grey[100],
            elevation: 3,
            child: ListView.builder(
              itemCount: selectedLoads.length,
              itemBuilder: (context, index) {
                final load = selectedLoads[index];
                return ListTile(
                  title: Text(
                      'Load: ${load['typeofload']}, Volume: ${load['volume']}, Price: ${load['loadPrice']}, Delivery Fee: ${load['deliveryFee']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeLoadEntry(index),
                  ),
                );
              },
            ),
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
          child: const AutoSizeText(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
