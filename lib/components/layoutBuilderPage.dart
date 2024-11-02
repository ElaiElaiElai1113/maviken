import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/main.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/hauling_advice.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:maviken/screens/monitoring.dart';
import 'package:maviken/screens/new_order.dart';
import 'package:maviken/screens/priceManagement.dart';
import 'package:maviken/screens/profiling.dart';

class LayoutBuilderPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final Widget page;
  final String label;

  const LayoutBuilderPage({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.page,
    required this.label,
  }) : super(key: key);

  @override
  _LayoutBuilderPageState createState() => _LayoutBuilderPageState();
}

class _LayoutBuilderPageState extends State<LayoutBuilderPage> {
  bool _isBarTopVisible = true;
  int _currentIndex = 1;

  void toggleBarTop() {
    setState(() {
      _isBarTopVisible = !_isBarTopVisible;
    });
  }

  void _setCurrentIndex() {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    switch (currentRoute) {
      case DashBoard.routeName:
        _currentIndex = 0;
        break;
      case NewOrder.routeName:
        _currentIndex = 1;
        break;
      case HaulingAdvice.routeName:
        _currentIndex = 2;
        break;
      case Monitoring.routeName:
        _currentIndex = 3;
        break;
      case Profiling.routeName:
        _currentIndex = 4;
        break;
      case PriceManagement.routeName:
        _currentIndex = 5;
        break;
      default:
        _currentIndex = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _setCurrentIndex();
  }

  Widget build(BuildContext context) {
    bool isWideScreen = widget.screenWidth > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        return isWideScreen
            ? Scaffold(
                body: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.horizontal,
                                child: child,
                              ),
                              child: _isBarTopVisible
                                  ? const BarTop()
                                  : sideNavRail(context),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  AppBar(
                                    title: Text(widget.label),
                                    backgroundColor: Colors.white,
                                    leading: IconButton(
                                      onPressed: toggleBarTop,
                                      icon: Icon(
                                        _isBarTopVisible
                                            ? Icons.arrow_back
                                            : Icons.menu,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(50.0),
                                      child: widget.page,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: Text(widget.label),
                  backgroundColor: Colors.white,
                ),
                body: Row(
                  children: [
                    if (widget.screenWidth < 600) sideNavRail(context),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(50),
                        color: Colors.white,
                        child: widget.page,
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  NavigationRail sideNavRail(BuildContext context) {
    return NavigationRail(
      labelType: NavigationRailLabelType.all,
      backgroundColor: const Color(0xFFeab557),
      selectedIndex: _currentIndex,
      useIndicator: true,
      indicatorColor: const Color.fromARGB(255, 216, 147, 29),
      onDestinationSelected: (int index) {
        setState(() {
          _currentIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, DashBoard.routeName);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, NewOrder.routeName);

            break;
          case 2:
            Navigator.pushReplacementNamed(context, HaulingAdvice.routeName);
            break;
          case 3:
            Navigator.pushReplacementNamed(context, Monitoring.routeName);
            break;
          case 4:
            Navigator.pushReplacementNamed(context, Profiling.routeName);
            break;
          case 5:
            Navigator.pushReplacementNamed(context, PriceManagement.routeName);
            break;
          case 6:
            supabase.auth.signOut();
            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            break;
        }
        _setCurrentIndex();
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
    );
  }
}
