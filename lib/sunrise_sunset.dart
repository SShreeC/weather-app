import 'package:flutter/material.dart';
import 'dart:math';

class SunriseSunsetWidget extends StatelessWidget {
  final String sunriseTime; // e.g., "6:30 AM"
  final String sunsetTime;  // e.g., "6:00 PM"
  final String currentTime; // e.g., "2:30 PM"

  const SunriseSunsetWidget({
    super.key,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: CustomPaint(
        painter: SunriseSunsetPainter(
          sunriseTime: sunriseTime,
          sunsetTime: sunsetTime,
          currentTime: currentTime,
        ),
        child: const SizedBox(
          height: 200, // Adjust height for the semi-circle
          width: double.infinity,
        ),
      ),
    );
  }
}

class SunriseSunsetPainter extends CustomPainter {
  final String sunriseTime;
  final String sunsetTime;
  final String currentTime;

  SunriseSunsetPainter({
    required this.sunriseTime,
    required this.sunsetTime,
    required this.currentTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.orange
      ..strokeWidth = 4;

    // Draw the semi-circle
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const startAngle = pi; // Semi-circle starts at 180 degrees
    const sweepAngle = pi; // Covers 180 degrees
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Draw the sun's position based on time
    final sunPositionAngle = _calculateSunPositionAngle();
    final sunOffset = Offset(
      center.dx + radius * cos(sunPositionAngle - pi),
      center.dy - radius * sin(sunPositionAngle - pi),
    );

    final sunPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunOffset, 10, sunPaint);

    // Draw sunrise and sunset texts
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: sunriseTime,
      style: const TextStyle(fontSize: 12, color: Colors.black),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, size.height - 20));

    textPainter.text = TextSpan(
      text: sunsetTime,
      style: const TextStyle(fontSize: 12, color: Colors.black),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width, size.height - 20));
  }

  // Calculate sun position angle (0 = sunrise, pi = sunset)
  double _calculateSunPositionAngle() {
    final sunrise = _timeToMinutes(sunriseTime);
    final sunset = _timeToMinutes(sunsetTime);
    final current = _timeToMinutes(currentTime);

    if (current <= sunrise) return pi; // Before sunrise
    if (current >= sunset) return 2 * pi; // After sunset

    final totalMinutes = sunset - sunrise;
    final elapsedMinutes = current - sunrise;

    return pi + (elapsedMinutes / totalMinutes) * pi; // Map to [pi, 2*pi]
  }

  // Helper to convert "6:30 AM" to minutes since midnight
  int _timeToMinutes(String time) {
    final timeParts = time.split(RegExp(r'[:\s]'));
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = timeParts[2].toLowerCase() == 'pm';

    return ((hour % 12) + (isPM ? 12 : 0)) * 60 + minute;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
