import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';

class Inventory extends StatefulWidget {
  static const routeName = '/inventoryPage';
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return LayoutBuilderPage(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: inventoryPage(screenWidth, screenHeight, context),
        label: ('Inventory'));
  }

  SingleChildScrollView inventoryPage(
    double screenWidth,
    double screenHeight,
    BuildContext context,
  ) {
    return SingleChildScrollView();
  }
}
