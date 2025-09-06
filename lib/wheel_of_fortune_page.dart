import 'package:flutter/material.dart';
import 'dart:math';

class WheelOfFortunePage extends StatefulWidget {
  const WheelOfFortunePage({super.key});

  @override
  State<WheelOfFortunePage> createState() => _WheelOfFortunePageState();
}

class _WheelOfFortunePageState extends State<WheelOfFortunePage>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool _isSpinning = false;
  int _selectedClub = 0;

  // 13 golf clubs (putter exempt from wheel)
  final List<Map<String, dynamic>> _golfClubs = [
    {'name': 'Driver', 'number': '1W', 'color': Colors.red, 'wheelNumber': 1},
    {
      'name': '3 Wood',
      'number': '3W',
      'color': Colors.orange,
      'wheelNumber': 2,
    },
    {'name': '5 Wood', 'number': '5W', 'color': Colors.amber, 'wheelNumber': 3},
    {
      'name': '3 Iron',
      'number': '3I',
      'color': Colors.yellow,
      'wheelNumber': 4,
    },
    {'name': '4 Iron', 'number': '4I', 'color': Colors.lime, 'wheelNumber': 5},
    {'name': '5 Iron', 'number': '5I', 'color': Colors.green, 'wheelNumber': 6},
    {'name': '6 Iron', 'number': '6I', 'color': Colors.teal, 'wheelNumber': 7},
    {'name': '7 Iron', 'number': '7I', 'color': Colors.cyan, 'wheelNumber': 8},
    {'name': '8 Iron', 'number': '8I', 'color': Colors.blue, 'wheelNumber': 9},
    {
      'name': '9 Iron',
      'number': '9I',
      'color': Colors.indigo,
      'wheelNumber': 10,
    },
    {
      'name': 'Pitching Wedge',
      'number': 'PW',
      'color': Colors.purple,
      'wheelNumber': 11,
    },
    {
      'name': 'Sand Wedge',
      'number': 'SW',
      'color': Colors.pink,
      'wheelNumber': 12,
    },
    {
      'name': 'Lob Wedge',
      'number': 'LW',
      'color': Colors.deepPurple,
      'wheelNumber': 13,
    },
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _spinAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _spinController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    // Random number of full rotations plus a random final position
    final random = Random();
    final rotations = 5 + random.nextInt(3); // 5-7 full rotations
    final finalPosition = random.nextDouble(); // Random final position

    _spinController.reset();
    _spinAnimation = Tween<double>(
      begin: 0,
      end: rotations + finalPosition,
    ).animate(CurvedAnimation(parent: _spinController, curve: Curves.easeOut));

    _spinController.forward().then((_) {
      setState(() {
        _isSpinning = false;
        // Calculate which club was selected
        _selectedClub = ((finalPosition * 13) % 13).floor();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Wheel of Fortune',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'Choose Your Club',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Wheel container
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _spinAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinAnimation.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: WheelPainter(_golfClubs),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Selected club display
            if (!_isSpinning && _selectedClub >= 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: _golfClubs[_selectedClub]['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _golfClubs[_selectedClub]['color'],
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Selected Club:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_selectedClub + 1}. ${_golfClubs[_selectedClub]['name']}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _golfClubs[_selectedClub]['color'],
                      ),
                    ),
                    Text(
                      _golfClubs[_selectedClub]['number'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _golfClubs[_selectedClub]['color'],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // Spin button
            GestureDetector(
              onTap: _spinWheel,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSpinning ? Colors.grey : const Color(0xFF4CAF50),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isSpinning ? Colors.grey : const Color(0xFF4CAF50))
                              .withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSpinning ? Icons.hourglass_empty : Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSpinning ? 'Spinning...' : 'SPIN',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Instructions
            Text(
              'Tap the button to spin the wheel and select a club!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> clubs;

  WheelPainter(this.clubs);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / clubs.length;

    // Draw wheel segments
    for (int i = 0; i < clubs.length; i++) {
      final startAngle = i * sweepAngle - pi / 2;

      // Create path for segment
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      );
      path.close();

      // Paint segment
      final paint = Paint()
        ..color = clubs[i]['color'].withOpacity(0.7)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawPath(path, borderPaint);

      // Draw club name
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: (i + 1).toString(), // Use index + 1 for wheel numbers 1-13
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 20, centerPaint);

    // Draw center border
    final centerBorderPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, 20, centerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
