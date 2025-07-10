import 'package:flutter/material.dart';

class Player {
  final int position;
  final String name;
  final int thru;
  final int toPar;
  final int brutto;

  const Player({
    required this.position,
    required this.name,
    required this.thru,
    required this.toPar,
    required this.brutto,
  });
}

final List<Player> samplePlayers = <Player>[
  Player(position: 1, name: 'Max Mustermann', thru: 18, toPar: -5, brutto: 67),
  Player(position: 2, name: 'Erika Musterfrau', thru: 18, toPar: -3, brutto: 69),
  Player(position: 3, name: 'John Doe', thru: 17, toPar: -2, brutto: 70),
];

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
      ),
      body: ListView.builder(
        itemCount: samplePlayers.length,
        itemBuilder: (context, index) {
          final player = samplePlayers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text(player.position.toString())),
                  Expanded(flex: 3, child: Text(player.name)),
                  Expanded(flex: 1, child: Text(player.thru.toString())),
                  Expanded(
                    flex: 1,
                    child: Text(
                      player.toPar > 0
                          ? '+${player.toPar}'
                          : player.toPar.toString(),
                    ),
                  ),
                  Expanded(flex: 1, child: Text(player.brutto.toString())),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
