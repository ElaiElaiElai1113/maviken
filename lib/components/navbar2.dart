import 'package:flutter/material.dart';
import 'package:maviken/screens/Monitoring.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/screens/priceManagement.dart';
import 'package:maviken/screens/profiling.dart';

class CollapsibleSidebar extends StatefulWidget {
  const CollapsibleSidebar({super.key});

  @override
  _CollapsibleSidebarState createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  bool _isCollapsed = true;

  void toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: toggleSidebar,
          child: Container(
            width: _isCollapsed ? 60 : 200,
            color: const Color(0xFFeab557),
            child: Column(
              children: [
                // Add your logo or header here
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://plus.unsplash.com/premium_photo-1663040229714-f9fd192358b0?q=80&w=2938&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Image.asset(
                    "lib/assets/mavikenlogo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                const Divider(color: Colors.black),
                Expanded(
                  child: ListView(
                    children: [
                      _buildListTile(
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        route: DashBoard.routeName,
                      ),
                      _buildListTile(
                        icon: Icons.add_box,
                        title: 'New Order',
                        route: NewOrder.routeName,
                      ),
                      _buildListTile(
                        icon: Icons.car_crash_rounded,
                        title: 'Hauling Advice',
                        route: HaulingAdvice.routeName,
                      ),
                      _buildListTile(
                        icon: Icons.monitor,
                        title: 'Monitoring',
                        route: Monitoring.routeName,
                      ),
                      _buildListTile(
                        icon: Icons.account_circle,
                        title: 'Profiling',
                        route: Profiling.routeName,
                      ),
                      _buildListTile(
                        icon: Icons.price_change,
                        title: 'Management',
                        route: PriceManagement.routeName,
                      ),
                      _buildListTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        route: LoginScreen.routeName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white, // Main content area
            child: const Center(
              child: Text(
                'Main Content Area',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
      {required IconData icon, required String title, required String route}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0a438f)),
      title: _isCollapsed
          ? null
          : Text(title, style: const TextStyle(color: Color(0xFF0a438f))),
      onTap: () => Navigator.pushReplacementNamed(context, route),
    );
  }
}
