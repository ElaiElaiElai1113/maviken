import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:maviken/components/HaulingAdviceCard2.dart';
import 'package:maviken/components/haulingAdviceCard.dart';

class MonitorCard extends StatefulWidget {
  final String id;
  final String custName;
  final String address;
  final String typeofload;
  final String price;
  final String date;
  final String totalVolume;
  final String quantity;
  final String volumeDel;
  final double screenWidth;
  final double initialHeight;
  final double initialWidth;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MonitorCard({
    super.key,
    required this.id,
    required this.custName,
    required this.address,
    required this.typeofload,
    required this.price,
    required this.date,
    required this.totalVolume,
    required this.quantity,
    required this.volumeDel,
    required this.screenWidth,
    required this.initialHeight,
    required this.initialWidth,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _MonitorCardState createState() => _MonitorCardState();
}

class _MonitorCardState extends State<MonitorCard> {
  double cardHeight = 0;
  double cardWidth = 0;
  bool showHaulingAdviceCard = false;

  @override
  void initState() {
    super.initState();
    cardHeight = widget.initialHeight;
    cardWidth = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.grey[100],
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: cardHeight * 0.2,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.orangeAccent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 18,
                            '${widget.id} - ${widget.custName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black),
                          onPressed: widget.onDelete,
                        ),
                        IconButton(
                          icon: const Icon(Icons.list, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              Navigator.pushNamed(
                                  context, HaulingAdviceList.routeName,
                                  arguments: widget.id);
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: widget.onEdit,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AutoSizeText(
                        "Date: ${widget.date}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      AutoSizeText(
                        "Address: ${widget.address}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      AutoSizeText(
                        "Type: ${widget.typeofload}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Color(0xFFffca61),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AutoSizeText(
                      "Volume: ${widget.volumeDel} / ${widget.totalVolume}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (showHaulingAdviceCard)
                  SizedBox(
                    height: cardHeight * 0.5,
                    child: HaulingAdviceCard(salesOrderId: widget.id),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
