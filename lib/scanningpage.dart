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

    try {
      final decoded = jsonDecode(rawData);
      final String scannedFlightId = decoded['flightId'];
      final String scannedTournamentId = decoded['tournamentId'];
      final String scannedGolfClubId = decoded['golfClubId'];
      final String scannedTeeId = decoded['teeId'];

      String flightBase =
          'https://golf-livescoring-backend-v1.fly.dev/api/flights?tournamentId=$scannedTournamentId&flightId=$scannedFlightId';
      //"http://192.168.2.172:5001/api/flights?tournamentId=$scannedTournamentId&flightId=$scannedFlightId";

      final response = await http.get(Uri.parse(flightBase));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final decoded = jsonDecode(response.body);

        if (decoded is List && decoded.isNotEmpty) {
          final playersJson = decoded[0]['players'] as List<dynamic>;

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

          final holesRes = await http.get(
            Uri.parse(
              'https://golf-livescoring-backend-v1.fly.dev/api/holes?golfClubId=$scannedGolfClubId&teeId=$scannedTeeId',
            ),
          );
          if (holesRes.statusCode == 200) {
            testOutput = holesRes.body;

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

          final signalR = Provider.of<SignalRService>(context, listen: false);
          signalR.setScoreProvider(
            Provider.of<FlightScoreProvider>(context, listen: false),
          );
          await signalR.startConnection(scannedTournamentId);

          //  Success: navigate to scoring
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScoreManagementPage()),
          );
          return;
        } else {
          setState(() => errorMessage = 'Flight not found.' + response.body);
        }
      } else {
        setState(() => errorMessage = 'API error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    }

    controller.start();
    setState(() => isProcessing = false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
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
                      'Scan a QR code to begin',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
