import 'package:flutter/foundation.dart';
import '../models/mulligan_cup_flight.dart';
import '../models/mulligan_cup_leaderboard.dart';
import '../models/mulligan_cup_game.dart';

class MulliganCupProvider with ChangeNotifier {
  List<MulliganCupFlight> _flights = [];
  MulliganCupLeaderboard? _leaderboard;
  MulliganCupGame? _currentGame;

  // Score data storage
  Map<String, int> _scores = {};
  Map<String, bool> _ladyCheckboxes = {};
  Map<String, bool> _mulliganCheckboxes = {};
  Map<String, int> _puttsCounters = {};

  List<MulliganCupFlight> get flights => _flights;
  MulliganCupLeaderboard? get leaderboard => _leaderboard;
  MulliganCupGame? get currentGame => _currentGame;

  // Score data getters
  Map<String, int> get scores => _scores;
  Map<String, bool> get ladyCheckboxes => _ladyCheckboxes;
  Map<String, bool> get mulliganCheckboxes => _mulliganCheckboxes;
  Map<String, int> get puttsCounters => _puttsCounters;

  void setFlights(List<MulliganCupFlight> flights) {
    _flights = flights;
    notifyListeners();
  }

  void setLeaderboard(MulliganCupLeaderboard leaderboard) {
    print('📊 Setting leaderboard with ${leaderboard.entries.length} entries');
    _leaderboard = leaderboard;
    notifyListeners();
  }

  void setCurrentGame(MulliganCupGame game) {
    _currentGame = game;
    notifyListeners();
  }

  void clearData() {
    print('🗑️ Clearing all Mulligan Cup data (including leaderboard)');
    _flights = [];
    _leaderboard = null;
    _currentGame = null;
    _scores.clear();
    _ladyCheckboxes.clear();
    _mulliganCheckboxes.clear();
    _puttsCounters.clear();
    notifyListeners();
  }

  // Score data management methods
  void setScore(String playerId, int holeIndex, int score) {
    _scores['${playerId}_$holeIndex'] = score;
    notifyListeners();
  }

  int getScore(String playerId, int holeIndex) {
    return _scores['${playerId}_$holeIndex'] ?? 0;
  }

  void setLadyCheckbox(String playerId, int holeIndex, bool value) {
    _ladyCheckboxes['${playerId}_$holeIndex'] = value;
    notifyListeners();
  }

  bool getLadyCheckbox(String playerId, int holeIndex) {
    return _ladyCheckboxes['${playerId}_$holeIndex'] ?? false;
  }

  void setMulliganCheckbox(String playerId, int holeIndex, bool value) {
    _mulliganCheckboxes['${playerId}_$holeIndex'] = value;
    notifyListeners();
  }

  bool getMulliganCheckbox(String playerId, int holeIndex) {
    return _mulliganCheckboxes['${playerId}_$holeIndex'] ?? false;
  }

  void setPuttsCounter(String playerId, int holeIndex, int value) {
    _puttsCounters['${playerId}_$holeIndex'] = value.clamp(0, 10);
    notifyListeners();
  }

  int getPuttsCounter(String playerId, int holeIndex) {
    return _puttsCounters['${playerId}_$holeIndex'] ?? 0;
  }

  void clearScoreData() {
    _scores.clear();
    _ladyCheckboxes.clear();
    _mulliganCheckboxes.clear();
    _puttsCounters.clear();
    notifyListeners();
  }
}
