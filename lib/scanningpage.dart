import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:livescoringfrontendv1/scoring.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'models/player.dart';
import 'models/hole.dart';
import '../providers/flight_score_provider.dart';
import 'services/signalr_service.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  String? errorMessage;
  bool isProcessing = false;

  Future<void> handleScan(String rawData) async {
    setState(() {
      isProcessing = true;
      errorMessage = null;
    });

    String testOutput = "";
    const int maxRetries = 3;
    const Duration retryDelay = Duration(milliseconds: 500);

    // Step 1: QR Code parsing and decoding
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(rawData);
    } catch (e) {
      setState(() => errorMessage = 'Ungültiger QR Code: $e');
      controller.start();
      setState(() => isProcessing = false);
      return;
    }

    final String scannedFlightId = decoded['flightId'];
    final String scannedTournamentId = decoded['tournamentId'];
    final String scannedGolfClubId = decoded['golfClubId'];
    final String scannedTeeId = decoded['teeId'];

    String flightBase =
        //'http://192.168.2.172:5001/api/flights?tournamentId=$scannedTournamentId&flightId=$scannedFlightId';
        "https://golf-livescoring-backend-v1.fly.dev/api/flights?tournamentId=$scannedTournamentId&flightId=$scannedFlightId";

    // Step 2: Flight API call with retry mechanism
    http.Response? response;
    try {
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          print("🔄 Flight API attempt $attempt of $maxRetries");
          response = await http.get(
            Uri.parse(flightBase),
            headers: {
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'Expires': '0',
            },
          );
          print("✅ Flight API attempt $attempt succeeded");
          break; // Success, exit retry loop
        } catch (e) {
          print("❌ Flight API attempt $attempt failed: $e");
          if (attempt < maxRetries) {
            print("⏳ Waiting ${retryDelay.inMilliseconds}ms before retry...");
            await Future.delayed(retryDelay);
          } else {
            throw Exception("Flight API failed after $maxRetries attempts: $e");
          }
        }
      }
    } catch (e) {
      setState(() => errorMessage = 'Flight API Fehler: $e');
      controller.start();
      setState(() => isProcessing = false);
      return;
    }

    if (response?.statusCode != 200) {
      setState(
        () => errorMessage =
            'Flight API error: ${response?.statusCode ?? 'Unknown'}',
      );
      controller.start();
      setState(() => isProcessing = false);
      return;
    }

    final List<dynamic> data = jsonDecode(response!.body);
    final decodedResponse = jsonDecode(response.body);

    if (decodedResponse is List && decodedResponse.isNotEmpty) {
      final playersJson = decodedResponse[0]['players'] as List<dynamic>;

      final players = playersJson.map((playerJson) {
        return Player(
          id: playerJson['id'] as String,
          name: playerJson['name'] as String,
        );
      }).toList();

      // Set players into the global provider
      if (context.mounted) {
        final scoreProvider = Provider.of<FlightScoreProvider>(
          context,
          listen: false,
        );
        scoreProvider.setFlightPlayers(players);
      }

      // Step 3: Holes API call with retry mechanism
      http.Response? holesRes;
      try {
        for (int attempt = 1; attempt <= maxRetries; attempt++) {
          try {
            print("🔄 Holes API attempt $attempt of $maxRetries");
            holesRes = await http.get(
              Uri.parse(
                //'http://192.168.2.172:5001/api/holes?golfClubId=$scannedGolfClubId&teeId=$scannedTeeId',
                'https://golf-livescoring-backend-v1.fly.dev/api/holes?golfClubId=$scannedGolfClubId&teeId=$scannedTeeId',
              ),
              headers: {
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                'Pragma': 'no-cache',
                'Expires': '0',
              },
            );
            print("✅ Holes API attempt $attempt succeeded");
            break; // Success, exit retry loop
          } catch (e) {
            print("❌ Holes API attempt $attempt failed: $e");
            if (attempt < maxRetries) {
              print("⏳ Waiting ${retryDelay.inMilliseconds}ms before retry...");
              await Future.delayed(retryDelay);
            } else {
              throw Exception(
                "Holes API failed after $maxRetries attempts: $e",
              );
            }
          }
        }
      } catch (e) {
        setState(() => errorMessage = 'Holes API Fehler: $e');
        controller.start();
        setState(() => isProcessing = false);
        return;
      }

      if (holesRes?.statusCode == 200) {
        testOutput = holesRes!.body;

        final holeList = jsonDecode(holesRes.body) as List;
        final holes = holeList.map((h) => Hole.fromJson(h)).toList();

        Provider.of<FlightScoreProvider>(
          context,
          listen: false,
        ).setHoles(holes);
      }
    }

    final flight = data.firstWhere(
      (f) => f['id'] == scannedFlightId,
      orElse: () => null,
    );

    if (flight != null) {
      // TournamentId match (if flight also contains tournamentId)
      // If not in the API response, skip this check or adapt it

      Provider.of<FlightScoreProvider>(
        context,
        listen: false,
      ).setTournamentId(scannedTournamentId);

      // Step 4: SignalR connection with retry mechanism
      try {
        final signalR = Provider.of<SignalRService>(context, listen: false);
        signalR.setScoreProvider(
          Provider.of<FlightScoreProvider>(context, listen: false),
        );

        for (int attempt = 1; attempt <= maxRetries; attempt++) {
          try {
            print("🔄 SignalR connection attempt $attempt of $maxRetries");
            await signalR.startConnection();
            print("✅ SignalR connection attempt $attempt succeeded");
            break; // Success, exit retry loop
          } catch (e) {
            print("❌ SignalR connection attempt $attempt failed: $e");
            if (attempt < maxRetries) {
              print("⏳ Waiting ${retryDelay.inMilliseconds}ms before retry...");
              await Future.delayed(retryDelay);
            } else {
              throw Exception(
                "SignalR connection failed after $maxRetries attempts: $e",
              );
            }
          }
        }

        // Success: navigate to scoring
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScoreManagementPage()),
        );
        return;
      } catch (e) {
        setState(() => errorMessage = 'SignalR Verbindungsfehler: $e');
        controller.start();
        setState(() => isProcessing = false);
        return;
      }
    } else {
      setState(() => errorMessage = 'Flight konntenicht gefunden werden');
      controller.start();
      setState(() => isProcessing = false);
      return;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scannen')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final code = capture.barcodes.first.rawValue;
                if (code != null && !isProcessing) {
                  controller.stop(); // pause while checking
                  handleScan(code);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: isProcessing
                  ? const CircularProgressIndicator()
                  : errorMessage != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            controller.start(); // resume scanning
                            setState(() {
                              errorMessage = null;
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  : const Text(
                      'Scanne deinen QR Code um zu beginnen',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
