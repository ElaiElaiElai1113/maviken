import 'package:flutter/material.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/screens/profile_employee.dart';

class BarTop extends StatelessWidget implements PreferredSizeWidget {
  const BarTop({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFEAECEF),
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
            ),
            child: Text(
              'MAVIKEN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('New Order'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, NewOrder.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.car_crash_rounded),
            title: const Text('Hauling Advice'),
            onTap: () => Navigator.pushReplacementNamed(
                context, HaulingAdvice.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.monitor),
            title: const Text('Monitoring'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, Monitoring.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profiling'),
            onTap: () => Navigator.pushReplacementNamed(
                context, ProfileEmployee.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, DashBoard.routeName),
          ),
        ],
      ),
    );
  }
}
