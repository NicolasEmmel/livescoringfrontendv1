import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mulligan_cup_provider.dart';
import 'services/signalr_service.dart';
import 'ryder_cup_games_page.dart';
import 'leaderboard.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String?
  _pendingNavigation; // Track which page to navigate to after connection

  @override
  void initState() {
    super.initState();
    // Set up navigation callback for when Mulligan Cup data is received
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signalR = Provider.of<SignalRService>(context, listen: false);
      signalR.setMulliganCupNavigationCallback((flights, leaderboard) {
        if (mounted && _pendingNavigation != null) {
          if (_pendingNavigation == 'games') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RyderCupGamesPage(),
              ),
            );
          } else if (_pendingNavigation == 'leaderboard') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const LeaderboardPage(source: 'landing', currentHole: 0),
              ),
            );
          }
          _pendingNavigation = null; // Reset after navigation
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
                  'Mulligan-Cup 2025',
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

                                    // Set pending navigation for games page
                                    _pendingNavigation = 'games';

                                    for (
                                      int attempt = 1;
                                      attempt <= maxRetries;
                                      attempt++
                                    ) {
                                      try {
                                        print(
                                          "🔄 Connection attempt $attempt of $maxRetries",
                                        );

                                        // Set up providers
                                        signalR.setMulliganCupProvider(
                                          Provider.of<MulliganCupProvider>(
                                            context,
                                            listen: false,
                                          ),
                                        );

                                        // Start SignalR connection
                                        await signalR.startConnection();

                                        // Success! The navigation will happen automatically when data is received
                                        print(
                                          "✅ SignalR connected, waiting for Mulligan Cup data...",
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

                                    // Set pending navigation for leaderboard page
                                    _pendingNavigation = 'leaderboard';

                                    for (
                                      int attempt = 1;
                                      attempt <= maxRetries;
                                      attempt++
                                    ) {
                                      try {
                                        print(
                                          "🔄 Leaderboard connection attempt $attempt of $maxRetries",
                                        );

                                        // Set up providers
                                        signalR.setMulliganCupProvider(
                                          Provider.of<MulliganCupProvider>(
                                            context,
                                            listen: false,
                                          ),
                                        );

                                        // Start SignalR connection
                                        await signalR.startConnection();

                                        // Success! The navigation will happen automatically when data is received
                                        print(
                                          "✅ SignalR connected for leaderboard, waiting for data...",
                                        );
                                        return; // Exit the retry loop on success
                                      } catch (e) {
                                        print(
                                          "❌ Leaderboard connection attempt $attempt failed: $e",
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
                                      Icons.leaderboard,
                                      color: Color(0xFF2E7D32),
                                      size: 28,
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    signalR.isConnecting
                                        ? 'Verbinde...'
                                        : 'Leaderboard anzeigen',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
