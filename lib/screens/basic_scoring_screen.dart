import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/player.dart';
import '../widgets/common.dart';
import '../utils/constants.dart';
import 'scoringscreen.dart';

class BasicScoringScreen extends StatefulWidget {
  final Player player1;
  final Player player2;

  const BasicScoringScreen({
    Key? key,
    required this.player1,
    required this.player2,
  }) : super(key: key);

  @override
  _BasicScoringScreenState createState() => _BasicScoringScreenState();
}

class _BasicScoringScreenState extends State<BasicScoringScreen> {
  final List<Map<String, int>> scores = [];
  int currentEnd = 1;
  late final GlobalKey<FormState> _formKey;
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  void _addEndScore(int player1Score, int player2Score) {
    setState(() {
      scores.add({'player1': player1Score, 'player2': player2Score});
      currentEnd++;
    });
  }

  // ------------------------ VISUAL HELPERS (UI only) ------------------------

  BoxDecoration _glassCard(BuildContext context) {
    return BoxDecoration(
      color: AppColors.glassLight,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.glassMedium, width: 1.5),
      boxShadow: [
        BoxShadow(
          blurRadius: 24,
          spreadRadius: -8,
          offset: const Offset(0, 12),
          color: Colors.black.withOpacity(0.35),
        ),
        BoxShadow(
          blurRadius: 6,
          spreadRadius: -2,
          offset: const Offset(0, 2),
          color: AppColors.accent.withOpacity(0.08),
        ),
      ],
    );
  }

  TextStyle get _labelStyle => const TextStyle(
    fontSize: 11,
    letterSpacing: 1.0,
    fontWeight: FontWeight.w700,
    color: Colors.white70,
  );

  TextStyle _totalStyle(Color color) => TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w900,
    color: color,
    height: 1.0,
    fontFeatures: const [FontFeature.tabularFigures()], // monospaced digits
  );

  Widget _scoreBadge({
    required String name,
    required int total,
    required Color accent,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth, // use full width of Expanded
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [accent.withOpacity(0.20), accent.withOpacity(0.06)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: accent.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Name row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // TOTAL label
              // Opacity(opacity: 0.75, child: Text('TOTAL', style: _labelStyle)),
              const SizedBox(height: 6),
              // Big total that never clips
              SizedBox(
                height: 48,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('$total', style: _totalStyle(accent)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF30B082).withOpacity(0.45)),
        color: const Color(0xFF30B082).withOpacity(0.15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.flag_fill,
            size: 16,
            color: Color(0xFF30B082),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              'End $currentEnd',
              key: ValueKey(currentEnd),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _endRow({required int index, required int p1, required int p2}) {
    final p1Color = widget.player1.color;
    final p2Color = widget.player2.color;

    return Container(
      decoration: _glassCard(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // End number
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF30B082).withOpacity(0.20),
                    const Color(0xFF30B082).withOpacity(0.06),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF30B082).withOpacity(0.40),
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF30B082),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Compact scoreboard: P1 3 — 2 P2
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: _miniTeamScore(
                      name: widget.player1.name,
                      score: p1,
                      color: p1Color,
                      alignRight: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Opacity(
                      opacity: 0.7,
                      child: Text(
                        '—',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: _miniTeamScore(
                      name: widget.player2.name,
                      score: p2,
                      color: p2Color,
                      alignRight: false,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Open advanced scoring',
              icon: const Icon(
                CupertinoIcons.chart_bar_alt_fill,
                color: Colors.white70,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScoringScreen(
                      player1: widget.player1,
                      player2: widget.player2,
                      currentEnd: index + 1, // Use the clicked end's index + 1
                      totalEnds: currentEnd,
                      player1TotalScore: _calculateTotalScore(true),
                      player2TotalScore: _calculateTotalScore(false),
                      endScore: scores[index],
                    ),
                  ),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.08),
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTeamScore({
    required String name,
    required int score,
    required Color color,
    required bool alignRight,
  }) {
    final nameText = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );

    final scoreText = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '$score',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        scoreText,
        const SizedBox(height: 2),
        // Opacity(opacity: 0.75, child: nameText),
      ],
    );
  }

  // ------------------------------- BUILD -------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.bgDarkest,
      body: Stack(
        children: [
          // 🌌 Dark green gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.bgDarkest, // very dark green
                    AppColors.bgDark, // deep jungle green
                    AppColors.bgMedium, // medium green
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Keep subtle radial highlight if you like (optional)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.1,
                    center: const Alignment(-0.6, -0.8),
                    colors: [
                      const Color(0xFF30B082).withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top summary card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    decoration: _glassCard(context),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _headerChip(),
                              const Spacer(),
                              // IconButton(
                              //   tooltip: 'Settings',
                              //   icon: const Icon(CupertinoIcons.settings),
                              //   onPressed: () {}, // placeholder
                              //   style: IconButton.styleFrom(
                              //     backgroundColor: Colors.white.withOpacity(
                              //       0.09,
                              //     ),
                              //     padding: const EdgeInsets.all(10),
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(12),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Two totals with clear separation and VS
                          Row(
                            children: [
                              Expanded(
                                child: _scoreBadge(
                                  name: widget.player1.name,
                                  total: _calculateTotalScore(true),
                                  accent: widget.player1.color,
                                ),
                              ),
                              Container(
                                width: 44,
                                alignment: Alignment.center,
                                child: Text(
                                  'VS',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white70,

                                    letterSpacing: 1.6,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _scoreBadge(
                                  name: widget.player2.name,
                                  total: _calculateTotalScore(false),
                                  accent: widget.player2.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Previous ends list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: scores.length,
                    itemBuilder: (context, index) {
                      final endScore = scores[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _endRow(
                          index: index,
                          p1: endScore['player1']!,
                          p2: endScore['player2']!,
                        ),
                      );
                    },
                  ),
                ),

                // Input section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Container(
                    decoration: _glassCard(context),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _player1Controller,
                                    keyboardType: TextInputType.number,
                                    decoration: _fieldDecoration(
                                      widget.player1.name,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return null;
                                      if (int.tryParse(value) == null)
                                        return 'Invalid number';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _player2Controller,
                                    keyboardType: TextInputType.number,
                                    decoration: _fieldDecoration(
                                      widget.player2.name,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return null;
                                      if (int.tryParse(value) == null)
                                        return 'Invalid number';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    onPressed: () {
                                      try {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          final p1 =
                                              _player1Controller.text.isNotEmpty
                                              ? int.parse(
                                                  _player1Controller.text,
                                                )
                                              : 0;
                                          final p2 =
                                              _player2Controller.text.isNotEmpty
                                              ? int.parse(
                                                  _player2Controller.text,
                                                )
                                              : 0;
                                          _addEndScore(p1, p2);
                                          _player1Controller.clear();
                                          _player2Controller.clear();
                                        }
                                      } catch (_) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Error validating form. Please try again.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: CupertinoIcons.checkmark_circle_fill,
                                    label: 'Submit End',
                                    color: const Color(0xFF30B082),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // AppButton(
                                //   onPressed: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) => ScoringScreen(
                                //           player1: widget.player1,
                                //           player2: widget.player2,
                                //           currentEnd: currentEnd,
                                //         ),
                                //       ),
                                //     );
                                //   },
                                //   icon: CupertinoIcons.chart_bar_alt_fill,
                                //   label: 'Advanced',
                                //   tint: const Color(0xFF30B082),
                                // ),
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
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        CupertinoIcons.number,
        color: AppColors.accent.withOpacity(0.7),
      ),
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.glassMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
      ),
      fillColor: AppColors.glassLight,
    );
  }

  int _calculateTotalScore(bool isPlayer1) {
    return scores.fold(
      0,
      (sum, score) => sum + (isPlayer1 ? score['player1']! : score['player2']!),
    );
  }
}
