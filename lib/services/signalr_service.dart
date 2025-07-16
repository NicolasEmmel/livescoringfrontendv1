import 'dart:convert';

import 'package:livescoringfrontendv1/models/leaderboard.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../providers/flight_score_provider.dart';

class SignalRService {
  late final HubConnection _hubConnection;
  bool _isConnected = false;

  FlightScoreProvider? _scoreProvider;

  void setScoreProvider(FlightScoreProvider provider) {
    _scoreProvider = provider;
  }

  final String baseUrl =
      'https://golf-livescoring-backend-v1.fly.dev/scorehub'; //'http://192.168.2.172:5001/scorehub';

  bool get isConnected => _isConnected;

  Future<void> startConnection(String tournamentId) async {
    final url = '$baseUrl?tournamentId=$tournamentId';

    final httpOptions = HttpConnectionOptions(
      transport: HttpTransportType.WebSockets,
    );

    _hubConnection = HubConnectionBuilder()
        .withUrl(url, options: httpOptions)
        .withAutomaticReconnect()
        .build();

    // Example listener
    _hubConnection.on("ReceiveScoreUpdate", (List<Object?>? arguments) {
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

    _hubConnection.on("TestMessage", (arguments) {
      print("📨 Message received: $arguments");
    });

    _hubConnection.onclose(({error}) {
      print("Connection closed");
      _isConnected = false;
    });

    _hubConnection.onreconnecting(({error}) {
      _isConnected = false;
      print("🔄 Reconnecting to SignalR...");
    });

    _hubConnection.onreconnected(({connectionId}) {
      _isConnected = true;
    });

    try {
      await _hubConnection.start();
      print("✅ SignalR connected.");
      _isConnected = true;
    } catch (e) {
      print("❌ SignalR connection error: $e");
      _isConnected = false;
    }
  }

  Future<void> stopConnection() async {
    if (_hubConnection.state == HubConnectionState.Connected) {
      await _hubConnection.stop();
      print("🔌 SignalR disconnected.");
      _isConnected = false;
    }
  }

  Future<void> sendScoreUpdate(List<Object> args) async {
    const method = 'SendScoreUpdate';

    if (_hubConnection.state == HubConnectionState.Connected) {
      try {
        print('📡 Sending score update...');
        await _hubConnection.invoke(method, args: args);
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
    while (_hubConnection.state != HubConnectionState.Connected &&
        attempts < retries) {
      print("⏳ Waiting for SignalR connection...");
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (_hubConnection.state != HubConnectionState.Connected) {
      throw Exception("SignalR not connected after $retries attempts.");
    }
  }

  void registerHandler(String method, void Function(List<Object?>?) callback) {
    _hubConnection.on(method, callback);
  }

  void unregisterHandler(String method) {
    _hubConnection.off(method);
  }
}
