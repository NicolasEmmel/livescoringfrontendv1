class Game {
  final int id;
  final String name;
  final List<String> playerNames;
  final int points1;
  final int points2;

  const Game({
    required this.id,
    required this.name,
    required this.playerNames,
    required this.points1,
    required this.points2,
  });

  // Factory constructor to create Game from JSON
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as int,
      name: json['name'] as String,
      playerNames: List<String>.from(json['playerNames'] as List),
      points1: json['points1'] as int,
      points2: json['points2'] as int,
    );
  }

  // Convert Game to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'playerNames': playerNames,
      'points1': points1,
      'points2': points2,
    };
  }

  // Create a copy of Game with updated values
  Game copyWith({
    int? id,
    String? name,
    List<String>? playerNames,
    int? points1,
    int? points2,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      playerNames: playerNames ?? this.playerNames,
      points1: points1 ?? this.points1,
      points2: points2 ?? this.points2,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'Game(id: $id, name: $name, playerNames: $playerNames, points1: $points1, points2: $points2)';
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Game &&
        other.id == id &&
        other.name == name &&
        other.playerNames == playerNames &&
        other.points1 == points1 &&
        other.points2 == points2;
  }

  // Override hashCode
  @override
  int get hashCode {
    return Object.hash(id, name, playerNames, points1, points2);
  }
}
