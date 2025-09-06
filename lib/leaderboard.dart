import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mulligan_cup_provider.dart';
import '../models/mle.dart';
import 'services/signalr_service.dart';
import 'scoring.dart';
import 'landingpage.dart';
import 'flight_leaderboard_page.dart';

class LeaderboardPage extends StatefulWidget {
  final String? source; // 'landing' or 'scoring'
  final int? currentHole; // Current hole when coming from scoring page

  const LeaderboardPage({super.key, this.source, this.currentHole});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String selectedFilter = 'toPar'; // Default filter

  // Golf course holes data (same as scoring page)
  final List<Map<String, dynamic>> _holes = [
    {'number': 1, 'length': 535, 'par': 5, 'strokeIndex': 1},
    {'number': 2, 'length': 152, 'par': 3, 'strokeIndex': 9},
    {'number': 3, 'length': 334, 'par': 4, 'strokeIndex': 13},
    {'number': 4, 'length': 331, 'par': 4, 'strokeIndex': 7},
    {'number': 5, 'length': 130, 'par': 3, 'strokeIndex': 15},
    {'number': 6, 'length': 442, 'par': 5, 'strokeIndex': 3},
    {'number': 7, 'length': 104, 'par': 3, 'strokeIndex': 17},
    {'number': 8, 'length': 382, 'par': 4, 'strokeIndex': 5},
    {'number': 9, 'length': 462, 'par': 5, 'strokeIndex': 11},
    {'number': 10, 'length': 462, 'par': 5, 'strokeIndex': 10},
    {'number': 11, 'length': 174, 'par': 3, 'strokeIndex': 12},
    {'number': 12, 'length': 361, 'par': 4, 'strokeIndex': 6},
    {'number': 13, 'length': 469, 'par': 5, 'strokeIndex': 14},
    {'number': 14, 'length': 389, 'par': 4, 'strokeIndex': 2},
    {'number': 15, 'length': 155, 'par': 3, 'strokeIndex': 18},
    {'number': 16, 'length': 335, 'par': 4, 'strokeIndex': 4},
    {'number': 17, 'length': 327, 'par': 4, 'strokeIndex': 16},
    {'number': 18, 'length': 338, 'par': 4, 'strokeIndex': 8},
  ];

  final List<Map<String, String>> filterOptions = [
    {'key': 'toPar', 'label': 'TO PAR'},
    {'key': 'brutto', 'label': 'BRUTTO'},
    {'key': 'netto', 'label': 'NETTO'},
    {'key': 'mulligans', 'label': 'MULLIGAN'},
    {'key': 'lady', 'label': 'LADY'},
  ];

  @override
  Widget build(BuildContext context) {
    final mulliganCupProvider = Provider.of<MulliganCupProvider>(context);
    final leaderboard = mulliganCupProvider.leaderboard;
    final signalR = Provider.of<SignalRService>(context);

    // Get leaderboard entries and sort them
    final entries = _getSortedEntries(leaderboard?.entries ?? []);

    // Debug information
    print('🔍 Leaderboard debug:');
    print('  - Leaderboard is null: ${leaderboard == null}');
    print('  - Total entries: ${leaderboard?.entries.length ?? 0}');
    print('  - Filtered entries (played holes): ${entries.length}');
    print('  - Selected filter: $selectedFilter');
    if (entries.isNotEmpty) {
      print('  - First entry: ${entries.first.name}');
    }

    return Scaffold(
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
          child: signalR.isConnecting
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D32),
                        ),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Verbinde mit Server...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                )
              : signalR.connectionError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Verbindungsfehler',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          signalR.connectionError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          signalR.clearError();
                          try {
                            await signalR.startConnection();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erneuter Verbindungsversuch fehlgeschlagen: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                )
              : leaderboard == null
              ? const Center(
                  child: Text(
                    'No leaderboard data available.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Header section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F2D9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 32,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'LEADERBOARD',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filter buttons
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: filterOptions.map((filter) {
                          final isSelected = selectedFilter == filter['key'];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedFilter = filter['key']!;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2E7D32)
                                        : const Color.fromARGB(
                                            80,
                                            255,
                                            255,
                                            255,
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    filter['label']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Leaderboard entries
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Header row
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  // Empty space for player names (no header)
                                  Expanded(flex: 3, child: Container()),
                                  // Thru header
                                  Expanded(
                                    flex: 1,
                                    child: _buildVerticalHeader('THRU'),
                                  ),
                                  // To Par header
                                  Expanded(
                                    flex: 1,
                                    child: _buildVerticalHeader('TO PAR'),
                                  ),
                                  // Lady header
                                  Expanded(
                                    flex: 1,
                                    child: _buildVerticalHeader('LADY'),
                                  ),
                                  // Mulligans header
                                  Expanded(
                                    flex: 1,
                                    child: _buildVerticalHeader('MULLIGANS'),
                                  ),
                                  // Brutto header
                                  Expanded(
                                    flex: 1,
                                    child: _buildVerticalHeader('BRUTTO'),
                                  ),
                                  // Netto header
                                  Expanded(
                                    flex: 1,
                                    child: _buildVerticalHeader('NETTO'),
                                  ),
                                ],
                              ),
                            ),
                            // Entries list
                            Expanded(
                              child: entries.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.golf_course,
                                            size: 48,
                                            color: Colors.black26,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Keine Spieler mit gespielten Löchern',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Spieler erscheinen erst nach dem ersten Loch',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: entries.length,
                                      itemBuilder: (context, index) {
                                        final entry = entries[index];
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              30,
                                              255,
                                              255,
                                              255,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 0.5,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 2,
                                                spreadRadius: 0,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              // Player name with position
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    // Position number
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: index < 3
                                                            ? _getPositionColor(
                                                                index,
                                                              )
                                                            : Colors
                                                                  .grey
                                                                  .shade200,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color: index < 3
                                                              ? _getPositionColor(
                                                                  index,
                                                                )
                                                              : Colors
                                                                    .grey
                                                                    .shade400,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '${index + 1}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: index < 3
                                                                ? Colors.white
                                                                : Colors
                                                                      .black87,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Player name
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            entry.name
                                                                .split(' ')
                                                                .first,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          if (entry.name
                                                                  .split(' ')
                                                                  .length >
                                                              1)
                                                            Text(
                                                              entry.name
                                                                  .split(' ')
                                                                  .sublist(1)
                                                                  .join(' '),
                                                              style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Thru
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '${entry.thru}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // To Par
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  _formatToPar(
                                                    _calculateToPar(entry),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getToParColor(
                                                      _calculateToPar(entry),
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // Lady count
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '${entry.ladyCount}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: entry.ladyCount > 0
                                                        ? Colors.pink.shade700
                                                        : Colors.black54,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // Mulligans
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '${entry.mulligans}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: entry.mulligans > 0
                                                        ? Colors.orange.shade700
                                                        : Colors.black54,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // Brutto score
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  _getBruttoScore(entry),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getScoreColor(
                                                      entry.brutto,
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // Netto score
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  _getNettoScore(entry),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getScoreColor(
                                                      entry.netto,
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom navigation
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Flight leaderboard button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FlightLeaderboardPage(),
                                ),
                              );
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE1F2D9),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 1,
                                    spreadRadius: 0,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.flight,
                                    size: 24,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Flight',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Score/Home button
                          GestureDetector(
                            onTap: () async {
                              if (widget.source == 'landing') {
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
                                    (route) =>
                                        false, // Remove all previous routes
                                  );
                                }
                              } else {
                                // Go back to scoring page with current hole
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScoreManagementPage(
                                      initialHole: widget.currentHole ?? 0,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE1F2D9),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 1,
                                    spreadRadius: 0,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.source == 'landing'
                                        ? Icons.home
                                        : Icons.score,
                                    size: 24,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.source == 'landing'
                                        ? 'Home'
                                        : 'Score',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Helper methods
  int _calculateToPar(MLE entry) {
    // Calculate total par for holes played
    int totalPar = 0;
    for (int i = 0; i < entry.thru; i++) {
      if (i < _holes.length) {
        totalPar += _holes[i]['par'] as int;
      }
    }

    // To par = strokes - total par
    return entry.strokes - totalPar;
  }

  String _formatToPar(int toPar) {
    if (toPar > 0) {
      return '+$toPar';
    } else if (toPar < 0) {
      return '$toPar';
    } else {
      return 'E';
    }
  }

  Color _getToParColor(int toPar) {
    if (toPar < 0) {
      return Colors.red; // Under par - red (good)
    } else if (toPar > 0) {
      return Colors.black87; // Over par - black
    } else {
      return Colors.green; // Even par - green
    }
  }

  List<MLE> _getSortedEntries(List<MLE> entries) {
    if (entries.isEmpty) return entries;

    // Filter out players who haven't played any holes (thru = 0)
    List<MLE> filteredEntries = entries
        .where((entry) => entry.thru > 0)
        .toList();

    if (filteredEntries.isEmpty) return filteredEntries;

    List<MLE> sortedEntries = List.from(filteredEntries);

    switch (selectedFilter) {
      case 'toPar':
        sortedEntries.sort(
          (a, b) => _calculateToPar(a).compareTo(_calculateToPar(b)),
        );
        break;
      case 'brutto':
        sortedEntries.sort(
          (a, b) => b.brutto.compareTo(a.brutto),
        ); // Descending - highest first
        break;
      case 'netto':
        sortedEntries.sort(
          (a, b) => b.netto.compareTo(a.netto),
        ); // Descending - highest first
        break;
      case 'mulligans':
        sortedEntries.sort(
          (a, b) => b.mulligans.compareTo(a.mulligans),
        ); // Descending
        break;
      case 'lady':
        sortedEntries.sort(
          (a, b) => b.ladyCount.compareTo(a.ladyCount),
        ); // Descending
        break;
    }

    return sortedEntries;
  }

  Widget _buildVerticalHeader(String text) {
    return Center(
      child: RotatedBox(
        quarterTurns: 3, // 90 degrees clockwise
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  String _getBruttoScore(MLE entry) {
    return entry.brutto > 0 ? '+${entry.brutto}' : '${entry.brutto}';
  }

  String _getNettoScore(MLE entry) {
    return entry.netto > 0 ? '+${entry.netto}' : '${entry.netto}';
  }

  Color _getScoreColor(int score) {
    if (score > 0) return Colors.red.shade700;
    if (score < 0) return Colors.green.shade700;
    return Colors.black87;
  }

  Color _getPositionColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber.shade600; // Gold for 1st place
      case 1:
        return Colors.grey.shade500; // Silver for 2nd place
      case 2:
        return Colors.orange.shade700; // Bronze for 3rd place
      default:
        return Colors.grey.shade200;
    }
  }
}
