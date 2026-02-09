import 'package:flutter/material.dart';

class BlePairedScreen extends StatelessWidget {
  const BlePairedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: const Text(
            "Bracelet Paired Successfully",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
