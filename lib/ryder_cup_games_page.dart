import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mulligan_cup_provider.dart';
import 'services/signalr_service.dart';
import 'landingpage.dart';
import 'scoring.dart';

class RyderCupGamesPage extends StatefulWidget {
  const RyderCupGamesPage({super.key});

  @override
  State<RyderCupGamesPage> createState() => _RyderCupGamesPageState();
}

class _RyderCupGamesPageState extends State<RyderCupGamesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF959F96), Color(0xFFE5E5E5), Color(0xFFE5E5E5)],
            stops: [0.0, 0.7, 1.0],
            radius: 0.8,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Mulligan-Cup 2025',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Flightauswahl',
                  style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32)),
                ),

                const SizedBox(height: 24),

                // Flights Grid
                Consumer<MulliganCupProvider>(
                  builder: (context, mulliganCupProvider, child) {
                    if (mulliganCupProvider.flights.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No flights available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: mulliganCupProvider.flights.map((flight) {
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 64) / 2,
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  // Request flight scores from backend
                                  final signalR = Provider.of<SignalRService>(
                                    context,
                                    listen: false,
                                  );

                                  await signalR.requestFlightScores(flight.id);

                                  // Navigate to scoring page
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ScoreManagementPage(flight: flight),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('❌ Error requesting flight scores: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Fehler beim Laden der Flugdaten: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1F2D9),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Flight ${flight.id}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...flight.players.map(
                                        (playerName) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            playerName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Back to Landing Page Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        // Disconnect from SignalR and return to landing page
                        final signalR = Provider.of<SignalRService>(
                          context,
                          listen: false,
                        );
                        await signalR.stopConnection();

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LandingPage(),
                            ),
                            (route) => false, // Remove all previous routes
                          );
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2E7D32),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 1,
                              spreadRadius: 0,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, size: 24, color: Colors.white),
                            SizedBox(height: 4),
                            Text(
                              'Home',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
