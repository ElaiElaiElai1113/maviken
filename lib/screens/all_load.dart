import 'package:flutter/material.dart';
import 'package:maviken/components/load_card.dart';
import 'package:maviken/components/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoadPage extends StatefulWidget {
  static const routeName = "/LoadPage";
  const LoadPage({super.key});

  @override
  State<LoadPage> createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  List<dynamic> loadList = [];

  Future<void> fetchSalesOrderLoad() async {
    final response = Supabase.instance.client
        .from('salesOrderLoad')
        .select('*, typeofload!inner(*), salesOrder(*)');
    if (mounted) {
      setState(() {
        loadList = response as List<dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: BarTop(),
      body: ListView.builder(
        itemCount: loadList.length,
        itemBuilder: (context, index) {
          final load = loadList[index];
          return LoadCard(
            price: load['price'].toString(),
            totalVolume: ['totalVolume'].toString(),
            volumeDel: load['volumeDel'].toString(),
            onEdit: () {},
            onDelete: () {},
          );
        },
      ),
    );
  }
}
