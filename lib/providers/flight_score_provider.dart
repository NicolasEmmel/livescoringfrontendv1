// lib/providers/flight_score_provider.dart
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/hole.dart';
import 'dart:collection';

class FlightScoreProvider with ChangeNotifier {
  final Map<String, Map<String, int>> _scores = {};
  List<Player> _players = [];
  List<Hole> _holes = [];

  void setFlightPlayers(List<Player> players) {
    _players = players;
    notifyListeners();
  }

  void setHoles(List<Hole> holes) {
    _holes = holes;
    notifyListeners();
  }

  List<Player> get players => _players;
  List<Hole> get holes => _holes;

  void updateScore({
    required String playerId,
    required String holeId,
    required int score,
  }) {
    _scores.putIfAbsent(playerId, () => {});
    _scores[playerId]![holeId] = score;
    notifyListeners();
  }

  int? getScore(String playerId, String holeId) {
    return _scores[playerId]?[holeId];
  }

  int getTotalScore(String playerId) {
    final scores = _scores[playerId];
    if (scores == null) return 0;
    return scores.values.fold(0, (sum, score) => sum + score);
  }

  List<String> getPlayedHoles(String playerId) {
    return _scores[playerId]?.keys.toList() ?? [];
  }

  bool hasPlayedHole(String playerId, String holeId) {
    return _scores[playerId]?.containsKey(holeId) ?? false;
  }

  Map<String, Map<String, int>> getAllScores() => _scores;
}
