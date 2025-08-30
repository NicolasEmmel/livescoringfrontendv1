import 'package:flutter/foundation.dart';
import '../models/game.dart';

class GameProvider with ChangeNotifier {
  List<Game> _games = [];

  List<Game> get games => _games;

  void setGames(List<Game> games) {
    _games = games;
    notifyListeners();
  }

  void updateGameScore(int gameId, int points1, int points2) {
    final gameIndex = _games.indexWhere((game) => game.id == gameId);
    if (gameIndex != -1) {
      _games[gameIndex] = _games[gameIndex].copyWith(
        points1: points1,
        points2: points2,
      );
      notifyListeners();
    }
  }

  Game? getGameById(int gameId) {
    try {
      return _games.firstWhere((game) => game.id == gameId);
    } catch (e) {
      return null;
    }
  }

  void clearGames() {
    _games = [];
    notifyListeners();
  }
}
