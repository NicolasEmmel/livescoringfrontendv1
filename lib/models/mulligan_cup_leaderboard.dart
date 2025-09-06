import 'mle.dart';

class MulliganCupLeaderboard {
  final List<MLE> entries;

  MulliganCupLeaderboard({required this.entries});

  factory MulliganCupLeaderboard.fromJson(Map<String, dynamic> json) {
    return MulliganCupLeaderboard(
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => MLE.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'entries': entries.map((e) => e.toJson()).toList()};
  }
}
