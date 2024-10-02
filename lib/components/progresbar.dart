import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Progresbar extends StatefulWidget {
  const Progresbar({super.key});

  @override
  State<Progresbar> createState() => _ProgresbarState();
}

class _ProgresbarState extends State<Progresbar> {
  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 30,
      lineWidth: 20,
      percent: .6,
      progressColor: Colors.yellow,
      backgroundColor: Colors.yellow.shade100,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}
