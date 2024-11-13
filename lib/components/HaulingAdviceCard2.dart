// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:maviken/main.dart';

class HaulingAdviceList extends StatefulWidget {
  static const routeName = '/HaulingAdviceList2';

  const HaulingAdviceList({super.key});

  @override
  _HaulingAdviceListState createState() => _HaulingAdviceListState();
}

class _HaulingAdviceListState extends State<HaulingAdviceList> {
  List<Map<String, dynamic>> orders = [];

  String? _salesOrderId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _salesOrderId = ModalRoute.of(context)?.settings.arguments as String?;
  }

  void deleteOrder(int index) async {
    final orderId = orders[index]['haulingAdviceId'];
    final volumeDelToDelete = orders[index]['volumeDel'];

    try {
      print('Deleting Hauling Advice with ID: $orderId');

      final haulingAdviceResponse = await supabase
          .from('haulingAdvice')
          .delete()
          .eq('haulingAdviceId', orderId);

      final deliveryResponse =
          await supabase.from('delivery').delete().eq('deliveryid', orderId);

      final currentSalesOrder = await supabase
          .from('salesOrder')
          .select('volumeDel')
          .eq('salesOrder_id', _salesOrderId as Object)
          .single();

      final currentVolumeDel = currentSalesOrder['volumeDel'] as int;

      final updatedVolumeDel = currentVolumeDel - volumeDelToDelete;

      await supabase
          .from('salesOrder')
          .update({'volumeDel': updatedVolumeDel}).eq(
              'salesOrder_id', _salesOrderId as Object);

      setState(() {
        orders.removeAt(index);
      });

      print('Order deleted successfully');
    } catch (error) {
      print('Error deleting order: $error');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete order: $error'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  Future<List<dynamic>> _fetchHaulingAdvice() async {
    final response = await supabase
        .from('haulingAdvice')
        .select('*, Truck(plateNumber)')
        .eq('salesOrder_id', _salesOrderId as Object);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 11, 14, 17),
        ),
        child: FutureBuilder(
          future: _fetchHaulingAdvice(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              orders = snapshot.data! as List<Map<String, dynamic>>;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final advice = snapshot.data![index];
                  final truck = advice['Truck'];

                  return Drawer(
                    child: Container(
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.6,
                      margin: const EdgeInsets.all(10),
                      child: Card(
                        color: const Color.fromARGB(255, 240, 185, 11),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Color.fromARGB(255, 30, 35, 41),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Advice ID: ${advice['haulingAdviceId'].toString()}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Date: ${advice['date'].toString()}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Truck ID: ${advice['truckID'].toString()}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Volume Delivered: ${advice['volumeDel'].toString()}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Plate Number: ${truck != null ? truck['plateNumber'].toString() : 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            deleteOrder(index);
                                          },
                                          icon: const Icon(Icons.delete)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
