import 'mulligan_player_score.dart';

class MulliganCupGame {
  final int id;
  final List<MulliganPlayerScore> players;

  MulliganCupGame({required this.id, required this.players});

  factory MulliganCupGame.fromJson(Map<String, dynamic> json) {
    return MulliganCupGame(
      id: json['id'] ?? 0,
      players:
          (json['players'] as List<dynamic>?)
              ?.map(
                (e) => MulliganPlayerScore.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'players': players.map((e) => e.toJson()).toList()};
  }
}
