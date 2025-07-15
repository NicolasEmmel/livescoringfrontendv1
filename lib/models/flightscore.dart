class FlightScoreData {
  // Map<PlayerId, Map<HoleId, Score>>
  final Map<String, Map<String, int>> _scores = {};

  void updateScore({
    required String playerId,
    required String holeId,
    required int score,
  }) {
    _scores.putIfAbsent(playerId, () => {});
    _scores[playerId]![holeId] = score;
  }

  int? getScore(String playerId, String holeId) {
    return _scores[playerId]?[holeId];
  }

  Map<String, int> getPlayerScores(String playerId) {
    return _scores[playerId] ?? {};
  }

  int getTotalScore(String playerId) {
    final scores = _scores[playerId];
    if (scores == null) return 0;

    return scores.values
        .whereType<int>() // filters out any nulls, just in case
        .fold(0, (sum, score) => sum + score);
  }

  List<String> getPlayedHoles(String playerId) {
    return _scores[playerId]?.keys.toList() ?? [];
  }

  bool hasPlayedHole(String playerId, String holeId) {
    return _scores[playerId]?.containsKey(holeId) ?? false;
  }

  Map<String, Map<String, int>> getAllScores() => _scores;
}
