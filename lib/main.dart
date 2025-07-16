import 'package:flutter/material.dart';
import 'package:livescoringfrontendv1/services/signalr_service.dart';
import 'package:provider/provider.dart';
import 'package:livescoringfrontendv1/landingpage.dart';
import 'package:livescoringfrontendv1/scoring.dart';
import 'leaderboard.dart';
import 'providers/flight_score_provider.dart';

void main() {
  final signalRService = SignalRService();
  runApp(
    MultiProvider(
      providers: [
        Provider<SignalRService>.value(value: signalRService),
        ChangeNotifierProvider(
          create: (_) => FlightScoreProvider(signalRService),
        ),
      ],
      child: const MyApp(), // replace with your root widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Scoring',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
