import 'package:flutter/material.dart';
import 'package:maviken/screens/HaulingAdvice.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/create_account.dart';
import 'package:maviken/screens/newOrderOwner.dart';
import 'package:maviken/screens/loginScreen.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: const TextTheme(
            bodyLarge: TextStyle(),
            bodyMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            bodySmall: TextStyle(),
            titleMedium: TextStyle(),
            titleSmall: TextStyle(),
            titleLarge: TextStyle(),
          ).apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        title: 'MAVIKEN',
        home: const LoginScreen(),
        routes: {
          DashBoard.routeName: (context) => const DashBoard(),
          NewOrder.routeName: (context) => const NewOrder(),
          Monitoring.routeName: (context) => const Monitoring(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          ProfileEmployee.routeName: (context) => const ProfileEmployee(),
          HaulingAdvice.routeName: (context) => const HaulingAdvice(),
          createAccount.routeName: (context) => const createAccount(),
        });
  }
}
