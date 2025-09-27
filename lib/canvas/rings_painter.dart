import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/shot.dart';
import '../utils/constants.dart';

class RingsPainter extends CustomPainter {
  RingsPainter({
    required this.lastTap,
    required this.hover,
    required this.rippleValue,
    required this.currentEnd,
    required this.shots,
    required this.players,
    required this.selectedPlayerId,
    required this.outerFraction,
    this.jackImage,
  });

  final ui.Image? jackImage;
  final Offset? lastTap;
  final Offset? hover;
  final double rippleValue;
  final int currentEnd;
  final Map<int, Map<String, List<Shot>>> shots;
  final List<Player> players;
  final String selectedPlayerId;
  final double outerFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfMin = math.min(size.width, size.height) / 2;

    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF113A2B), Color(0xFF0F2E24), Color(0xFF0B231C)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Inner glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.secondary.withOpacity(0.20), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: halfMin * 0.95));
    canvas.drawCircle(center, halfMin * 0.95, glowPaint);

    // Rings with lawn-like gradient
    final rings = [0.18, 0.36, 0.54, 0.72, outerFraction];

    // Draw filled circles from outer to inner with gradient
    for (int i = rings.length - 1; i >= 0; i--) {
      final r = rings[i] * halfMin;
      // Calculate darkness factor based on ring index (0 = center/lightest, 4 = outer/darkest)
      final darknessFactor = i / (rings.length - 1);

      final circle = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            HSLColor.fromColor(AppColors.secondary)
                .withLightness(
                  0.6 - (darknessFactor * 0.4),
                ) // Progressively darker
                .toColor(),
            HSLColor.fromColor(AppColors.secondary)
                .withLightness(
                  0.4 - (darknessFactor * 0.3),
                ) // Progressively darker
                .toColor(),
          ],
          stops: const [0.0, 1.0],
          center: Alignment.center,
        ).createShader(Rect.fromCircle(center: center, radius: r));

      canvas.drawCircle(center, r, circle);
    }

    // Draw jack at center first so shots appear on top of it
    if (jackImage != null) {
      final jackSize =
          halfMin * 0.16; // Slightly smaller than the innermost ring
      canvas.drawImageRect(
        jackImage!,
        Rect.fromLTWH(
          0,
          0,
          jackImage!.width.toDouble(),
          jackImage!.height.toDouble(),
        ),
        Rect.fromCenter(
          center: center,
          width: jackSize * 2,
          height: jackSize * 2,
        ),
        Paint()
          ..filterQuality = ui
              .FilterQuality
              .medium // Improve image quality
          ..colorFilter = const ColorFilter.mode(
            Colors.white,
            BlendMode.modulate,
          ),
      );
    }

    // Previous ends (faint)
    for (final entry in shots.entries) {
      final end = entry.key;
      if (end == currentEnd) continue;
      final map = entry.value;
      _drawShots(
        canvas,
        size,
        map,
        players,
        opacity: 0.18,
        labelBg: Colors.black.withOpacity(0.18),
      );
    }

    // Current end (normal)
    _drawShots(
      canvas,
      size,
      shots[currentEnd] ?? {},
      players,
      opacity: 1.0,
      labelBg: Colors.black.withOpacity(0.35),
      selectedPlayerId: selectedPlayerId,
    );

    // Hover preview (desktop)
    if (hover != null) {
      final dotPaint = Paint()..color = Colors.white.withOpacity(0.35);
      canvas.drawCircle(
        hover!,
        math.max(5.0, size.shortestSide * 0.010),
        dotPaint,
      );

      // Live value preview
      final value = _previewClassify(hover!, size, outerFraction);
      _drawLabel(
        canvas,
        value == 'Ditch' ? 'D' : value,
        hover! + const Offset(10, -18),
        fg: Colors.white,
        bg: Colors.black.withOpacity(0.30),
        sizePx: math.max(12, size.shortestSide * 0.030),
      );
    }

    // Last tap ripple
    if (lastTap != null) {
      final ripplePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, size.shortestSide * 0.004)
        ..color = AppColors.secondary.withOpacity(
          (1 - rippleValue).clamp(0.0, 1.0),
        );
      final maxRipple = rings.last * halfMin * 1.05;
      final rippleRadius = 14 + maxRipple * rippleValue;
      canvas.drawCircle(lastTap!, rippleRadius, ripplePaint);
    }
  }

  void _drawShots(
    Canvas canvas,
    Size size,
    Map<String, List<Shot>> map,
    List<Player> players, {
    required double opacity,
    required Color labelBg,
    String? selectedPlayerId,
  }) {
    final colorOf = {for (final p in players) p.id: p.color};
    for (final e in map.entries) {
      final pid = e.key;
      final shots = e.value;
      final base = (colorOf[pid] ?? Colors.white).withOpacity(opacity);
      final selected = selectedPlayerId == null || selectedPlayerId == pid;
      final boost = selected ? 1.0 : 0.65;
      final color = base.withOpacity(base.opacity * boost);

      for (var i = 0; i < shots.length; i++) {
        final s = shots[i];
        final pos = Offset(
          s.normPos.dx * size.width,
          s.normPos.dy * size.height,
        );
        final dotR = math.max(6.5, size.shortestSide * 0.030);
        final stroke = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2.5, size.shortestSide * 0.004)
          ..color = Colors.black.withOpacity(0.55 * opacity);
        final fill = Paint()..color = color;

        canvas.drawCircle(pos, dotR, stroke);
        canvas.drawCircle(pos, dotR - 1.6, fill);

        final label = s.value == 'Ditch' ? 'D' : '${i + 1}';
        _drawLabelInsideCircle(
          canvas,
          label,
          pos,
          dotR,
          sizePx: math.min(math.max(10, size.shortestSide * 0.028), dotR * 0.9),
        );
      }
    }
  }

  String _previewClassify(Offset localPos, Size size, double outerFraction) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = (localPos - center).distance;
    final halfMin = math.min(size.width, size.height) / 2;
    final thresholds = [
      0.18,
      0.36,
      0.54,
      0.72,
      outerFraction,
    ].map((f) => f * halfMin).toList();
    for (int i = 0; i < thresholds.length; i++) {
      if (r <= thresholds[i]) return '$i';
    }
    return 'Ditch';
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset pos, {
    required Color fg,
    required Color bg,
    required double sizePx,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: fg,
          fontSize: sizePx,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pad = 4.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        pos.dx - pad,
        pos.dy - pad,
        tp.width + pad * 2,
        tp.height + pad * 2,
      ),
      const Radius.circular(6),
    );
    final paint = Paint()..color = bg;
    canvas.drawRRect(rect, paint);
    tp.paint(canvas, Offset(pos.dx, pos.dy));
  }

  void _drawLabelInsideCircle(
    Canvas canvas,
    String text,
    Offset center,
    double radius, {
    required double sizePx,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: sizePx,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pos = center - Offset(tp.width / 2, tp.height / 2);
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant RingsPainter old) {
    return lastTap != old.lastTap ||
        hover != old.hover ||
        rippleValue != old.rippleValue ||
        currentEnd != old.currentEnd ||
        selectedPlayerId != old.selectedPlayerId ||
        outerFraction != old.outerFraction ||
        !_mapEquals(shots, old.shots);
  }

  bool _mapEquals(
    Map<int, Map<String, List<Shot>>> a,
    Map<int, Map<String, List<Shot>>> b,
  ) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      final aa = a[k]!;
      final bb = b[k] ?? {};
      if (aa.length != bb.length) return false;
      for (final pk in aa.keys) {
        final la = aa[pk]!;
        final lb = bb[pk] ?? [];
        if (la.length != lb.length) return false;
      }
    }
    return true;
  }
}
