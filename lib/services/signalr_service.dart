import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:livescoringfrontendv1/models/leaderboard.dart';
import 'package:livescoringfrontendv1/models/game.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../providers/flight_score_provider.dart';
import '../providers/game_provider.dart';
import '../providers/mulligan_cup_provider.dart';
import '../models/mulligan_cup_flight.dart';
import '../models/mulligan_cup_leaderboard.dart';
import '../models/mulligan_cup_game.dart';

class SignalRService with ChangeNotifier {
  HubConnection? _hubConnection;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;

  FlightScoreProvider? _scoreProvider;
  GameProvider? _gameProvider;
  MulliganCupProvider? _mulliganCupProvider;

  // Navigation callback for when games are received
  Function(List<Game>)? _navigationCallback;
  // Navigation callback for when Mulligan Cup data is received
  Function(List<MulliganCupFlight>, MulliganCupLeaderboard)?
  _mulliganCupNavigationCallback;

  void setScoreProvider(FlightScoreProvider provider) {
    _scoreProvider = provider;
  }

  void setGameProvider(GameProvider provider) {
    _gameProvider = provider;
  }

  void setMulliganCupProvider(MulliganCupProvider provider) {
    _mulliganCupProvider = provider;
  }

  void setNavigationCallback(Function(List<Game>) callback) {
    _navigationCallback = callback;
  }

  void setMulliganCupNavigationCallback(
    Function(List<MulliganCupFlight>, MulliganCupLeaderboard) callback,
  ) {
    _mulliganCupNavigationCallback = callback;
  }

  List<Game> get ryderCupGames => _gameProvider?.games ?? [];

  // Get current connection state
  String get connectionState {
    if (_hubConnection == null) return 'Not initialized';
    switch (_hubConnection!.state) {
      case HubConnectionState.Disconnected:
        return 'Disconnected';
      case HubConnectionState.Connecting:
        return 'Connecting';
      case HubConnectionState.Connected:
        return 'Connected';
      case HubConnectionState.Reconnecting:
        return 'Reconnecting';
      default:
        return 'Unknown';
    }
  }

  // Get detailed connection info
  Map<String, dynamic> get connectionInfo {
    return {
      'isConnected': _isConnected,
      'isConnecting': _isConnecting,
      'connectionState': connectionState,
      'connectionError': _connectionError,
      'hubConnectionState': _hubConnection?.state.toString(),
      'connectionId': _hubConnection?.connectionId,
      'baseUrl': baseUrl,
    };
  }

  void clearError() {
    _connectionError = null;
    notifyListeners();
  }

  // Check connection health and diagnose issues
  void diagnoseConnection() {
    print("🔍 === CONNECTION DIAGNOSIS ===");
    print("📊 Connection Info: $connectionInfo");

    if (_hubConnection != null) {
      print("🔗 Hub Connection State: ${_hubConnection!.state}");
      print("🆔 Connection ID: ${_hubConnection!.connectionId}");
      print("🌐 Base URL: $baseUrl");
    } else {
      print("❌ No Hub Connection available");
    }

    if (_connectionError != null) {
      print("❌ Last Error: $_connectionError");
    }

    print(
      "📡 Score Provider: ${_scoreProvider != null ? 'Available' : 'Not set'}",
    );
    print(
      "🧭 Navigation Callback: ${_navigationCallback != null ? 'Set' : 'Not set'}",
    );
    print(
      "🎮 Ryder Cup Games: ${_gameProvider?.games.length ?? 0} games loaded",
    );
    print("🔍 === END DIAGNOSIS ===");
  }

  void setConnectingState(bool isConnecting) {
    _isConnecting = isConnecting;
    notifyListeners();
  }

  final String baseUrl = 'https://golf-livescoring-backend-v1.fly.dev/scorehub';
  //'http://192.168.2.172:5001/scorehub';
  //'http://localhost:5001/scorehub';

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;

  Future<void> startConnection() async {
    // Reset error state
    _connectionError = null;
    _isConnecting = true;
    notifyListeners();

    try {
      print("🚀 Starting SignalR connection...");
      print("📍 Base URL: $baseUrl");

      // If there's already a connection, stop it first
      if (_hubConnection != null) {
        print("🔄 Stopping existing connection...");
        await stopConnection();
        // Small delay to ensure connection is fully cleaned up
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Clear existing scores when starting a new connection
      if (_scoreProvider != null) {
        _scoreProvider!.clearAllScores();
      }

      print("🔗 Full connection URL: $baseUrl");

      // Skip connectivity test for live backend
      print("🚀 Proceeding with SignalR connection to live backend...");

      final httpOptions = HttpConnectionOptions(
        transport: HttpTransportType.WebSockets,
      );

      print("🔧 Building HubConnection...");
      _hubConnection = HubConnectionBuilder()
          .withUrl(baseUrl, options: httpOptions)
          .withAutomaticReconnect()
          .build();

      print("🔍 HubConnection built, checking initial state...");
      print("🔍 Initial connection state: ${_hubConnection!.state}");

      print("📡 Setting up message listeners...");

      // Example listener
      _hubConnection!.on("ReceiveScoreUpdate", (List<Object?>? arguments) {
        print("📨 Raw SignalR arguments: $arguments");

        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0];

          if (data is Map<String, dynamic>) {
            try {
              final leaderboard = Leaderboard.fromJson(data);
              print(
                "✅ Received Leaderboard: ${leaderboard.entries.length} entries",
              );

              _scoreProvider?.setLeaderboard(leaderboard);
            } catch (e) {
              print("❌ Failed to parse leaderboard: $e");
            }
          } else {
            print("⚠️ Invalid leaderboard data format: $data");
          }
        }
      });

      // Listener for receiving Ryder Cup games from the backend
      _hubConnection!.on("ReceiveRyderCupScores", (List<Object?>? arguments) {
        print("📨 Received Ryder Cup games: $arguments");

        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0];

          if (data is List) {
            try {
              final List<Game> games = data.map((gameData) {
                if (gameData is Map<String, dynamic>) {
                  return Game.fromJson(gameData);
                } else {
                  throw Exception("Invalid game data format");
                }
              }).toList();

              print("✅ Parsed ${games.length} Ryder Cup games");

              // Store the games in the game provider
              if (_gameProvider != null) {
                _gameProvider!.setGames(games);
              }
              notifyListeners();

              // Navigate to the games page if we have a navigation context
              if (_navigationCallback != null) {
                print(
                  "🧭 Calling navigation callback with ${games.length} games",
                );
                _navigationCallback!(games);
              } else {
                print("⚠️ No navigation callback set");
              }
            } catch (e) {
              print("❌ Failed to parse Ryder Cup games: $e");
            }
          } else {
            print("⚠️ Invalid Ryder Cup games data format: $data");
          }
        }
      });

      // Listener for receiving score updates from the backend
      _hubConnection!.on("ReceiveRyderCupUpdate", (List<Object?>? arguments) {
        print("📨 Received Ryder Cup score update: $arguments");

        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0];

          if (data is List<dynamic>) {
            try {
              // Parse the updated games
              final List<Game> updatedGames = data.map((gameData) {
                if (gameData is Map<String, dynamic>) {
                  return Game.fromJson(gameData);
                } else {
                  throw FormatException('Invalid game data format: $gameData');
                }
              }).toList();

              print("✅ Parsed ${updatedGames.length} updated Ryder Cup games");

              // Update the existing games with new scores
              if (_gameProvider != null) {
                // Update each game individually to preserve existing state
                for (final updatedGame in updatedGames) {
                  final existingGame = _gameProvider!.getGameById(
                    updatedGame.id,
                  );
                  if (existingGame != null) {
                    // Update the existing game with new scores
                    _gameProvider!.updateGameScore(
                      updatedGame.id,
                      updatedGame.points1,
                      updatedGame.points2,
                    );
                    print(
                      "🔄 Updated game ${updatedGame.id}: ${updatedGame.points1}-${updatedGame.points2}",
                    );
                  } else {
                    // If game doesn't exist, add it
                    print(
                      "➕ Adding new game ${updatedGame.id}: ${updatedGame.points1}-${updatedGame.points2}",
                    );
                    _gameProvider!.setGames([
                      ..._gameProvider!.games,
                      updatedGame,
                    ]);
                  }
                }
                print("✅ Updated game provider with score updates");
              }
              notifyListeners();
            } catch (e) {
              print("❌ Failed to parse Ryder Cup score update: $e");
            }
          } else {
            print("⚠️ Invalid Ryder Cup score update data format: $data");
          }
        }
      });

      _hubConnection!.on("TestMessage", (arguments) {
        print("📨 Message received: $arguments");
      });

      // Listener for receiving Mulligan Cup initialization data
      _hubConnection!.on("ReceiveInit", (List<Object?>? arguments) {
        print("📨 Received Mulligan Cup init data: $arguments");

        if (arguments != null && arguments.length >= 2) {
          try {
            // Parse flights (arg1)
            final flightsData = arguments[0];
            List<MulliganCupFlight> flights = [];

            if (flightsData is List) {
              flights = flightsData.map((flightData) {
                if (flightData is Map<String, dynamic>) {
                  return MulliganCupFlight.fromJson(flightData);
                } else {
                  throw Exception("Invalid flight data format");
                }
              }).toList();
            }

            // Parse leaderboard (arg2)
            final leaderboardData = arguments[1];
            MulliganCupLeaderboard? leaderboard;

            if (leaderboardData is Map<String, dynamic>) {
              leaderboard = MulliganCupLeaderboard.fromJson(leaderboardData);
            }

            print("✅ Parsed ${flights.length} Mulligan Cup flights");
            print(
              "✅ Parsed leaderboard with ${leaderboard?.entries.length ?? 0} entries",
            );

            // Store the data in the provider
            if (_mulliganCupProvider != null) {
              _mulliganCupProvider!.setFlights(flights);
              if (leaderboard != null) {
                _mulliganCupProvider!.setLeaderboard(leaderboard);
              }
            }

            // Navigate to the games page if we have a navigation context
            if (_mulliganCupNavigationCallback != null) {
              print(
                "🧭 Calling Mulligan Cup navigation callback with ${flights.length} flights",
              );
              _mulliganCupNavigationCallback!(
                flights,
                leaderboard ?? MulliganCupLeaderboard(entries: []),
              );
            } else {
              print("⚠️ No Mulligan Cup navigation callback set");
            }

            notifyListeners();
          } catch (e) {
            print("❌ Failed to parse Mulligan Cup init data: $e");
          }
        } else {
          print("⚠️ Invalid Mulligan Cup init data format: $arguments");
        }
      });

      // Listener for receiving flight scores from the backend
      _hubConnection!.on("ReceiveFlightScores", (List<Object?>? arguments) {
        print("📨 Received flight scores: $arguments");

        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0];

          if (data is Map<String, dynamic>) {
            try {
              final game = MulliganCupGame.fromJson(data);
              print(
                "✅ Parsed flight scores for game ${game.id} with ${game.players.length} players",
              );

              // Store the game data in the provider
              if (_mulliganCupProvider != null) {
                _mulliganCupProvider!.setCurrentGame(game);
              }

              notifyListeners();
            } catch (e) {
              print("❌ Failed to parse flight scores: $e");
            }
          } else {
            print("⚠️ Invalid flight scores data format: $data");
          }
        } else {
          print("⚠️ Invalid flight scores arguments: $arguments");
        }
      });

      // Listener for receiving updated leaderboard from the backend
      _hubConnection!.on("ReceiveLeaderboard", (List<Object?>? arguments) {
        print("📨 Received updated leaderboard: $arguments");

        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0];

          if (data is Map<String, dynamic>) {
            try {
              final leaderboard = MulliganCupLeaderboard.fromJson(data);
              print(
                "✅ Parsed updated leaderboard with ${leaderboard.entries.length} entries",
              );
              if (leaderboard.entries.isNotEmpty) {
                print("✅ First entry: ${leaderboard.entries.first.name}");
              }

              // Store the updated leaderboard in the provider
              if (_mulliganCupProvider != null) {
                _mulliganCupProvider!.setLeaderboard(leaderboard);
                print("✅ Leaderboard stored in provider");
              } else {
                print(
                  "⚠️ MulliganCupProvider is null, cannot store leaderboard",
                );
              }

              notifyListeners();
            } catch (e) {
              print("❌ Failed to parse updated leaderboard: $e");
            }
          } else {
            print("⚠️ Invalid leaderboard data format: $data");
          }
        } else {
          print("⚠️ Invalid leaderboard arguments: $arguments");
        }
      });

      // Listener for receiving saved scores from the backend
      _hubConnection!.on("ReceiveSavedScores", (List<Object?>? arguments) {
        print("📨 Received saved scores: $arguments");

        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0];

          if (data is Map<String, dynamic>) {
            try {
              // Convert the received data to the expected format
              final Map<String, Map<String, int>> savedScores = {};

              // Parse the received data structure
              data.forEach((playerId, holeScores) {
                if (holeScores is Map<String, dynamic>) {
                  final Map<String, int> playerHoleScores = {};
                  holeScores.forEach((holeId, score) {
                    if (score is int) {
                      playerHoleScores[holeId] = score;
                    }
                  });
                  savedScores[playerId] = playerHoleScores;
                }
              });

              print("✅ Parsed saved scores for ${savedScores.length} players");

              // Update the score provider with the saved scores
              if (_scoreProvider != null) {
                // Clear existing scores before loading new ones
                _scoreProvider!.clearAllScores();

                savedScores.forEach((playerId, holeScores) {
                  holeScores.forEach((holeId, score) {
                    _scoreProvider!.updateScore(
                      playerId: playerId,
                      holeId: holeId,
                      score:
                          score + _scoreProvider!.holes[int.parse(holeId)].par,
                    );
                  });
                });
                print("✅ Updated score provider with saved scores");
              }
            } catch (e) {
              print("❌ Failed to parse saved scores: $e");
            }
          } else {
            print("⚠️ Invalid saved scores data format: $data");
          }
        }
      });

      _hubConnection!.onclose(({error}) {
        print("🔌 Connection closed");
        if (error != null) {
          print("❌ Connection error: $error");
          _connectionError = "Connection closed: ${error.toString()}";
        } else {
          print("ℹ️ Connection closed without error (possibly by backend)");
          _connectionError = "Connection closed by server";
        }
        _isConnected = false;
        notifyListeners();
      });

      _hubConnection!.onreconnecting(({error}) {
        _isConnected = false;
        print("🔄 Reconnecting to SignalR... State: ${_hubConnection!.state}");
        if (error != null) {
          print("❌ Reconnection error: $error");
          _connectionError = "Reconnecting: ${error.toString()}";
        }
        notifyListeners();
      });

      _hubConnection!.onreconnected(({connectionId}) {
        _isConnected = true;
        _connectionError = null;
        print("✅ Reconnected to SignalR. Connection ID: $connectionId");
        notifyListeners();
      });

      print("🚀 Starting connection...");
      print("🔍 Pre-connection state check:");
      print(
        "   - HubConnection: ${_hubConnection != null ? 'Built' : 'Not built'}",
      );
      print("   - Connection state: ${_hubConnection?.state}");
      print("   - Base URL: $baseUrl");

      final connectionFuture = _hubConnection!.start();
      if (connectionFuture != null) {
        print("⏱️ Waiting for connection with 15 second timeout...");
        print("🔍 Connection future type: ${connectionFuture.runtimeType}");

        await connectionFuture.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print("⏰ Connection timeout after 15 seconds");
            print("🔍 Final connection state: ${_hubConnection?.state}");
            throw Exception("Connection timeout after 15 seconds");
          },
        );
      } else {
        print("❌ Connection future is null");
        throw Exception(
          "Failed to start connection - connection future is null",
        );
      }
      print("✅ SignalR connected successfully!");
      print("🔗 Connection state: ${_hubConnection!.state}");
      print("🆔 Connection ID: ${_hubConnection!.connectionId}");
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();
    } catch (e) {
      print("❌ SignalR connection error: $e");
      print("🔍 Error type: ${e.runtimeType}");
      print("🔍 Error details: ${e.toString()}");

      // Check if there's a connection that needs cleanup
      if (_hubConnection != null) {
        print(
          "🔍 Final connection state before cleanup: ${_hubConnection!.state}",
        );
        try {
          await _hubConnection!.stop();
        } catch (stopError) {
          print("⚠️ Error stopping connection during cleanup: $stopError");
        }
      }

      _isConnected = false;
      _isConnecting = false;
      _connectionError = "Connection failed: ${e.toString()}";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> stopConnection() async {
    if (_hubConnection != null) {
      print("🔌 Stopping SignalR connection (state: ${_hubConnection!.state})");
      try {
        if (_hubConnection!.state == HubConnectionState.Connected) {
          await _hubConnection!.stop();
        }
      } catch (e) {
        print("⚠️ Error stopping connection: $e");
      }
      _isConnected = false;
      _isConnecting = false;
      _connectionError = null;
      notifyListeners();
    }
    _hubConnection = null;
  }

  Future<void> sendScoreUpdate(List<Object> args) async {
    const method = 'SendScoreUpdate';

    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      try {
        print('📡 Sending score update...');
        await _hubConnection!.invoke(method, args: args);
        print("📤 Sent message: $method => $args");
        return;
      } catch (e) {
        print('stack: $e');
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> sendMulliganCupGameUpdate(Map<String, dynamic> gameData) async {
    const method = 'SendScoreUpdate';

    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      try {
        print('📡 Sending Mulligan Cup game update...');
        await _hubConnection!.invoke(method, args: [gameData]);
        print("📤 Sent message: $method => $gameData");
        return;
      } catch (e) {
        print('❌ Error sending Mulligan Cup game update: $e');
        rethrow;
      }
    } else {
      throw Exception('SignalR connection not available');
    }
  }

  Future<void> sendGameScoreUpdate(int points1, int points2, int gameId) async {
    const method = 'SendScoreUpdate';

    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      try {
        print(
          '📡 Sending game score update: Team1=$points1, Team2=$points2, GameID=$gameId',
        );
        await _hubConnection!.invoke(method, args: [points1, points2, gameId]);
        print(
          "📤 Sent game score update: $method => [$points1, $points2, $gameId]",
        );

        // Update local game state
        if (_gameProvider != null) {
          _gameProvider!.updateGameScore(gameId, points1, points2);
        }
      } catch (e) {
        print('❌ Error sending game score update: $e');
        rethrow;
      }
    } else {
      throw Exception('SignalR connection not available');
    }
  }

  Future<void> waitForConnectionReady({int retries = 10}) async {
    int attempts = 0;
    while (_hubConnection != null &&
        _hubConnection!.state != HubConnectionState.Connected &&
        attempts < retries) {
      print("⏳ Waiting for SignalR connection...");
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (_hubConnection == null ||
        _hubConnection!.state != HubConnectionState.Connected) {
      throw Exception("SignalR not connected after $retries attempts.");
    }
  }

  Future<void> requestFlightScores(int flightId) async {
    const method = 'ReceiveFlightScores';

    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      try {
        print('📡 Requesting flight scores for flight $flightId...');
        await _hubConnection!.invoke(method, args: [flightId]);
        print("📤 Sent request: $method => [$flightId]");
        return;
      } catch (e) {
        print('❌ Error requesting flight scores: $e');
        rethrow;
      }
    } else {
      throw Exception('SignalR connection not available');
    }
  }

  void registerHandler(String method, void Function(List<Object?>?) callback) {
    _hubConnection?.on(method, callback);
  }

  void unregisterHandler(String method) {
    _hubConnection?.off(method);
  }

  // Test basic connectivity to the backend
  Future<bool> testBackendConnectivity() async {
    try {
      print("🧪 Testing backend connectivity to: $baseUrl");

      // Try to make a simple HTTP request to the base domain to see if the backend is reachable
      final baseDomain = baseUrl.replaceAll('/scorehub', '');
      print("🧪 Testing base domain: $baseDomain");

      final response = await http
          .get(Uri.parse(baseDomain))
          .timeout(const Duration(seconds: 5));

      print("✅ Backend connectivity test successful: ${response.statusCode}");
      // Accept any 2xx or 3xx status code as successful
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      print("❌ Backend connectivity test failed: $e");
      return false;
    }
  }
}
