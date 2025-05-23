import 'package:flutter/material.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/accountsReceivables.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/fleetManage.dart';
import 'package:maviken/screens/hauling_advice.dart' as haulingAdvice;
import 'package:maviken/screens/inventory.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/maintenanceLogs.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/screens/management.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/payRoll.dart';
import 'package:maviken/screens/profile_loadtype.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:maviken/screens/profile_trucks.dart';
import 'package:maviken/screens/profiling.dart';
import 'package:maviken/screens/reports.dart';

class BarTop extends StatefulWidget implements PreferredSizeWidget {
  const BarTop({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromWidth(600);

  @override
  _BarTopState createState() => _BarTopState();
}

class _BarTopState extends State<BarTop> {
  String? selectedRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedRoute = ModalRoute.of(context)?.settings.name;
  }

  void navigateTo(String routeName) {
    setState(() {
      selectedRoute = routeName;
    });
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      backgroundColor: Colors.orangeAccent,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://plus.unsplash.com/premium_photo-1663040229714-f9fd192358b0?q=80&w=2938&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              child: Image.asset(
                "lib/assets/mavikenlogo.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text(
              'Dashboard',
            ),
            selected: selectedRoute == DashBoard.routeName,
            selectedColor: const Color(0xFF0a438f),
            selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
            onTap: () => navigateTo(DashBoard.routeName),
          ),
          ListTile(
            leading: const Icon(
              Icons.add_box,
            ),
            title: const Text(
              'New Order',
            ),
            selected: selectedRoute == NewOrder.routeName,
            selectedColor: const Color(0xFF0a438f),
            selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
            onTap: () => navigateTo(NewOrder.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.car_crash_rounded),
            title: const Text('Hauling Advice'),
            selected: selectedRoute == haulingAdvice.HaulingAdvice.routeName,
            selectedColor: const Color(0xFF0a438f),
            selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
            onTap: () => navigateTo(haulingAdvice.HaulingAdvice.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.monitor),
            title: const Text('Monitoring'),
            selected: selectedRoute == Monitoring.routeName,
            selectedColor: const Color(0xFF0a438f),
            selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
            onTap: () => navigateTo(Monitoring.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('Payroll'),
            selected: selectedRoute == Payroll.routeName,
            selectedColor: const Color(0xFF0a438f),
            onTap: () => navigateTo(Payroll.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Invoices'),
            selected: selectedRoute == PriceManagement.routeName,
            selectedColor: const Color(0xFF0a438f),
            selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
            onTap: () => navigateTo(AccountsReceivables.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Reports'),
            selected: selectedRoute == Reports.routeName,
            selectedColor: const Color(0xFF0a438f),
            selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
            onTap: () => navigateTo(Reports.routeName),
          ),
          ExpansionTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profiling'),
            backgroundColor: const Color(0xFFeab557),
            iconColor: const Color(0xFF0a438f),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Customer Profiling'),
                selected: selectedRoute == ProfileCustomer.routeName,
                selectedColor: const Color(0xFF0a438f),
                selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
                onTap: () => navigateTo(ProfileCustomer.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Employee Profiling'),
                selected: selectedRoute == Profiling.routeName,
                selectedColor: const Color(0xFF0a438f),
                selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
                onTap: () => navigateTo(Profiling.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping),
                title: const Text('Truck Profiling'),
                selected: selectedRoute == ProfileTrucks.routeName,
                selectedColor: const Color(0xFF0a438f),
                selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
                onTap: () => navigateTo(ProfileTrucks.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Supplier Profiling'),
                selected: selectedRoute == ProfileSupplier.routeName,
                selectedColor: const Color(0xFF0a438f),
                selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
                onTap: () => navigateTo(ProfileSupplier.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.price_change),
                title: const Text('Load Profiling'),
                selected: selectedRoute == PriceManagement.routeName,
                selectedColor: const Color(0xFF0a438f),
                selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
                onTap: () => navigateTo(ProfileLoadtype.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: const Text('Management'),
                selected: selectedRoute == PriceManagement.routeName,
                selectedColor: const Color(0xFF0a438f),
                selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
                onTap: () => navigateTo(PriceManagement.routeName),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Fleet Management'),
            backgroundColor: const Color(0xFFeab557),
            iconColor: const Color(0xFF0a438f),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Truck Management'),
                selected: selectedRoute == fleetManagement.routeName,
                selectedColor: const Color(0xFF0a438f),
                selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
                onTap: () => navigateTo(fleetManagement.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Maintenance Logs'),
                selected: selectedRoute == MaintenanceLogs.routeName,
                selectedColor: const Color(0xFF0a438f),
                selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
                onTap: () => navigateTo(MaintenanceLogs.routeName),
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Inventory'),
                selected: selectedRoute == Inventory.routeName,
                selectedColor: const Color(0xFF0a438f),
                selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
                onTap: () => navigateTo(Inventory.routeName),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            selected: selectedRoute == LoginScreen.routeName,
            selectedTileColor: const Color.fromARGB(255, 216, 147, 29),
            onTap: () => navigateTo(LoginScreen.routeName),
          ),
        ],
      ),
    );
  }
}
