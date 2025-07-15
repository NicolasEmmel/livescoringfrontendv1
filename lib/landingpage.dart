import 'package:flutter/material.dart';
import 'package:livescoringfrontendv1/scanningpage.dart';

class LandingPage extends StatelessWidget
{
const LandingPage({super.key});

@override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerPage()),
    );
  },
  child: const Text('Go to your Flight'),
    );
    
  }

}