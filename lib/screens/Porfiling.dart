import 'package:flutter/material.dart';
import 'package:maviken/components/navbar.dart';

class Profiling extends StatefulWidget {
  const Profiling({super.key});

  @override
  State<Profiling> createState() => _ProfilingState();
}

class _ProfilingState extends State<Profiling> {
  @override
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
      ),
    );
  }
}
