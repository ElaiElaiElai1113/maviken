import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';

class allEmployeePage extends StatefulWidget {
  static const routeName = '/employeePage';
  const allEmployeePage({super.key});

  @override
  State<allEmployeePage> createState() => _allEmployeePageState();
}

class _allEmployeePageState extends State<allEmployeePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const BarTop(),
        body: SidebarDrawer(
            body: Container(
              color: Colors.red,
            ),
            drawer: const BarTop()));
  }
}
