import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../models/shot.dart';
import '../models/end_stats.dart';
import '../utils/constants.dart';
import '../utils/scoring_utils.dart';
import '../widgets/common.dart';
import '../widgets/control_panel.dart';
import '../widgets/end_selector.dart';
import '../widgets/player_toggle.dart';
import '../widgets/scoring_display.dart';
import '../canvas/canvas_area.dart';

class MatDitchScreen extends StatefulWidget {
  const MatDitchScreen({super.key});
  @override
  State<MatDitchScreen> createState() => _MatDitchScreenState();
}

class _MatDitchScreenState extends State<MatDitchScreen>
    with TickerProviderStateMixin {
  // Players (dummy)
  final List<Player> _players = const [
    Player(id: 'p1', name: 'Arya', color: AppColors.p1Dot),
    Player(id: 'p2', name: 'Rohit', color: AppColors.p2Dot),
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
    final value = classifyTap(localPos, size, _outerFraction);
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

    final msg = value == 'Ditch'
        ? 'Ditch recorded'
        : 'Mat length set to $value';
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

  EndStats _computeStatsForEnd(int end) {
    final map = _shots[end] ?? {'p1': [], 'p2': []};
    int wood = 0;
    final ringCounts = List<int>.filled(5, 0);
    final perPlayer = <String, int>{'p1': 0, 'p2': 0};

    for (final entry in map.entries) {
      perPlayer[entry.key] = entry.value.length;
      for (final s in entry.value) {
        if (s.value == 'Ditch') {
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
                    'Tip: Larger outer ring makes "Ditch" area smaller. Keep between 80–95% of half-min.',
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

  /* -------------------- Build -------------------- */

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: _handleKey,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final desktop = constraints.maxWidth >= 900;
          final canvas = CanvasArea(
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

          final controls = ControlPanel(
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
                        // Row 1: Back • PlayerToggle • Settings
                        GlassPill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                CompactIconButton(
                                  onPressed: () => Navigator.maybePop(context),
                                  icon: CupertinoIcons.chevron_back,
                                  tooltip: 'Back',
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                    child: PlayerToggle(
                                      players: _players,
                                      selectedId: _selectedPlayerId,
                                      onChanged: _switchPlayer,
                                      scores: computeScores(_shots, [
                                        'p1',
                                        'p2',
                                      ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                CompactIconButton(
                                  onPressed: () => _openSettingsSheet(context),
                                  icon: CupertinoIcons.slider_horizontal_3,
                                  tooltip: 'Settings',
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Row 2: End selector
                        GlassPill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Center(
                              child: EndSelector(
                                currentEnd: _currentEnd,
                                onPrev: _prevEnd,
                                onNext: _nextEnd,
                              ),
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
                      child: GlassPill(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RecentRow(shots: _playerShots(_selectedPlayerId)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: FrostedButton.icon(
                                      onPressed: _undo,
                                      icon: CupertinoIcons.arrow_uturn_left,
                                      label: 'Undo',
                                      tint: AppColors.g2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SolidButton.icon(
                                      onPressed: _save,
                                      icon: CupertinoIcons
                                          .check_mark_circled_solid,
                                      label: 'Save',
                                      color: AppColors.g2,
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
}
