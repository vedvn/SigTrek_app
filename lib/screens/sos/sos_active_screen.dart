import 'package:flutter/material.dart';

class SosActiveScreen extends StatelessWidget {
  const SosActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.warning, color: Colors.red, size: 80),
            SizedBox(height: 16),
            Text(
              'SOS ACTIVE',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Live location is being shared',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
