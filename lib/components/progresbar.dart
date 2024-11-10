import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Progresbar extends StatefulWidget {
  const Progresbar({super.key});

  @override
  State<Progresbar> createState() => _ProgresbarState();
}

class _ProgresbarState extends State<Progresbar> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: LinearPercentIndicator(
        width: MediaQuery.of(context).size.width * 0.8,
        lineHeight: 20,
        percent: 0.6,
        backgroundColor: Colors.purple.shade100,
        progressColor: Colors.purple,
        center: const Text(
          "60%",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        barRadius: Radius.circular(10),
      ),
    );
  }
}
