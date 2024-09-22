import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:sidebar_drawer/sidebar_drawer.dart';

class DashBoard extends StatelessWidget {
  static const routeName = '/DashBoard';
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const BarTop(),
      body: SidebarDrawer(
        drawer: const BarTop(),
        body: Container(
          color: Colors.white,
          width: screenWidth,
          height: screenHeight,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                leading: const DrawerIcon(),
                title: const Text("Dashboard"),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(50),
                  child: Container(
                    padding: const EdgeInsets.all(50),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
