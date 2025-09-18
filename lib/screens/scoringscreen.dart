import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MatWoodScreen extends StatefulWidget {
  const MatWoodScreen({super.key});
  @override
  State<MatWoodScreen> createState() => _MatWoodScreenState();
}

class _MatWoodScreenState extends State<MatWoodScreen>
    with TickerProviderStateMixin {
  // Greens for chrome
  static const Color g1 = Color(0xFF148D61);
  static const Color g2 = Color(0xFF30B082);
  static const Color g3 = Color(0xFF67C196);
  static const Color g4 = Color(0xFF17875F);

  // Player colors (high contrast on dark field)
  static const Color p1Dot = Color(0xFF5BE7C4); // mint/cyan
  static const Color p2Dot = Color(0xFFFFD166); // amber

  final List<PlayerData> _players = [
    PlayerData(
      id: 'p1',
      name: 'Arya',
      endsPlayed: 6,
      recent: ['3', 'Wood', '1', '2'],
    ),
    PlayerData(
      id: 'p2',
      name: 'Rohit',
      endsPlayed: 5,
      recent: ['2', '2', 'Wood', '4'],
    ),
  ];
  String _selectedPlayerId = 'p1';

  // Persisted shots per player (stored as normalized positions)
  final Map<String, List<Shot>> _shotsByPlayer = {
    'p1': <Shot>[],
    'p2': <Shot>[],
  };

  // Last tap ripple
  Offset? _lastTapLocal;
  late final AnimationController _rippleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _ripple = CurvedAnimation(
    parent: _rippleCtrl,
    curve: Curves.easeOutCubic,
  );

  PlayerData get _selected => _players.firstWhere(
    (p) => p.id == _selectedPlayerId,
    orElse: () => _players.first,
  );

  void _switchPlayer(String id) => setState(() => _selectedPlayerId = id);

  void _recordTap(Offset localPos, Size size) {
    final result = _classifyTap(localPos, size);

    // Save as normalized so it survives size changes/orientation
    final norm = Offset(localPos.dx / size.width, localPos.dy / size.height);
    final shot = Shot(
      playerId: _selectedPlayerId,
      normPos: norm,
      value: result,
    );

    setState(() {
      _lastTapLocal = localPos;
      _rippleCtrl.forward(from: 0);

      _shotsByPlayer[_selectedPlayerId]!.add(shot); // persist dot on canvas

      _selected.recent.insert(0, result);
      if (_selected.recent.length > 10) _selected.recent.removeLast();
    });

    final msg = result == 'Wood'
        ? 'Wood recorded'
        : 'Mat length set to $result';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  // Full-screen thresholds
  String _classifyTap(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final r = math.sqrt(dx * dx + dy * dy);

    final halfMin = math.min(size.width, size.height) / 2;
    final thresholds = [
      0.18 * halfMin,
      0.36 * halfMin,
      0.54 * halfMin,
      0.72 * halfMin,
      0.90 * halfMin,
    ];
    for (int i = 0; i < thresholds.length; i++) {
      if (r <= thresholds[i]) return '$i';
    }
    return 'Wood';
  }

  void _undo() {
    // Undo removes last shot for selected player + recent chip
    final list = _shotsByPlayer[_selectedPlayerId]!;
    if (list.isNotEmpty) {
      setState(() => list.removeLast());
    }
    if (_selected.recent.isNotEmpty) {
      setState(() => _selected.recent.removeAt(0));
    }
  }

  void _saveAndNext() {
    // Keep shots on screen (as requested). You can clear-on-save if you prefer.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved. Points remain visible.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgBottom = isDark ? const Color(0xFF0E1511) : const Color(0xFFE9FFF4);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: bgBottom,
      body: Stack(
        children: [
          // FULL-SCREEN TARGET with persisted dots
          Positioned.fill(
            child: _TapCanvas(
              lastTapLocal: _lastTapLocal,
              ripple: _ripple,
              selectedPlayerId: _selectedPlayerId,
              shotsByPlayer: _shotsByPlayer,
              playerColors: const {'p1': p1Dot, 'p2': p2Dot},
              onTapResolved: _recordTap,
            ),
          ),

          // TOP FLOAT
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GlassPill(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(CupertinoIcons.chevron_back),
                        color: Colors.white,
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PlayerToggle(
                          players: _players,
                          selectedId: _selectedPlayerId,
                          onChanged: _switchPlayer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // tiny legend
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            _LegendDot(color: p1Dot, label: 'Arya'),
                            SizedBox(width: 10),
                            _LegendDot(color: p2Dot, label: 'Rohit'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _GlassPill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.chart_bar_alt_fill,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ends: ${_selected.endsPlayed}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tap rings (0–4) or outside = Wood',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM FLOAT
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GlassPill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: _RecentChips(values: _selected.recent),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _FrostedButton.icon(
                          onPressed: _undo,
                          icon: CupertinoIcons.arrow_uturn_left,
                          label: 'Undo',
                          tint: g3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SolidButton.icon(
                          onPressed: _saveAndNext,
                          icon: CupertinoIcons.check_mark_circled_solid,
                          label: 'Save & Next',
                          color: g2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== DATA MODELS ===================== */

class PlayerData {
  final String id;
  final String name;
  final int endsPlayed;
  final List<String> recent;
  PlayerData({
    required this.id,
    required this.name,
    required this.endsPlayed,
    required this.recent,
  });
}

class Shot {
  final String playerId;
  final Offset normPos; // x in [0..1], y in [0..1]
  final String value; // '0'..'4' or 'Wood'
  const Shot({
    required this.playerId,
    required this.normPos,
    required this.value,
  });
}

/* ===================== UI PARTS ===================== */

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.25),
            Colors.black.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
    );
  }
}

class _PlayerToggle extends StatelessWidget {
  const _PlayerToggle({
    required this.players,
    required this.selectedId,
    required this.onChanged,
  });
  final List<PlayerData> players;
  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
      ),
      child: Row(
        children: players.map((p) {
          final selected = p.id == selectedId;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.20)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onChanged(p.id),
                child: Center(
                  child: Text(
                    p.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecentChips extends StatelessWidget {
  const _RecentChips({required this.values});
  final List<String> values;

  static const Color g2 = _MatWoodScreenState.g2;
  static const Color g3 = _MatWoodScreenState.g3;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values.take(10).map((v) {
          final isWood = v.toLowerCase() == 'wood';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isWood
                    ? [g3.withOpacity(0.15), g2.withOpacity(0.20)]
                    : [g2.withOpacity(0.20), g2.withOpacity(0.32)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: g2.withOpacity(0.45)),
            ),
            child: Text(
              isWood ? 'Wood' : v,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FrostedButton extends StatelessWidget {
  const _FrostedButton.icon({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.tint,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final c = tint ?? Colors.white;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: c.withOpacity(0.25),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _SolidButton extends StatelessWidget {
  const _SolidButton.icon({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shadowColor: color.withOpacity(0.35),
        elevation: 10,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

/* ===================== FULL-SCREEN CANVAS ===================== */

class _TapCanvas extends StatefulWidget {
  const _TapCanvas({
    required this.lastTapLocal,
    required this.ripple,
    required this.selectedPlayerId,
    required this.shotsByPlayer,
    required this.playerColors,
    required this.onTapResolved,
  });

  final Offset? lastTapLocal;
  final Animation<double> ripple;
  final String selectedPlayerId;
  final Map<String, List<Shot>> shotsByPlayer;
  final Map<String, Color> playerColors;
  final void Function(Offset localPos, Size canvasSize) onTapResolved;

  @override
  State<_TapCanvas> createState() => _TapCanvasState();
}

class _TapCanvasState extends State<_TapCanvas> {
  // Fractions scaled to full-screen; outer ring at 0.90 of half-min
  static const List<double> _fractions = [0.18, 0.36, 0.54, 0.72, 0.90];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => widget.onTapResolved(
        d.localPosition,
        context.size ?? const Size(0, 0),
      ),
      child: AnimatedBuilder(
        animation: widget.ripple,
        builder: (_, __) => CustomPaint(
          painter: _FullScreenRingsPainter(
            fractions: _fractions,
            lastTap: widget.lastTapLocal,
            rippleValue: widget.ripple.value,
            selectedPlayerId: widget.selectedPlayerId,
            shotsByPlayer: widget.shotsByPlayer,
            playerColors: widget.playerColors,
          ),
        ),
      ),
    );
  }
}

class _FullScreenRingsPainter extends CustomPainter {
  _FullScreenRingsPainter({
    required this.fractions,
    required this.lastTap,
    required this.rippleValue,
    required this.selectedPlayerId,
    required this.shotsByPlayer,
    required this.playerColors,
  });

  final List<double> fractions;
  final Offset? lastTap;
  final double rippleValue;
  final String selectedPlayerId;
  final Map<String, List<Shot>> shotsByPlayer;
  final Map<String, Color> playerColors;

  static const Color g1 = _MatWoodScreenState.g1;
  static const Color g2 = _MatWoodScreenState.g2;
  static const Color g3 = _MatWoodScreenState.g3;
  static const Color g4 = _MatWoodScreenState.g4;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfMin = math.min(size.width, size.height) / 2;

    // Background gradient + soft vignette
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF113A2B), Color(0xFF0F2E24), Color(0xFF0B231C)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Radial inner glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [g2.withOpacity(0.20), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: halfMin * 0.95));
    canvas.drawCircle(center, halfMin * 0.95, glowPaint);

    // Rings
    final ringColors = [g3, g2, g1, g4, g2];
    for (int i = 0; i < fractions.length; i++) {
      final r = fractions[i] * halfMin;
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.5, size.shortestSide * 0.006)
        ..color = ringColors[i].withOpacity(
          i == fractions.length - 1 ? 0.95 : 0.85,
        );
      canvas.drawCircle(center, r, ring);
    }

    // Labels 0..4 on right
    for (int i = 0; i < fractions.length; i++) {
      final r = fractions[i] * halfMin;
      final pos = center + Offset(r + 10, 0);
      _drawText(
        canvas,
        '$i',
        pos,
        color: Colors.white.withOpacity(0.9),
        fontSize: math.max(14, size.shortestSide * 0.035),
      );
    }

    // Draw persisted shots for both players
    for (final entry in shotsByPlayer.entries) {
      final pid = entry.key;
      final shots = entry.value;
      if (shots.isEmpty) continue;

      final baseColor = playerColors[pid] ?? Colors.white;
      final isSelected = pid == selectedPlayerId;
      final color = isSelected ? baseColor : baseColor.withOpacity(0.55);

      for (final s in shots) {
        final pos = Offset(
          s.normPos.dx * size.width,
          s.normPos.dy * size.height,
        );

        // Dot with outline for visibility
        final dotRadius = math.max(4.0, size.shortestSide * 0.010);
        final stroke = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2.0, size.shortestSide * 0.0035)
          ..color = Colors.black.withOpacity(0.6);
        final fill = Paint()..color = color;

        canvas.drawCircle(pos, dotRadius, stroke);
        canvas.drawCircle(pos, dotRadius - 1.5, fill);

        // Label (0..4 or W)
        final label = s.value.toLowerCase() == 'wood' ? 'W' : s.value;
        _drawLabel(
          canvas,
          label,
          pos + Offset(dotRadius + 4, -dotRadius - 2),
          fg: Colors.white,
          bg: Colors.black.withOpacity(0.35),
          size: math.max(10, size.shortestSide * 0.028),
        );
      }
    }

    // Last tap ripple
    if (lastTap != null) {
      final ripplePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, size.shortestSide * 0.004)
        ..color = g2.withOpacity((1 - rippleValue).clamp(0.0, 1.0));
      final maxRipple = fractions.last * halfMin * 1.05;
      final rippleRadius = 14 + maxRipple * rippleValue;
      canvas.drawCircle(lastTap!, rippleRadius, ripplePaint);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    Color color = Colors.white,
    double fontSize = 16,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx, pos.dy - tp.height / 2));
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset pos, {
    required Color fg,
    required Color bg,
    required double size,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: fg,
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final padding = 4.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        pos.dx - padding,
        pos.dy - padding,
        tp.width + padding * 2,
        tp.height + padding * 2,
      ),
      const Radius.circular(6),
    );
    final paint = Paint()..color = bg;
    canvas.drawRRect(rect, paint);
    tp.paint(canvas, Offset(pos.dx, pos.dy));
  }

  @override
  bool shouldRepaint(covariant _FullScreenRingsPainter old) {
    return old.lastTap != lastTap ||
        old.rippleValue != rippleValue ||
        old.fractions != fractions ||
        old.selectedPlayerId != selectedPlayerId ||
        !mapEquals(old.shotsByPlayer, shotsByPlayer);
  }

  // shallow map compare (positions change -> new instances -> triggers repaint)
  bool mapEquals(Map<String, List<Shot>> a, Map<String, List<Shot>> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      final la = a[k]!;
      final lb = b[k]!;
      if (la.length != lb.length) return false;
      for (int i = 0; i < la.length; i++) {
        if (la[i] != lb[i]) return false;
      }
    }
    return true;
  }
}
