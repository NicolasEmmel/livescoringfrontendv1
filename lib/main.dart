import 'package:flutter/material.dart';
import 'package:livescoringfrontendv1/services/signalr_service.dart';
import 'package:provider/provider.dart';
import 'package:livescoringfrontendv1/landingpage.dart';
import 'providers/flight_score_provider.dart';
import 'providers/game_provider.dart';
import 'ryder_cup_leaderboard.dart';
import 'games_scores_page.dart';

void main() {
  final signalRService = SignalRService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SignalRService>.value(value: signalRService),
        ChangeNotifierProvider(
          create: (_) => FlightScoreProvider(signalRService),
        ),
        ChangeNotifierProvider(create: (_) => GameProvider()),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/leaderboard': (context) =>
            const RyderCupLeaderboardPage(source: 'scoring'),
        '/games-scores': (context) => const GamesScoresPage(),
      },
    );
  }
}
