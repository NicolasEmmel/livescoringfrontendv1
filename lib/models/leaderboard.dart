class Leaderboard {
  final List<LeaderboardEntry> entries;

  Leaderboard({required this.entries});

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    var list = json['entries'] as List<dynamic>;
    List<LeaderboardEntry> parsedEntries = list
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList();

    return Leaderboard(entries: parsedEntries);
  }
}

class LeaderboardEntry {
  final String name;
  final int toPar;
  final int thru;
  final int brutto;
  final int netto;
  final String category;

  LeaderboardEntry({
    required this.name,
    required this.toPar,
    required this.thru,
    required this.brutto,
    required this.netto,
    required this.category,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'],
      toPar: json['toPar'],
      thru: json['thru'],
      brutto: json['brutto'],
      netto: json['netto'],
      category: json['category'],
    );
  }
}
