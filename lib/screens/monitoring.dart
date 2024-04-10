import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/main.dart';

class Monitoring extends StatefulWidget {
  static const routeName = '/Monitoring';

  const Monitoring({super.key});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  List<Map<String, dynamic>> orders = [];

  Future<void> fetchData() async {
    try {
      final data = await supabase.from('purchaseOrder').select('*');
      setState(() {
        orders = data;
      });
    } catch (error) {
      print('Nothing to print');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

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
            color: const Color(0xFFF8E6C3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  monitorCard(
                    orders[index]['id'.toString()],
                    orders[index]['custName'],
                    orders[index]['date'].toString(),
                    orders[index]['address'],
                    orders[index]['description'],
                    orders[index]['volume'].toString(),
                    orders[index]['price'].toString(),
                    orders[index]['quantity'].toString(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Card monitorCard(
    int id,
    String custName,
    String address,
    String description,
    String price,
    String date,
    String volume,
    String quantity,
  ) {
    return Card(
      color: const Color(0xFFffca61),
      child: SizedBox(
        width: 500,
        height: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(id.toString()),
                Text(custName),
                Text(address),
                Text(description),
                Divider(),
                Text(volume),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFeab557),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "0/21,000",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(date),
                Text(volume),
                Text(quantity),
                Text(volume),
                Divider(),
                Text(quantity),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFeab557),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "0/21",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
