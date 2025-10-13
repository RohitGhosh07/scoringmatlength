import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Models
import '../models/player.dart';
import '../models/shot.dart';
import '../models/end_stats.dart';
import '../utils/url_utils.dart';

// Widgets
// Canvas
import '../canvas/canvas_area.dart';

// Widgets
import '../widgets/common.dart';
import '../widgets/control_panel.dart';
import '../widgets/end_selector.dart';
import '../widgets/player_toggle.dart';
import '../widgets/scoring_display.dart';

// Utils
import '../utils/scoring_utils.dart';

class ScoringScreen extends StatefulWidget {
  final Player player1;
  final Player player2;
  final int currentEnd;
  final int totalEnds;
  final int player1TotalScore;
  final int player2TotalScore;
  final Map<String, int> endScore;
  final Map<int, Map<String, List<Shot>>>? initialShots;

  const ScoringScreen({
    super.key,
    required this.player1,
    required this.player2,
    required this.currentEnd,
    required this.totalEnds,
    required this.player1TotalScore,
    required this.player2TotalScore,
    required this.endScore,
    this.initialShots,
  });

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen>
    with TickerProviderStateMixin {
  // Chrome colors
  static const Color g2 = Color(0xFF30B082);

  late List<Player> _players;
  late String _selectedPlayerId;

  // Ends -> Player -> Shots
  final Map<int, Map<String, List<Shot>>> _shots = {};
  late int _currentEnd;

  @override
  void initState() {
    super.initState();
    _players = [widget.player1, widget.player2];
    _selectedPlayerId = widget.player1.id;
    _currentEnd = widget.currentEnd;

    // Initialize shots map for current end
    _ensureEnd(_currentEnd);

    // Initialize with shots from URL if provided
    if (widget.initialShots != null) {
      debugPrint('Initial shots found: ${widget.initialShots}');
      widget.initialShots!.forEach((end, playerShots) {
        _shots[end] = Map<String, List<Shot>>.from(playerShots);
      });
    }

    // Debug print current shots
    debugPrint('Current shots state: $_shots');
  }

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

  List<Shot> _playerShots(String pid) {
    // Make sure we have a map for the current end
    _shots[_currentEnd] ??= {};
    // Make sure we have a list for this player
    _shots[_currentEnd]![pid] ??= [];
    return _shots[_currentEnd]![pid]!;
  }

  bool _canAddShot(String playerId) {
    // Maximum 4 shots per player per end
    return _playerShots(playerId).length < 4;
  }

  void _ensureEnd(int end) {
    _shots.putIfAbsent(end, () => {'p1': [], 'p2': []});
  }

  /* -------------------- Actions -------------------- */

  void _switchPlayer(String id) => setState(() => _selectedPlayerId = id);

  void _syncUrlWithShots() {
    if (!mounted) return;

    final router = GoRouter.of(context);
    final currentUri = router.routeInformationProvider.value.uri;

    // Get current query parameters
    final params = Map<String, String>.from(currentUri.queryParameters);

    // Update shot parameters
    final p1Shots = _shots[_currentEnd]?['p1'] ?? [];
    final p2Shots = _shots[_currentEnd]?['p2'] ?? [];

    if (p1Shots.isNotEmpty) {
      params['p1_shots'] = UrlUtils.shotsToUrlParam(p1Shots);
    } else {
      params.remove('p1_shots');
    }

    if (p2Shots.isNotEmpty) {
      params['p2_shots'] = UrlUtils.shotsToUrlParam(p2Shots);
    } else {
      params.remove('p2_shots');
    }

    // Build new URI
    final newUri = currentUri.replace(queryParameters: params);
    router.go(newUri.toString());
  }

  Future<void> _recordShot(Shot shot) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://golf.forcempower.com/WBIC2025/update_end_wise_mat_length.php',
      ),
    );

    final shotData = {
      'msg': 'mat-legth-data',
      'data': [
        {
          'match_id': '313', // Static for now
          'game_id': 'game1', // Static for now
          'team': '12', // Static for now
          'player': '2', // Static for now
          'ends': shot.end.toString(),
          'shots': (_playerShots(shot.playerId).length).toString(),
          'coordinate_1': shot.normPos.dx.toString(),
          'coordinate_2': shot.normPos.dy.toString(),
        },
      ],
    };

    request.fields['mat_length_data'] = jsonEncode(shotData);

    // Debug: Print detailed request information
    debugPrint('\n🎯 Shot Recording Details 🎯');
    debugPrint('──────────────────────────────');
    debugPrint('URL: ${request.url}');
    debugPrint('Method: ${request.method}');
    debugPrint('\nShot Details:');
    debugPrint('• Player ID: ${shot.playerId}');
    debugPrint('• End Number: ${shot.end}');
    debugPrint('• Shot Number: ${_playerShots(shot.playerId).length}');
    debugPrint(
      '• Position: (${shot.normPos.dx.toStringAsFixed(3)}, ${shot.normPos.dy.toStringAsFixed(3)})',
    );
    debugPrint('• Shot Value: ${shot.value}');
    debugPrint('\nRequest Payload:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(shotData));
    debugPrint('──────────────────────────────');

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('\n📡 API Response:');
      debugPrint('──────────────────────────────');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('\nResponse Body:');
      try {
        // Try to format JSON response if valid
        final jsonResponse = jsonDecode(responseBody);
        debugPrint(const JsonEncoder.withIndent('  ').convert(jsonResponse));
      } catch (e) {
        // If not JSON, print raw response
        debugPrint(responseBody);
      }
      debugPrint('──────────────────────────────');

      if (response.statusCode == 200) {
        debugPrint('✅ Shot recorded successfully');
      } else {
        debugPrint('❌ Failed to record shot');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Reason: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('❌ Error recording shot: $e');
    }
  }

  void _recordTap(Offset localPos, Size size) {
    if (!_canAddShot(_selectedPlayerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selected.name} has already taken 4 shots this end'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }

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

      // Record shot to the server
      _recordShot(shot);

      // Initialize opponent's shots list if empty
      final opponentId = _selectedPlayerId == 'p1' ? 'p2' : 'p1';
      _playerShots(opponentId); // This ensures the list exists

      // Sync URL with new shots
      _syncUrlWithShots();
    });

    final shotsCount = _playerShots(_selectedPlayerId).length;
    final msg = value == 'Ditch'
        ? 'Ditch recorded'
        : 'Mat length set to $value';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'End $_currentEnd • ${_selected.name}: $msg (Shot $shotsCount/4)',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _undo() {
    final list = _playerShots(_selectedPlayerId);
    if (list.isNotEmpty) {
      setState(() {
        list.removeLast();
        _syncUrlWithShots();
      });
    }
  }

  void _nextEnd() {
    // Prevent going beyond the total ends from BasicScoringScreen
    if (_currentEnd >= widget.totalEnds) return;
    setState(() {
      _currentEnd += 1;
      _ensureEnd(_currentEnd);
    });
  }

  void _prevEnd() {
    if (_currentEnd <= 1) return;
    setState(() => _currentEnd -= 1);
  }

  // Remove ability to create new ends since they should come from BasicScoringScreen
  void _newEnd() {
    // This functionality is disabled as ends should only be created in BasicScoringScreen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'New ends can only be created in the basic scoring screen',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearCurrentEnd() {
    setState(() {
      _shots[_currentEnd] = {'p1': [], 'p2': []};
      _syncUrlWithShots();
    });
  }

  /* -------------------- Logic -------------------- */

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

                  // Top: player + end mini bar (refactored, same UI, cleaner structure)
                  SafeArea(
                    minimum: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row 1: Back • PlayerToggle • Settings
                        GlassPill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                CompactIconButton(
                                  onPressed: () => Navigator.maybePop(context),
                                  icon: CupertinoIcons.chevron_back,
                                  tooltip: 'Back',
                                ),

                                const SizedBox(width: 8),

                                // Flexible PlayerToggle so it never overflows
                                Expanded(
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                    child: PlayerToggle(
                                      players: _players,
                                      selectedId: _selectedPlayerId,
                                      onChanged: _switchPlayer,
                                      scores: _computeScores(),
                                      shotsLeft: {
                                        'p1': 4 - _playerShots('p1').length,
                                        'p2': 4 - _playerShots('p2').length,
                                      },
                                      endScores: widget.endScore,
                                      currentEnd: widget.currentEnd,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                CompactIconButton(
                                  onPressed: () => _openSettingsSheet(context),
                                  icon: CupertinoIcons.slider_horizontal_3,
                                  tooltip: 'Settings',
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // End score display with modern look (kept same content, cleaner layout)
                        // GlassPill(
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(12),
                        //     child: Row(
                        //       children: [
                        //         Expanded(
                        //           child: _buildModernScoreCard(
                        //             playerName: widget.player1.name,
                        //             playerColor: widget.player1.color,
                        //             score: widget.endScore['player1'] ?? 0,
                        //             endNumber: widget.currentEnd,
                        //           ),
                        //         ),
                        //         // Slim divider
                        //         Container(
                        //           width: 1,
                        //           height: 40,
                        //           margin: const EdgeInsets.symmetric(
                        //             horizontal: 12,
                        //           ),
                        //           color: Colors.white12,
                        //         ),
                        //         Expanded(
                        //           child: _buildModernScoreCard(
                        //             playerName: widget.player2.name,
                        //             playerColor: widget.player2.color,
                        //             score: widget.endScore['player2'] ?? 0,
                        //             endNumber: widget.currentEnd,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        // const SizedBox(height: 10),

                        // Row 2: End selector (centered) — kept in its own pill
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
                                leftScore: widget.endScore['player1'] ?? 0,
                                rightScore: widget.endScore['player2'] ?? 0,
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
                                    child: AppButton(
                                      onPressed: _undo,
                                      icon: CupertinoIcons.arrow_uturn_left,
                                      label: 'Undo',
                                      tint: g2,
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
  Map<String, int> _computeScores() {
    final scores = <String, int>{'p1': 0, 'p2': 0};
    for (final end in _shots.entries) {
      // Get best shot (lowest number = closest to center) for each player in this end
      Map<String, int?> bestShots = {};
      for (final player in _players) {
        final shots = end.value[player.id] ?? [];
        int? bestValue;
        for (final shot in shots) {
          if (shot.value != 'Ditch') {
            final value = int.parse(shot.value);
            bestValue = bestValue == null ? value : math.min(bestValue, value);
          }
        }
        bestShots[player.id] = bestValue;
      }

      // Only score points for the player with the closest shot (lowest number)
      // If both have the same best shot, no points are awarded
      final p1Best = bestShots['p1'];
      final p2Best = bestShots['p2'];

      if (p1Best != null && (p2Best == null || p1Best < p2Best)) {
        // Player 1 wins the end
        scores['p1'] = (scores['p1'] ?? 0) + (4 - p1Best);
        // Player 2 gets 0 for this end (already initialized to 0)
      } else if (p2Best != null && (p1Best == null || p2Best < p1Best)) {
        // Player 2 wins the end
        scores['p2'] = (scores['p2'] ?? 0) + (4 - p2Best);
        // Player 1 gets 0 for this end (already initialized to 0)
      }
      // If equal or no valid shots, no points awarded
    }
    return scores;
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

  /* -------------------- UI Helpers -------------------- */

  /* -------------------- Settings Sheet -------------------- */
  void _clearAllData() {
    setState(() {
      _shots.clear();
      // Reinitialize current end
      _ensureEnd(_currentEnd);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data has been cleared'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                    'Tip: Larger outer ring makes “Ditch” area smaller. Keep between 80–95% of half-min.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: const Color(0xFF111A15),
                              title: const Text(
                                'Clear All Data',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'This will clear all stored shots data. This action cannot be undone.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(
                                      context,
                                    ).pop(); // Close settings sheet
                                    _clearAllData();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Clear All'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        foregroundColor: Colors.white,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Clear All Data',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
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
