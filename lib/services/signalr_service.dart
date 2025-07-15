import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  late final HubConnection _hubConnection;
  bool _isConnected = false;

  final String baseUrl;
  final String playerId;

  SignalRService({required this.baseUrl, required this.playerId});

  bool get isConnected => _isConnected;

  Future<void> startConnection() async {
    final url = '$baseUrl?playerId=$playerId';

    final httpOptions = HttpConnectionOptions(
      transport: HttpTransportType.WebSockets,
    );

    _hubConnection = HubConnectionBuilder()
        .withUrl(url, options: httpOptions)
        .withAutomaticReconnect()
        .build();

    _hubConnection.onclose(({error}) {
      print("Connection closed");
      _isConnected = false;
    });

    _hubConnection.onreconnecting(({error}) {
      print("🔄 Reconnecting to SignalR...");
    });

    _hubConnection.onreconnected(({connectionId}) {
      _isConnected = true;
    });

    // Example listener
    _hubConnection.on("ReceiveMessage", (arguments) {
      final from = arguments?[0];
      final msg = arguments?[1];
      print("📨 Message from $from: $msg");
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

  Future<void> sendMessage(String method, List<Object> args) async {
    if (_hubConnection.state == HubConnectionState.Connected) {
      try {
        await _hubConnection.invoke(method, args: args);
        print("📤 Sent message: $method => $args");
      } catch (e) {
        print("❌ Failed to send message: $e");
      }
    } else {
      print("⚠️ Can't send message. Not connected.");
    }
  }

  void registerHandler(String method, void Function(List<Object?>?) callback) {
    _hubConnection.on(method, callback);
  }

  void unregisterHandler(String method) {
    _hubConnection.off(method);
  }
}
