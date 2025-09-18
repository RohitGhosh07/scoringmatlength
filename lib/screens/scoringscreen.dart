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
  // Vibrant, clean greens
  static const Color g1 = Color(0xFF148D61);
  static const Color g2 = Color(0xFF30B082);
  static const Color g3 = Color(0xFF67C196);
  static const Color g4 = Color(0xFF17875F);

  final List<PlayerData> _players = [
    PlayerData(
      id: 'p1',
      name: 'Arya',
      endsPlayed: 6,
      recent: ['3', 'Wood', '1', '2'],
      color: const Color(0xFF30B082), // Bright green
    ),
    PlayerData(
      id: 'p2',
      name: 'Rohit',
      endsPlayed: 5,
      recent: ['2', '2', 'Wood', '4'],
      color: const Color(0xFF67C196), // Light green
    ),
  ];
  String _selectedPlayerId = 'p1';

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
    setState(() {
      _lastTapLocal = localPos;
      _rippleCtrl.forward(from: 0);
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

  // Full-screen-friendly thresholds (use 90% of half-min as outer ring)
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
    if (_selected.recent.isEmpty) return;
    setState(() => _selected.recent.removeAt(0));
  }

  void _saveAndNext() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved. Proceeding to next…'),
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
    final bgTop = isDark ? const Color(0xFF0A0F0C) : const Color(0xFFF2FFF8);
    final bgBottom = isDark ? const Color(0xFF0E1511) : const Color(0xFFE9FFF4);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: bgBottom,
      body: Stack(
        children: [
          // FULL-SCREEN TARGET
          Positioned.fill(
            child: _TapCanvas(
              lastTapLocal: _lastTapLocal,
              ripple: _ripple,
              onTapResolved: _recordTap,
            ),
          ),

          // TOP FLOAT: Player toggle + mini stats
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(CupertinoIcons.gear_alt),
                        color: Colors.white,
                        tooltip: 'Settings',
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

          // BOTTOM FLOAT: recent chips + actions
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

class Shot {
  final Offset position;
  final String value;
  final DateTime timestamp;

  Shot({
    required this.position,
    required this.value,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class PlayerData {
  final String id;
  final String name;
  final int endsPlayed;
  final List<String> recent;
  final List<Shot> shots;
  final Color color; // Player-specific color

  PlayerData({
    required this.id,
    required this.name,
    required this.endsPlayed,
    required this.recent,
    List<Shot>? shots,
    Color? color,
  }) : shots = shots ?? [],
       color = color ?? const Color(0xFF30B082);
}

/* ---------------- UI PARTS ---------------- */

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

  static const Color g2 = _MatWoodScreenState.g2;
  static const Color g4 = _MatWoodScreenState.g4;

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

/* ---------------- FULL-SCREEN CANVAS ---------------- */

class _TapCanvas extends StatefulWidget {
  const _TapCanvas({
    required this.lastTapLocal,
    required this.ripple,
    required this.onTapResolved,
  });
  final Offset? lastTapLocal;
  final Animation<double> ripple;
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
      onTapDown: (d) {
        widget.onTapResolved(d.localPosition, context.size ?? const Size(0, 0));
      },
      child: AnimatedBuilder(
        animation: widget.ripple,
        builder: (_, __) {
          return CustomPaint(
            painter: _FullScreenRingsPainter(
              fractions: _fractions,
              lastTap: widget.lastTapLocal,
              rippleValue: widget.ripple.value,
            ),
          );
        },
      ),
    );
  }
}

class _FullScreenRingsPainter extends CustomPainter {
  _FullScreenRingsPainter({
    required this.fractions,
    required this.lastTap,
    required this.rippleValue,
  });

  final List<double> fractions;
  final Offset? lastTap;
  final double rippleValue;

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
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF113A2B),
          const Color(0xFF0F2E24),
          const Color(0xFF0B231C),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Radial inner glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [g2.withOpacity(0.20), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: halfMin * 0.95));
    canvas.drawCircle(center, halfMin * 0.95, glowPaint);

    // Rings (thicker, bright, easy to see)
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

    // Labels (big, readable) – placed on the right side
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

    // Tap marker + ripple
    if (lastTap != null) {
      final dotPaint = Paint()..color = g2;
      canvas.drawCircle(
        lastTap!,
        math.max(3, size.shortestSide * 0.008),
        dotPaint,
      );

      final maxRipple = fractions.last * halfMin * 1.05;
      final rippleRadius = 14 + maxRipple * rippleValue;
      final ripplePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, size.shortestSide * 0.004)
        ..color = g2.withOpacity((1 - rippleValue).clamp(0.0, 1.0));
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

  @override
  bool shouldRepaint(covariant _FullScreenRingsPainter old) {
    return old.lastTap != lastTap ||
        old.rippleValue != rippleValue ||
        old.fractions != fractions;
  }
}
