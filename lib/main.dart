import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:maviken/screens/accountsReceivables.dart';
import 'package:maviken/screens/all_load.dart';
import 'package:maviken/screens/fleetManage.dart';
import 'package:maviken/screens/maintenanceLogs.dart';
import 'package:maviken/screens/management.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/screens/all_customer.dart';
import 'package:maviken/screens/all_employee.dart';
import 'package:maviken/screens/all_supplier.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/profile_customer.dart';
import 'package:maviken/screens/profiling.dart';
import 'package:maviken/screens/profile_supplier.dart';
import 'package:maviken/screens/profile_trucks.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/create_account.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/components/HaulingAdviceCard2.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://inwedmhzhjaensuawcyf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlud2VkbWh6aGphZW5zdWF3Y3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDg3Njg1ODUsImV4cCI6MjAyNDM0NDU4NX0.E0ErllIEXy9sCA3ynUw2Ta7XJIZXj6MXRtJSArFoXbo',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ConnectivityResult _connectivityResult;
  late Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _connectivityStream = Connectivity().onConnectivityChanged;
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = result;
    });

    if (result == ConnectivityResult.none) {
      showNoInternetError();
    }
  }

  void showNoInternetError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No internet connection. Please check your network.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MAVIKEN',
      home: const LoginScreen(),
      routes: {
        DashBoard.routeName: (context) => const DashBoard(),
        NewOrder.routeName: (context) => const NewOrder(),
        Monitoring.routeName: (context) => const Monitoring(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        Profiling.routeName: (context) => const Profiling(),
        ProfileSupplier.routeName: (context) => const ProfileSupplier(),
        ProfileCustomer.routeName: (context) => const ProfileCustomer(),
        ProfileTrucks.routeName: (context) => const ProfileTrucks(),
        HaulingAdvice.routeName: (context) => const HaulingAdvice(),
        CreateAccount.routeName: (context) => const CreateAccount(),
        HaulingAdviceList.routeName: (context) => const HaulingAdviceList(),
        AllEmployeePage.routeName: (context) => const AllEmployeePage(),
        AllCustomerPage.routeName: (context) => const AllCustomerPage(),
        allSupplierPage.routeName: (context) => const allSupplierPage(),
        AllLoadPage.routeName: (context) => const AllLoadPage(),
        PriceManagement.routeName: (context) => const PriceManagement(),
        fleetManagement.routeName: (context) => const fleetManagement(),
        Accountsreceivables.routeName: (context) => const Accountsreceivables(),
        MaintenanceLogs.routeName: (context) => const MaintenanceLogs(),
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
