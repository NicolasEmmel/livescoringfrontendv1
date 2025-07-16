import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_score_provider.dart';
import '../models/leaderboard.dart';
import 'scoring.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = Provider.of<FlightScoreProvider>(context).leaderboard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF959F96), Color(0xFFE5E5E5), Color(0xFFE5E5E5)],
            stops: [0.0, 0.7, 1.0],
            radius: 0.8,
          ),
        ),
        child: SafeArea(
          child: leaderboard == null
              ? const Center(child: Text('No leaderboard data available.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: leaderboard.entries.length,
                        itemBuilder: (context, index) {
                          final entry = leaderboard.entries[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.1),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.05),
                                    blurRadius: 0,
                                    spreadRadius: 2,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text('${index + 1}'),
                                  ),
                                  Expanded(flex: 3, child: Text(entry.name)),
                                  Expanded(
                                    flex: 1,
                                    child: Text('${entry.thru}'),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      entry.toPar > 0
                                          ? '+${entry.toPar}'
                                          : '${entry.toPar}',
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text('${entry.brutto}'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.score),
                          label: const Text("Back to Scoring"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ScoreManagementPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
