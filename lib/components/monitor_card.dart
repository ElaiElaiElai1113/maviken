import 'package:flutter/material.dart';

class monitorCard extends StatefulWidget {
  final String id;
  final String custName;
  final String address;
  final String description;
  final String price;
  final String date;
  final String volume;
  final String quantity;
  final double screenWidth;
  final double initialHeight;
  final double initialWidth;

    const monitorCard({
    required this.id,
    required this.custName,
    required this.address,
    required this.description,
    required this.price,
    required this.date,
    required this.volume,
    required this.quantity,
    required this.screenWidth,
    required this.initialHeight,
    required this.initialWidth,
  });

  @override
  _monitorCardState createState() => _monitorCardState();
}

class _monitorCardState extends State<monitorCard> {
  double cardHeight = 0;
  double cardWidth = 0;

  late String editedCustName;
  late String editedAddress;
  late String editedDescription;
  late String editedVolume;
  late String editedQuantity;
  late String editedDate;

  @override
  void initState() {
    super.initState();
    cardHeight = widget.initialHeight;
    cardWidth = widget.initialWidth;
    editedCustName = widget.custName;
    editedAddress = widget.address;
    editedDescription = widget.description;
    editedVolume = widget.volume;
    editedQuantity = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFffca61),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(widget.id),
                    TextField(
                      controller: TextEditingController(text: editedCustName),
                      onChanged: (value) {
                        setState(() {
                          editedCustName = value;
                        });
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: editedAddress),
                      onChanged: (value) {
                        setState(() {
                          editedAddress = value;
                        });
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: editedDescription),
                      onChanged: (value) {
                        setState(() {
                          editedDescription = value;
                        });
                      },
                    ),
                    const Divider(),
                    TextField(
                      controller: TextEditingController(text: editedVolume),
                      onChanged: (value) {
                        setState(() {
                          editedVolume = value;
                        });
                      },
                    ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextField(
                      controller: TextEditingController(text: widget.date),
                      onChanged: (value) {
                        setState(() {
                          editedDate = value;
                        });
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: editedQuantity),
                      onChanged: (value) {
                        setState(() {
                          editedQuantity = value;
                        });
                      },
                    ),
                    const Divider(),
                    Text(widget.quantity),
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
            ElevatedButton(
              onPressed: () {
                print('Edited Customer Name: $editedCustName');
                print('Edited Address: $editedAddress');
                print('Edited Description: $editedDescription');
                print('Edited Volume: $editedVolume');
                print('Edited Quantity: $editedQuantity');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}