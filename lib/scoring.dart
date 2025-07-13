import 'package:flutter/material.dart';

class ScoreManagementPage extends StatefulWidget {
  const ScoreManagementPage({super.key});

  @override
  State<ScoreManagementPage> createState() => _ScoreManagementPageState();
}

class _ScoreManagementPageState extends State<ScoreManagementPage> {
  final int totalHoles = 18;
  int currentHoleIndex = 0;

  final List<Map<String, dynamic>> players = [
    {'name': 'Max Mustermann', 'score': 4},
    {'name': 'Erika Musterfrau', 'score': 5},
    {'name': 'John Doe', 'score': 4},
    {'name': 'Jane Doe', 'score': 6},
  ];

  final List<Map<String, dynamic>> holes = List.generate(
    18,
    (index) => {
      'hole': index + 1,
      'length': 400 + index * 5,
      'par': (index % 3) + 3,
      'strokeIndex': (index % 18) + 1,
    },
  );

  void updateScore(int playerIndex, int delta) {
    setState(() {
      players[playerIndex]['score'] = (players[playerIndex]['score'] + delta)
          .clamp(1, 12);
    });
  }

  void sendScoresToBackend(int holeIndex) {
    print('Sending scores for hole ${holeIndex + 1}');
    for (var player in players) {
      print('${player['name']} scored ${player['score']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF959F96),
              Color.fromARGB(255, 227, 227, 227),
              Color.fromARGB(255, 234, 234, 234),
            ],
            stops: [0.0, 0.7, 1.0],
            radius: 0.8,
          ),
        ),
        child: PageView.builder(
          itemCount: totalHoles,
          controller: PageController(initialPage: currentHoleIndex),
          onPageChanged: (index) {
            sendScoresToBackend(currentHoleIndex);
            setState(() => currentHoleIndex = index);
          },
          itemBuilder: (context, index) {
            final hole = holes[index];

            return SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight / 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F2D9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 0.5,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Text(
                                'Hole ${hole['hole']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Text('${hole['length']} m'),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Text(
                                'Par ${hole['par']} | SI ${hole['strokeIndex']}',
                              ),
                            ),
                            const Center(
                              child: Icon(Icons.golf_course, size: 64),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Column(
                        children: players.asMap().entries.map((entry) {
                          final i = entry.key;
                          final player = entry.value;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    80,
                                    255,
                                    255,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          player['name'].split(
                                            ' ',
                                          )[0], // First name
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          player['name'].split(
                                            ' ',
                                          )[1], // Last name
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () => updateScore(i, -1),
                                      ),
                                      Text(
                                        '${player['score']}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => updateScore(i, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
