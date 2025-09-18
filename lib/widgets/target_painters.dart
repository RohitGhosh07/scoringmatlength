import 'dart:math' as math;
import 'package:flutter/material.dart';

class TargetPainter extends CustomPainter {
  final List<Color> ringColors;
  final int? selectedRing;
  final bool isWood;
  final ThemeData theme;

  const TargetPainter({
    required this.ringColors,
    required this.selectedRing,
    required this.isWood,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw rings from largest to smallest
    for (var i = 4; i >= 0; i--) {
      final paint = Paint()
        ..color = ringColors[i].withOpacity(selectedRing == i ? 1.0 : 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius * ((i + 1) / 5), paint);
    }

    // Draw wood area highlight if selected
    if (isWood) {
      final paint = Paint()
        ..color = theme.colorScheme.secondary.withOpacity(0.1)
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant TargetPainter oldDelegate) {
    return oldDelegate.selectedRing != selectedRing ||
        oldDelegate.isWood != isWood;
  }
}

class TapRipplePainter extends CustomPainter {
  final Offset position;
  final double progress;
  final Color color;

  const TapRipplePainter({
    required this.position,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1 - progress) * 0.3)
      ..style = PaintingStyle.fill;

    // Draw tap dot
    canvas.drawCircle(position, 4, Paint()..color = color);

    // Draw expanding ripple
    canvas.drawCircle(position, 24 * progress, paint);
  }

  @override
  bool shouldRepaint(covariant TapRipplePainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
