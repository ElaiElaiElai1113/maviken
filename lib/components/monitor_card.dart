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

  @override
  void initState() {
    super.initState();
    cardHeight = widget.initialHeight;
    cardWidth = widget.initialWidth;
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
                    Text(widget.custName),
                    Text(widget.address),
                    Text(widget.description),
                    const Divider(),
                    Text(widget.volume),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFeab557),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "/21,000",
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
                    Text(widget.date),
                    Text(widget.volume),
                    Text(widget.quantity),
                    Text(widget.volume),
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
                          "/21",
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
                setState(() {
                  cardHeight += 400;
                  cardWidth += 550;
                });
              },
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
