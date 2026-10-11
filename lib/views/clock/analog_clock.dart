import 'dart:math';
import 'package:flutter/material.dart';

class AnalogClock extends StatelessWidget {
  final DateTime dateTime;
  const AnalogClock({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return CustomPaint(
          size: Size(size, size),
          painter: _ChronoMasterClockPainter(dateTime),
        );
      },
    );
  }
}

class _ChronoMasterClockPainter extends CustomPainter {
  final DateTime dateTime;
  _ChronoMasterClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ==========================================
    // 1. DUAL METALLIC BEZEL & 3D RECESSED RIM
    // ==========================================
    // Outer polished steel ring
    final outerBezelPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Colors.white,
          Color(0xFFCDD2DF),
          Colors.white,
          Color(0xFFB8BFCE),
          Colors.white,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius - 2, outerBezelPaint);

    // Deep Inner Dial (Radial Sunburst Texture)
    final dialBgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        colors: const [
          Colors.white,
          Color(0xFFF7F8FC),
          Color(0xFFE6EAF2),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 4, dialBgPaint);

    // Recessed 3D Bezel Drop Shadow
    final innerShadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF1B1424).withValues(alpha: 0.16),
        ],
        stops: const [0.82, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 4));
    canvas.drawCircle(center, radius - 4, innerShadowPaint);

    // Internal Concentric Precision Rings
    final innerOrbitPaint = Paint()
      ..color = const Color(0xFFB0B7C6).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.64, innerOrbitPaint);
    canvas.drawCircle(center, radius * 0.32, innerOrbitPaint);

    // ==========================================
    // 2. ROMAN / CARDINAL NUMERALS & PRECISION TICKS
    // ==========================================
    _drawNumerals(canvas, center, radius);

    // Minute Ticks and Micro Dots
    final majorTickPaint = Paint()
      ..color = const Color(0xFF22162B)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final goldDotPaint = Paint()
      ..color = const Color(0xFFE5A826)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 60; i++) {
      if (i % 15 == 0) continue; // 12, 3, 6, 9 বাদ দেওয়া হয়েছে টেক্সটের জন্য
      final angle = i * 6 * pi / 180;
      final isHour = (i % 5 == 0);

      if (isHour) {
        final p1 = Offset(
          center.dx + (radius - 12) * cos(angle),
          center.dy + (radius - 12) * sin(angle),
        );
        final p2 = Offset(
          center.dx + (radius - 23) * cos(angle),
          center.dy + (radius - 23) * sin(angle),
        );
        canvas.drawLine(p1, p2, majorTickPaint);

        // সোনালী সূক্ষ্ম ইনডিকেটর ডট
        final dotPos = Offset(
          center.dx + (radius - 28) * cos(angle),
          center.dy + (radius - 28) * sin(angle),
        );
        canvas.drawCircle(dotPos, 1.6, goldDotPaint);
      } else {
        final p1 = Offset(
          center.dx + (radius - 14) * cos(angle),
          center.dy + (radius - 14) * sin(angle),
        );
        final p2 = Offset(
          center.dx + (radius - 19) * cos(angle),
          center.dy + (radius - 19) * sin(angle),
        );
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = const Color(0xFF9EA6B8).withValues(alpha: 0.6)
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // ==========================================
    // 3. CONTINUOUS SMOOTH HAND MOVEMENT ANGLES
    // ==========================================
    final secFraction = dateTime.millisecond / 1000.0;
    final sec = dateTime.second + secFraction;
    final min = dateTime.minute + (sec / 60.0);
    final hour = (dateTime.hour % 12) + (min / 60.0);

    final hourAngle = hour * 30 * pi / 180 - pi / 2;
    final minAngle = min * 6 * pi / 180 - pi / 2;
    final secAngle = sec * 6 * pi / 180 - pi / 2;

    void drawSoftShadow(Offset p1, Offset p2, double width) {
      final shadowPaint = Paint()
        ..color = const Color(0xFF160F1E).withValues(alpha: 0.24)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
      canvas.drawLine(p1 + const Offset(4, 5), p2 + const Offset(4, 5), shadowPaint);
    }

    // ==========================================
    // 4. HOUR HAND (Sculpted Obsidian / Sword Style)
    // ==========================================
    final hourLength = radius * 0.46;
    final hourP1 = center - Offset(12 * cos(hourAngle), 12 * sin(hourAngle));
    final hourP2 = Offset(center.dx + hourLength * cos(hourAngle), center.dy + hourLength * sin(hourAngle));

    drawSoftShadow(hourP1, hourP2, 7.0);

    // Hand body
    canvas.drawLine(
      hourP1,
      hourP2,
      Paint()
        ..color = const Color(0xFF1E1528)
        ..strokeWidth = 6.2
        ..strokeCap = StrokeCap.round,
    );
    // Center spine highlight
    canvas.drawLine(
      center + Offset(5 * cos(hourAngle), 5 * sin(hourAngle)),
      Offset(center.dx + (hourLength - 8) * cos(hourAngle), center.dy + (hourLength - 8) * sin(hourAngle)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    // ==========================================
    // 5. MINUTE HAND (Radiant Metallic Gold Sword)
    // ==========================================
    final minLength = radius * 0.69;
    final minP1 = center - Offset(14 * cos(minAngle), 14 * sin(minAngle));
    final minP2 = Offset(center.dx + minLength * cos(minAngle), center.dy + minLength * sin(minAngle));

    drawSoftShadow(minP1, minP2, 5.0);

    final minPaint = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0xFFFFDF7D),
          Color(0xFFE59C0B),
          Color(0xFFFFC033),
        ],
      ).createShader(Rect.fromPoints(minP1, minP2))
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(minP1, minP2, minPaint);

    // ==========================================
    // 6. SECOND HAND (Racing Red Needle + Diamond Tail)
    // ==========================================
    final secLength = radius * 0.80;
    final secTail = 24.0;
    final secP1 = center - Offset(secTail * cos(secAngle), secTail * sin(secAngle));
    final secP2 = Offset(center.dx + secLength * cos(secAngle), center.dy + secLength * sin(secAngle));

    drawSoftShadow(secP1, secP2, 2.5);

    // Red needle
    canvas.drawLine(
      secP1,
      secP2,
      Paint()
        ..color = const Color(0xFFFF3333)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // Counterbalance skeleton diamond/ring
    final tailCircleCenter = center - Offset((secTail - 7) * cos(secAngle), (secTail - 7) * sin(secAngle));
    canvas.drawCircle(
      tailCircleCenter,
      4.2,
      Paint()
        ..color = const Color(0xFFFF3333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // ==========================================
    // 7. CENTER LUXURY JEWELED CAP
    // ==========================================
    canvas.drawCircle(center, 9.0, Paint()..color = const Color(0xFF1E1528));
    canvas.drawCircle(center, 6.0, Paint()..color = const Color(0xFFFFDF7D));
    canvas.drawCircle(center, 3.2, Paint()..color = const Color(0xFFFF3333));
    canvas.drawCircle(center, 1.2, Paint()..color = Colors.white);

    // ==========================================
    // 8. CURVED SAPPHIRE CRYSTAL LENS GLARE
    // ==========================================
    _drawSapphireGlare(canvas, center, radius - 4);
  }

  void _drawNumerals(Canvas canvas, Offset center, double radius) {
    const numerals = {"12": -pi / 2, "3": 0.0, "6": pi / 2, "9": pi};

    numerals.forEach((text, angle) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Color(0xFF22162B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final distance = radius - 21;
      final textCenter = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );

      textPainter.paint(
        canvas,
        Offset(
          textCenter.dx - textPainter.width / 2,
          textCenter.dy - textPainter.height / 2,
        ),
      );
    });
  }

  void _drawSapphireGlare(Canvas canvas, Offset center, double radius) {
    final glarePath = Path();
    glarePath.addArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.95,
      pi * 0.75,
    );
    glarePath.quadraticBezierTo(
      center.dx,
      center.dy - (radius * 0.2),
      center.dx - radius * cos(pi * 0.25),
      center.dy - radius * sin(pi * 0.25),
    );
    glarePath.close();

    final glarePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(glarePath, glarePaint);
  }

  @override
  bool shouldRepaint(covariant _ChronoMasterClockPainter oldDelegate) => true;
}
