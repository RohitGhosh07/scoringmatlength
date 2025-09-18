import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MatWoodScreen extends StatefulWidget {
  const MatWoodScreen({super.key});
  @override
  State<MatWoodScreen> createState() => _MatWoodScreenState();
}

class _MatWoodScreenState extends State<MatWoodScreen>
    with TickerProviderStateMixin {
  // Chrome colors
  static const Color g1 = Color(0xFF148D61);
  static const Color g2 = Color(0xFF30B082);
  static const Color g3 = Color(0xFF67C196);
  static const Color g4 = Color(0xFF17875F);

  // Player dot colors
  static const Color p1Dot = Color(0xFF5BE7C4); // Arya
  static const Color p2Dot = Color(0xFFFFD166); // Rohit

  // Players (dummy)
  final List<Player> _players = const [
    Player(id: 'p1', name: 'Arya', color: p1Dot),
    Player(id: 'p2', name: 'Rohit', color: p2Dot),
  ];
  String _selectedPlayerId = 'p1';

  // Ends -> Player -> Shots
  final Map<int, Map<String, List<Shot>>> _shots = {
    1: {'p1': [], 'p2': []},
  };
  int _currentEnd = 1;

  // UI state
  Offset? _lastTapLocal;
  Offset? _hoverLocal; // desktop hover preview
  double _outerFraction = 0.90; // adjustable from settings

  late final AnimationController _rippleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _ripple = CurvedAnimation(
    parent: _rippleCtrl,
    curve: Curves.easeOutCubic,
  );

  Player get _selected => _players.firstWhere((p) => p.id == _selectedPlayerId);

  Map<String, List<Shot>> get _endShots => _shots[_currentEnd]!;
  List<Shot> _playerShots(String pid) => _endShots[pid]!;
  void _ensureEnd(int end) =>
      _shots.putIfAbsent(end, () => {'p1': [], 'p2': []});

  /* -------------------- Actions -------------------- */

  void _switchPlayer(String id) => setState(() => _selectedPlayerId = id);

  void _recordTap(Offset localPos, Size size) {
    final value = _classifyTap(localPos, size, _outerFraction);
    final norm = Offset(localPos.dx / size.width, localPos.dy / size.height);
    final shot = Shot(
      playerId: _selectedPlayerId,
      normPos: norm,
      value: value,
      end: _currentEnd,
    );

    setState(() {
      _lastTapLocal = localPos;
      _rippleCtrl.forward(from: 0);
      _playerShots(_selectedPlayerId).add(shot);
    });

    final msg = value == 'Wood' ? 'Wood recorded' : 'Mat length set to $value';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('End $_currentEnd • ${_selected.name}: $msg'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _undo() {
    final list = _playerShots(_selectedPlayerId);
    if (list.isNotEmpty) {
      setState(() => list.removeLast());
    }
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved current end. Points stay visible.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void _nextEnd() {
    setState(() {
      _currentEnd += 1;
      _ensureEnd(_currentEnd);
    });
  }

  void _prevEnd() {
    if (_currentEnd <= 1) return;
    setState(() => _currentEnd -= 1);
  }

  void _newEnd() {
    setState(() {
      _currentEnd = (_shots.keys.isEmpty
          ? 1
          : (_shots.keys.reduce(math.max) + 1));
      _ensureEnd(_currentEnd);
    });
  }

  void _clearCurrentEnd() {
    setState(() {
      _shots[_currentEnd] = {'p1': [], 'p2': []};
    });
  }

  /* -------------------- Logic -------------------- */

  String _classifyTap(Offset localPos, Size size, double outerFraction) {
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
      outerFraction * halfMin, // adjustable outer ring
    ];
    for (int i = 0; i < thresholds.length; i++) {
      if (r <= thresholds[i]) return '$i';
    }
    return 'Wood';
  }

  /* -------------------- Desktop Shortcuts -------------------- */

  void _handleKey(RawKeyEvent e) {
    if (e is! RawKeyDownEvent) return;
    final key = e.logicalKey.keyLabel.toLowerCase();
    switch (key) {
      case 'a':
        _switchPlayer('p1');
        break;
      case 'r':
        _switchPlayer('p2');
        break;
      case 'n':
        _nextEnd();
        break;
      case 'p':
        _prevEnd();
        break;
      case 'u':
        _undo();
        break;
      case 's':
        _save();
        break;
    }
  }

  /* -------------------- UI -------------------- */

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: _handleKey,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final desktop = constraints.maxWidth >= 900;
          final canvas = _CanvasArea(
            lastTapLocal: _lastTapLocal,
            hoverLocal: _hoverLocal,
            ripple: _ripple,
            currentEnd: _currentEnd,
            shots: _shots,
            players: _players,
            selectedPlayerId: _selectedPlayerId,
            outerFraction: _outerFraction,
            onTapResolved: _recordTap,
            onHover: (p) => setState(() => _hoverLocal = p),
          );

          final controls = _ControlPanel(
            players: _players,
            selectedId: _selectedPlayerId,
            onPlayerChanged: _switchPlayer,
            currentEnd: _currentEnd,
            onPrevEnd: _prevEnd,
            onNextEnd: _nextEnd,
            onNewEnd: _newEnd,
            onClearEnd: _clearCurrentEnd,
            onSave: _save,
            endStats: _computeStatsForEnd(_currentEnd),
            onOpenSettings: () => _openSettingsSheet(context),
          );

          if (desktop) {
            // Desktop / large tablet split layout
            return Scaffold(
              backgroundColor: isDark
                  ? const Color(0xFF0E1511)
                  : const Color(0xFFE9FFF4),
              body: SafeArea(
                child: Row(
                  children: [
                    Expanded(flex: 3, child: canvas),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: math.min(460, constraints.maxWidth * 0.35),
                      child: controls,
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            );
          } else {
            // Mobile stacked with floating pills
            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: isDark
                  ? const Color(0xFF0E1511)
                  : const Color(0xFFE9FFF4),
              body: Stack(
                children: [
                  Positioned.fill(child: canvas),

                  // Top: player + end mini bar
                  SafeArea(
                    minimum: const EdgeInsets.fromLTRB(12, 10, 12, 0),
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
                              Expanded(
                                child: _PlayerToggle(
                                  players: _players,
                                  selectedId: _selectedPlayerId,
                                  onChanged: _switchPlayer,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _openSettingsSheet(context),
                                icon: const Icon(
                                  CupertinoIcons.slider_horizontal_3,
                                ),
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
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _EndChip(
                                  label: 'End',
                                  value: '$_currentEnd',
                                  onPrev: _prevEnd,
                                  onNext: _nextEnd,
                                ),
                                const SizedBox(width: 8),
                                _LegendRow(players: _players),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom: recent + actions
                  SafeArea(
                    minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _GlassPill(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _RecentRow(
                                shots: _playerShots(_selectedPlayerId),
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
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _SolidButton.icon(
                                      onPressed: _save,
                                      icon: CupertinoIcons
                                          .check_mark_circled_solid,
                                      label: 'Save',
                                      color: g2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  /* -------------------- Stats -------------------- */
  EndStats _computeStatsForEnd(int end) {
    final map = _shots[end] ?? {'p1': [], 'p2': []};
    int wood = 0;
    final ringCounts = List<int>.filled(5, 0);
    final perPlayer = <String, int>{'p1': 0, 'p2': 0};

    for (final entry in map.entries) {
      perPlayer[entry.key] = entry.value.length;
      for (final s in entry.value) {
        if (s.value == 'Wood') {
          wood++;
        } else {
          final idx = int.tryParse(s.value) ?? -1;
          if (idx >= 0 && idx < 5) ringCounts[idx]++;
        }
      }
    }
    return EndStats(
      ringCounts: ringCounts,
      wood: wood,
      perPlayerShots: perPlayer,
    );
  }

  /* -------------------- Settings Sheet -------------------- */
  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF111A15),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: StatefulBuilder(
            builder: (context, setS) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Canvas Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Outer ring size',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${(_outerFraction * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Slider(
                    value: _outerFraction,
                    onChanged: (v) =>
                        setS(() => _outerFraction = v.clamp(0.80, 0.95)),
                    min: 0.80,
                    max: 0.95,
                    divisions: 15,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tip: Larger outer ring makes “Wood” area smaller. Keep between 80–95% of half-min.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      },
    ).whenComplete(() => setState(() {}));
  }
}

/* ===================== MODELS ===================== */

class Player {
  final String id;
  final String name;
  final Color color;
  const Player({required this.id, required this.name, required this.color});
}

class Shot {
  final String playerId;
  final Offset normPos; // [0..1] x [0..1]
  final String value; // '0'..'4' or 'Wood'
  final int end;
  const Shot({
    required this.playerId,
    required this.normPos,
    required this.value,
    required this.end,
  });
}

class EndStats {
  final List<int> ringCounts; // index 0..4
  final int wood;
  final Map<String, int> perPlayerShots;
  const EndStats({
    required this.ringCounts,
    required this.wood,
    required this.perPlayerShots,
  });
}

/* ===================== UI PARTS ===================== */

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.players,
    required this.selectedId,
    required this.onPlayerChanged,
    required this.currentEnd,
    required this.onPrevEnd,
    required this.onNextEnd,
    required this.onNewEnd,
    required this.onClearEnd,
    required this.onSave,
    required this.endStats,
    required this.onOpenSettings,
  });

  final List<Player> players;
  final String selectedId;
  final ValueChanged<String> onPlayerChanged;
  final int currentEnd;
  final VoidCallback onPrevEnd;
  final VoidCallback onNextEnd;
  final VoidCallback onNewEnd;
  final VoidCallback onClearEnd;
  final VoidCallback onSave;
  final EndStats endStats;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle('Players'),
              _PlayerToggleDesktop(
                players: players,
                selectedId: selectedId,
                onChanged: onPlayerChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle('End Controls'),
              Row(
                children: [
                  _RoundIconButton(
                    icon: CupertinoIcons.back,
                    onPressed: onPrevEnd,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Text(
                        'End $currentEnd',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RoundIconButton(
                    icon: CupertinoIcons.forward,
                    onPressed: onNextEnd,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onNewEnd,
                      icon: const Icon(CupertinoIcons.add_circled),
                      label: const Text('New End'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onClearEnd,
                      icon: const Icon(CupertinoIcons.delete),
                      label: const Text('Clear End'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(CupertinoIcons.check_mark_circled_solid),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _MatWoodScreenState.g2,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(CupertinoIcons.slider_horizontal_3),
                label: const Text('Canvas Settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle('End Stats'),
              _StatRow(label: 'Ring 0', value: '${endStats.ringCounts[0]}'),
              _StatRow(label: 'Ring 1', value: '${endStats.ringCounts[1]}'),
              _StatRow(label: 'Ring 2', value: '${endStats.ringCounts[2]}'),
              _StatRow(label: 'Ring 3', value: '${endStats.ringCounts[3]}'),
              _StatRow(label: 'Ring 4', value: '${endStats.ringCounts[4]}'),
              const Divider(),
              _StatRow(label: 'Wood', value: '${endStats.wood}'),
              const Divider(),
              _StatRow(
                label: 'Arya shots',
                value: '${endStats.perPlayerShots['p1'] ?? 0}',
              ),
              _StatRow(
                label: 'Rohit shots',
                value: '${endStats.perPlayerShots['p2'] ?? 0}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* Cards & bits */
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121A16)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
  );
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => InkResponse(
    onTap: onPressed,
    radius: 24,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Icon(icon),
    ),
  );
}

/* Player toggles */
class _PlayerToggle extends StatelessWidget {
  const _PlayerToggle({
    required this.players,
    required this.selectedId,
    required this.onChanged,
  });
  final List<Player> players;
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

class _PlayerToggleDesktop extends StatelessWidget {
  const _PlayerToggleDesktop({
    required this.players,
    required this.selectedId,
    required this.onChanged,
  });
  final List<Player> players;
  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: players.map((p) {
        final selected = p.id == selectedId;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: ElevatedButton(
              onPressed: () => onChanged(p.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: selected
                    ? p.color
                    : Colors.white.withOpacity(0.08),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                p.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.players});
  final List<Player> players;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: players
        .map(
          (p) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: p.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  p.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

/* Pills & Buttons */
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

class _EndChip extends StatelessWidget {
  const _EndChip({
    required this.label,
    required this.value,
    required this.onPrev,
    required this.onNext,
  });
  final String label;
  final String value;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        onPressed: onPrev,
        icon: const Icon(CupertinoIcons.chevron_left),
        color: Colors.white,
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        onPressed: onNext,
        icon: const Icon(CupertinoIcons.chevron_right),
        color: Colors.white,
      ),
    ],
  );
}

/* Recent row (mobile) */
class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.shots});
  final List<Shot> shots;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: shots.take(12).map((s) {
          final isWood = s.value == 'Wood';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isWood ? Colors.white : _MatWoodScreenState.g2)
                  .withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Text(
              isWood ? 'W' : s.value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/* ===================== CANVAS ===================== */

class _CanvasArea extends StatefulWidget {
  const _CanvasArea({
    required this.lastTapLocal,
    required this.hoverLocal,
    required this.ripple,
    required this.currentEnd,
    required this.shots,
    required this.players,
    required this.selectedPlayerId,
    required this.outerFraction,
    required this.onTapResolved,
    required this.onHover,
  });

  final Offset? lastTapLocal;
  final Offset? hoverLocal;
  final Animation<double> ripple;
  final int currentEnd;
  final Map<int, Map<String, List<Shot>>> shots;
  final List<Player> players;
  final String selectedPlayerId;
  final double outerFraction;
  final void Function(Offset localPos, Size canvasSize) onTapResolved;
  final ValueChanged<Offset?> onHover;

  @override
  State<_CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<_CanvasArea> {
  ui.Image? _jackImage;

  @override
  void initState() {
    super.initState();
    _loadJackImage();
  }

  Future<void> _loadJackImage() async {
    try {
      final data = await rootBundle.load('assets/images/jack.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      setState(() => _jackImage = frame.image);
    } catch (e) {
      print('Error loading jack image: $e');
    }
  }

  static const List<double> baseFractions = [
    0.18,
    0.36,
    0.54,
    0.72,
  ]; // last is outerFraction

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => widget.onHover(e.localPosition),
      onExit: (_) => widget.onHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => widget.onTapResolved(
          d.localPosition,
          context.size ?? const Size(0, 0),
        ),
        child: AnimatedBuilder(
          animation: widget.ripple,
          builder: (_, __) {
            return CustomPaint(
              painter: _RingsPainter(
                lastTap: widget.lastTapLocal,
                hover: widget.hoverLocal,
                rippleValue: widget.ripple.value,
                currentEnd: widget.currentEnd,
                shots: widget.shots,
                players: widget.players,
                selectedPlayerId: widget.selectedPlayerId,
                outerFraction: widget.outerFraction,
                jackImage: _jackImage,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({
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

  static const Color g1 = _MatWoodScreenState.g1;
  static const Color g2 = _MatWoodScreenState.g2;
  static const Color g3 = _MatWoodScreenState.g3;
  static const Color g4 = _MatWoodScreenState.g4;

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
        colors: [g2.withOpacity(0.20), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: halfMin * 0.95));
    canvas.drawCircle(center, halfMin * 0.95, glowPaint);

    // Draw jack at center
    if (jackImage != null) {
      final jackSize = halfMin * 0.15; // Adjust size as needed
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
        Paint(),
      );
    }

    // Rings
    final rings = [0.18, 0.36, 0.54, 0.72, outerFraction];
    final ringColors = [g3, g2, g1, g4, g2];
    for (int i = 0; i < rings.length; i++) {
      final r = rings[i] * halfMin;
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.5, size.shortestSide * 0.006)
        ..color = ringColors[i].withOpacity(
          i == rings.length - 1 ? 0.95 : 0.85,
        );
      canvas.drawCircle(center, r, ring);
    }

    // // Labels
    // for (int i = 0; i < rings.length; i++) {
    //   final r = rings[i] * halfMin;
    //   final pos = center + Offset(r + 10, 0);
    //   _drawText(
    //     canvas,
    //     '$i',
    //     pos,
    //     color: Colors.white.withOpacity(0.9),
    //     fontSize: math.max(14, size.shortestSide * 0.035),
    //   );
    // }

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
        value == 'Wood' ? 'W' : value,
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
        ..color = g2.withOpacity((1 - rippleValue).clamp(0.0, 1.0));
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

      for (final s in shots) {
        final pos = Offset(
          s.normPos.dx * size.width,
          s.normPos.dy * size.height,
        );
        final dotR = math.max(
          6.5,
          size.shortestSide * 0.030,
        ); // Increased radius
        final stroke = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math
              .max(2.5, size.shortestSide * 0.004) // Slightly thicker stroke
          ..color = Colors.black.withOpacity(0.55 * opacity);
        final fill = Paint()..color = color;

        canvas.drawCircle(pos, dotR, stroke);
        canvas.drawCircle(pos, dotR - 1.6, fill);

        final label = s.value == 'Wood' ? 'W' : s.value;
        _drawLabel(
          canvas,
          label,
          pos + Offset(dotR + 4, -dotR - 2),
          fg: Colors.white.withOpacity(opacity),
          bg: labelBg,
          sizePx: math.max(10, size.shortestSide * 0.028),
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
    return 'Wood';
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

  @override
  bool shouldRepaint(covariant _RingsPainter old) {
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
