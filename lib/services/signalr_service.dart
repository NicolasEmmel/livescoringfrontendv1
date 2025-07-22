import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:livescoringfrontendv1/models/leaderboard.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../providers/flight_score_provider.dart';

class SignalRService with ChangeNotifier {
  HubConnection? _hubConnection;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;

  FlightScoreProvider? _scoreProvider;

  void setScoreProvider(FlightScoreProvider provider) {
    _scoreProvider = provider;
  }

  void clearError() {
    _connectionError = null;
    notifyListeners();
  }

  final String baseUrl =
      //'http://192.168.2.172:5001/scorehub';
      'https://golf-livescoring-backend-v1.fly.dev/scorehub';

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;

  Future<void> startConnection(String tournamentId, {String? flightId}) async {
    // Reset error state
    _connectionError = null;
    _isConnecting = true;
    notifyListeners();

    try {
      // If there's already a connection, stop it first
      if (_hubConnection != null) {
        await stopConnection();
      }

      // Clear existing scores when starting a new connection
      if (_scoreProvider != null) {
        _scoreProvider!.clearAllScores();
      }

      String url = '$baseUrl?tournamentId=$tournamentId';
      if (flightId != null) {
        url += '&flightId=$flightId';
      }

      final httpOptions = HttpConnectionOptions(
        transport: HttpTransportType.WebSockets,
      );

      _hubConnection = HubConnectionBuilder()
          .withUrl(url, options: httpOptions)
          .withAutomaticReconnect()
          .build();

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

      _hubConnection!.on("TestMessage", (arguments) {
        print("📨 Message received: $arguments");
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
        print("Connection closed");
        _isConnected = false;
        notifyListeners();
      });

      _hubConnection!.onreconnecting(({error}) {
        _isConnected = false;
        print("🔄 Reconnecting to SignalR...");
        notifyListeners();
      });

      _hubConnection!.onreconnected(({connectionId}) {
        _isConnected = true;
        notifyListeners();
      });

      final connectionFuture = _hubConnection!.start();
      if (connectionFuture != null) {
        await connectionFuture.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception("Connection timeout after 10 seconds");
          },
        );
      } else {
        throw Exception("Failed to start connection");
      }
      print("✅ SignalR connected.");
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();
    } catch (e) {
      print("❌ SignalR connection error: $e");
      _isConnected = false;
      _isConnecting = false;
      _connectionError = "Connection failed: ${e.toString()}";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> stopConnection() async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      await _hubConnection!.stop();
      print("🔌 SignalR disconnected.");
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
      } catch (e, stack) {
        print('stack: $e');
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
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

  void registerHandler(String method, void Function(List<Object?>?) callback) {
    _hubConnection?.on(method, callback);
  }

  void unregisterHandler(String method) {
    _hubConnection?.off(method);
  }
}
