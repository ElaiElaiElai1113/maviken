import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/components/monitor_card.dart';
import 'package:maviken/main.dart';

class Monitoring extends StatefulWidget {
  static const routeName = '/Monitoring';

  const Monitoring({Key? key}) : super(key: key);

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  List<Map<String, dynamic>> orders = [];

  Future<void> fetchData() async {
    final data = await supabase.from('purchaseOrder').select('*');
    setState(() {
      orders = data;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const BarTop(),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: const Color(0xFFFCF7E6),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 236, 223, 196),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView(
            children: [
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 15,
                  alignment: WrapAlignment.start,
                  children: List.generate(
                    orders.length,
                    (index) {
                      return monitorCard(
                        id: orders[index]['id'].toString(),
                        custName: orders[index]['custName'],
                        date: orders[index]['date'].toString(),
                        address: orders[index]['address'],
                        description: orders[index]['description'],
                        volume: orders[index]['volume'].toString(),
                        price: orders[index]['price'].toString(),
                        quantity: orders[index]['quantity'].toString(),
                        screenWidth: screenWidth * .25,
                        initialHeight: screenHeight * .30,
                        initialWidth: screenWidth * .25,
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
