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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF959F96),
              Color(0xFFE5E5E5),
              Color(0xFFE5E5E5),
            ],
            stops: [0.0,0.7,1.0],
            radius: 0.8,
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            itemCount: samplePlayers.length,
            itemBuilder: (context, index) {
              final player = samplePlayers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 0,
                        spreadRadius: 2,
                        offset: Offset(0, 4)
                        )
                      ]
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
        ),
        )
    );
  }
}
