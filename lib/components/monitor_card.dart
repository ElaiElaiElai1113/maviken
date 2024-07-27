import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
            color: const Color.fromARGB(255, 243, 186, 47),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color.fromARGB(255, 30, 35, 41),
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
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                onPressed: widget.onDelete,
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
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
                              widget.date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            AutoSizeText(
                              widget.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            AutoSizeText(
                              widget.typeofload,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Divider(
                              color: Color(0xFFffca61),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 30, 35, 41),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AutoSizeText(
                                  "Volume: ${widget.volumeDel} / ${widget.totalVolume}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            )));
  }
}
