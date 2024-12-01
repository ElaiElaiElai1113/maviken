import 'package:flutter/material.dart';
import 'package:maviken/components/layoutBuilderPage.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/screens/all_load.dart';
import 'package:maviken/components/info_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController loadController = TextEditingController();

class ProfileLoadtype extends StatefulWidget {
  static const routeName = '/ProfileLoadtype';
  const ProfileLoadtype({super.key});

  @override
  State<ProfileLoadtype> createState() => _ProfileLoadtypeState();
}

class _ProfileLoadtypeState extends State<ProfileLoadtype> {
  List<Map<String, dynamic>> loadList = [];
  bool isLoading = false;

  Future<void> fetchLoad() async {
    setState(() => isLoading = true);
    final response =
        await Supabase.instance.client.from('typeofload').select('*');
    setState(() {
      loadList = response.map((e) => Map<String, dynamic>.from(e)).toList();
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchLoad();
  }

  Future<void> newLoad() async {
    if (loadController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Load Type cannot be empty!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      final response =
          await Supabase.instance.client.from('typeofload').insert([
        {'loadtype': loadController.text.trim()},
      ]);

      if (response.error != null) {
        throw response.error!;
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Load successfully added!"),
        backgroundColor: Colors.green,
      ));
      loadController.clear();
      fetchLoad();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error has occurred: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilderPage(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      page: buildSupplierForm(screenWidth, screenHeight, context),
      label: "Load Profiling",
    );
  }

  SingleChildScrollView buildSupplierForm(
      double screenWidth, double screenHeight, BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(25),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Load Type",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: infoButton(
                      screenWidth * 0.9,
                      screenHeight * 0.1,
                      "Load Type",
                      loadController,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: 'Save',
                    icon: null,
                    onPressed: newLoad,
                    width: screenWidth * 0.1,
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    text: '',
                    icon: Icons.read_more,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllLoadPage(),
                        ),
                      );
                    },
                    width: screenWidth * 0.1,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: screenHeight * 0.4, // Adjust height as needed
                    child: loadList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection:
                                Axis.vertical, // Enable vertical scrolling
                            child: SingleChildScrollView(
                              scrollDirection: Axis
                                  .horizontal, // Enable horizontal scrolling
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Load ID')),
                                  DataColumn(label: Text('Load Type')),
                                ],
                                rows: loadList.map((load) {
                                  return DataRow(cells: [
                                    DataCell(Text(load['loadID'].toString())),
                                    DataCell(Text(load['loadtype'].toString())),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final double width;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.orangeAccent,
        ),
        onPressed: onPressed,
        child: icon != null
            ? Icon(icon, color: Colors.white)
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
