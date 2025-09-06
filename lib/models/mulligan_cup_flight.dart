class MulliganCupFlight {
  final int id;
  final List<String> players;

  MulliganCupFlight({required this.id, required this.players});

  factory MulliganCupFlight.fromJson(Map<String, dynamic> json) {
    return MulliganCupFlight(
      id: json['id'] ?? 0,
      players: List<String>.from(json['players'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'players': players};
  }
}
