import 'package:flutter/material.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/screens/priceManagement.dart';
import 'package:maviken/screens/profile_employee.dart';

class BarTop extends StatelessWidget implements PreferredSizeWidget {
  const BarTop({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      backgroundColor: const Color(0xFFEAECEF),
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
            title: const Text('Dashboard'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, DashBoard.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('New Order'),
            onTap: () => Navigator.pushNamed(context, NewOrder.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.car_crash_rounded),
            title: const Text('Hauling Advice'),
            onTap: () => Navigator.pushNamed(context, HaulingAdvice.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.monitor),
            title: const Text('Monitoring'),
            onTap: () => Navigator.pushNamed(context, Monitoring.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profiling'),
            onTap: () =>
                Navigator.pushNamed(context, ProfileEmployee.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.price_change),
            title: const Text('Management'),
            onTap: () =>
                Navigator.pushNamed(context, PriceManagement.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () =>
                Navigator.popAndPushNamed(context, LoginScreen.routeName),
          ),
        ],
      ),
    );
  }
}
