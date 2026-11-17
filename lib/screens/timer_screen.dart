import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  static const int totalSeconds = 120;
  int remainingSeconds = totalSeconds;
  Timer? timer;
  bool isRunning = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: totalSeconds),
    );
  }

  void startTimer() {
    if (isRunning) return;
    setState(() => isRunning = true);

    // Sync animation with remaining time
    final double startValue =
        1 - (remainingSeconds / totalSeconds.toDouble());
    _controller.value = startValue;
    _controller.forward();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          t.cancel();
          isRunning = false;
          _controller.stop();
        }
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    _controller.stop();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();
    _controller.reset();
    setState(() {
      remainingSeconds = totalSeconds;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int minutes = remainingSeconds ~/ 60;
    final int seconds = remainingSeconds % 60;

    return Scaffold(
      backgroundColor: const Color(0xFFE8ECF0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: OvalTeethPainter(progress: _controller.value),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 32, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset
                  GestureDetector(
                    onTap: resetTimer,
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 36,
                      color: Color(0xFF4A90D9),
                    ),
                  ),

                  // Timer circle
                  GestureDetector(
                    onTap: startTimer,
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CustomPaint(
                        painter: _TimerRingPainter(progress: _controller.value),
                        child: Center(
                          child: Text(
                            "$minutes:${seconds.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A90D9),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Stop
                  GestureDetector(
                    onTap: stopTimer,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90D9).withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stop_rounded,
                        size: 28,
                        color: Color(0xFF4A90D9),
                      ),
                    ),
                  ),

                  // +Time
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        remainingSeconds += 30;
                      });
                    },
                    child: const Text(
                      "+Time",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A90D9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OvalTeethPainter
// Smooth animation: teeth fade from yellow → white progressively based on progress
// ─────────────────────────────────────────────────────────────────────────────
class OvalTeethPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  OvalTeethPainter({required this.progress});

  static const int totalTeeth = 32;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double rx = size.width * 0.42;
    final double ry = size.height * 0.48;

    final List<_ToothPos> positions = [];

    // Upper arch
    for (int i = 0; i < 16; i++) {
      final double angleDeg = 200 + i * (140 / 15);
      final double a = angleDeg * pi / 180;
      positions.add(_ToothPos(
        x: cx + rx * cos(a),
        y: cy - ry * sin(a),
        nx: cos(a),
        ny: -sin(a),
      ));
    }

    // Lower arch
    for (int i = 0; i < 16; i++) {
      final double angleDeg = 160 - i * (140 / 15);
      final double a = angleDeg * pi / 180;
      positions.add(_ToothPos(
        x: cx + rx * cos(a),
        y: cy - ry * sin(a),
        nx: cos(a),
        ny: -sin(a),
      ));
    }

    for (int i = 0; i < totalTeeth; i++) {
      final double t = (progress * totalTeeth) - i;
      final double local = t.clamp(0.0, 1.0);

      // Smooth color transition
      final Color color = Color.lerp(
        const Color(0xFFFFF176), // yellow
        Colors.white,            // brushed
        local,
      )!;

      _drawTooth(canvas, positions[i], color);
    }
  }

  void _drawTooth(Canvas canvas, _ToothPos p, Color fillColor) {
    const double w = 22;
    const double h = 26;

    canvas.save();
    canvas.translate(p.x, p.y);
    final double angle = atan2(p.ny, p.nx);
    canvas.rotate(angle - pi / 2);

    final path = Path()
      ..moveTo(-w * 0.5, h * 0.45)
      ..quadraticBezierTo(-w, h * 0.2, -w * 0.8, -h * 0.45)
      ..quadraticBezierTo(0, -h * 0.6, w * 0.8, -h * 0.45)
      ..quadraticBezierTo(w, h * 0.2, w * 0.5, h * 0.45)
      ..quadraticBezierTo(0, h * 0.55, -w * 0.5, h * 0.45)
      ..close();

    canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF222222)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OvalTeethPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ToothPos {
  final double x, y, nx, ny;
  _ToothPos({required this.x, required this.y, required this.nx, required this.ny});
}

// ─────────────────────────────────────────────────────────────────────────────
// Timer ring painter
// ─────────────────────────────────────────────────────────────────────────────
class _TimerRingPainter extends CustomPainter {
  final double progress;
  _TimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 5;

    canvas.drawCircle(center, radius,
        Paint()..color = const Color(0xFF4A90D9)..style = PaintingStyle.fill);

    canvas.drawCircle(center, radius - 10,
        Paint()..color = const Color(0xFFDDE8F5)..style = PaintingStyle.fill);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 5),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = const Color(0xFF2171C7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}