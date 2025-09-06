import 'mulligan_hole_score.dart';

class MulliganPlayerScore {
  final int id;
  final String name;
  final double handicap;
  final String gender;
  final int drunkBackClubs;
  final List<MulliganHoleScore> scores;

  MulliganPlayerScore({
    required this.id,
    required this.name,
    required this.handicap,
    required this.gender,
    required this.drunkBackClubs,
    required this.scores,
  });

  factory MulliganPlayerScore.fromJson(Map<String, dynamic> json) {
    return MulliganPlayerScore(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      handicap: (json['handicap'] ?? 0).toDouble(),
      gender: json['gender'] ?? "",
      drunkBackClubs: json['drunkBackClubs'] ?? 0,
      scores:
          (json['scores'] as List<dynamic>?)
              ?.map(
                (e) => MulliganHoleScore.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'handicap': handicap,
      'gender': gender,
      'drunkBackClubs': drunkBackClubs,
      'scores': scores.map((e) => e.toJson()).toList(),
    };
  }
}
