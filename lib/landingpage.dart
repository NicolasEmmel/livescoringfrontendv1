import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:livescoringfrontendv1/ryder_cup_games_page.dart';
import '../providers/flight_score_provider.dart';
import '../providers/game_provider.dart';
import 'services/signalr_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Set up navigation callback for when games are received
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signalR = Provider.of<SignalRService>(context, listen: false);
      signalR.setNavigationCallback((games) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RyderCupGamesPage()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF959F96), Color(0xFFE5E5E5), Color(0xFFE5E5E5)],
            stops: [0.0, 0.7, 1.0],
            radius: 0.8,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.golf_course,
                  size: 120,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Ryder-Cup 2025',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(80, 255, 255, 255),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1,
                          spreadRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Consumer<SignalRService>(
                        builder: (context, signalR, child) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: signalR.isConnecting
                                ? null
                                : () async {
                                    const int maxRetries = 3;
                                    const Duration retryDelay = Duration(
                                      milliseconds: 500,
                                    );

                                    // Set connecting state manually for the entire retry process
                                    signalR.setConnectingState(true);

                                    for (
                                      int attempt = 1;
                                      attempt <= maxRetries;
                                      attempt++
                                    ) {
                                      try {
                                        print(
                                          "🔄 Connection attempt $attempt of $maxRetries",
                                        );

                                        // Start SignalR connection
                                        signalR.setScoreProvider(
                                          Provider.of<FlightScoreProvider>(
                                            context,
                                            listen: false,
                                          ),
                                        );
                                        signalR.setGameProvider(
                                          Provider.of<GameProvider>(
                                            context,
                                            listen: false,
                                          ),
                                        );
                                        await signalR.startConnection();

                                        // Success! The navigation will happen automatically when games are received
                                        print(
                                          "✅ SignalR connected, waiting for games...",
                                        );
                                        return; // Exit the retry loop on success
                                      } catch (e) {
                                        print(
                                          "❌ Connection attempt $attempt failed: $e",
                                        );

                                        if (attempt < maxRetries) {
                                          // Wait before retrying
                                          await Future.delayed(retryDelay);
                                        } else {
                                          // All retries failed
                                          signalR.setConnectingState(false);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Verbindungsfehler nach $maxRetries Versuchen: Bitte erneut versuchen',
                                                ),
                                                backgroundColor: Colors.red,
                                                duration: const Duration(
                                                  seconds: 3,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    }
                                  },
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (signalR.isConnecting)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF2E7D32),
                                            ),
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.qr_code_scanner,
                                      color: Color(0xFF2E7D32),
                                      size: 28,
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    signalR.isConnecting
                                        ? 'Verbinde...'
                                        : 'Flightauswahl',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Leaderboard Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(80, 255, 255, 255),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1,
                          spreadRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pushNamed(context, '/leaderboard');
                        },
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.leaderboard,
                                color: Color(0xFF2E7D32),
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Leaderboard anzeigen',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
