import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/player.dart';
import '../widgets/common.dart';
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
  Widget _buildPlayerScore({
    required String name,
    required int score,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            score.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndScore({
    required String name,
    required int score,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          name,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  final List<Map<String, int>> scores = [];
  int currentEnd = 1;
  late final GlobalKey<FormState> _formKey;
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    // Ensure the form key is properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0E1511)
          : const Color(0xFFE9FFF4),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with title and scores
            GlassPill(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'End $currentEnd',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.settings),
                          onPressed: () {
                            // TODO: Add settings functionality if needed
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPlayerScore(
                          name: widget.player1.name,
                          score: _calculateTotalScore(true),
                          color: widget.player1.color,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _buildPlayerScore(
                          name: widget.player2.name,
                          score: _calculateTotalScore(false),
                          color: widget.player2.color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Previous ends scores
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: scores.length,
                itemBuilder: (context, index) {
                  final endScore = scores[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GlassPill(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // End number with circular background
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF30B082).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF30B082),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Scores
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildEndScore(
                                    name: widget.player1.name,
                                    score: endScore['player1']!,
                                    color: widget.player1.color,
                                  ),
                                  _buildEndScore(
                                    name: widget.player2.name,
                                    score: endScore['player2']!,
                                    color: widget.player2.color,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Advanced scoring button
                            IconButton(
                              icon: const Icon(
                                CupertinoIcons.chart_bar_alt_fill,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScoringScreen(
                                      player1: widget.player1,
                                      player2: widget.player2,
                                      currentEnd: index + 1,
                                    ),
                                  ),
                                );
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input section at the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassPill(
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
                                decoration: InputDecoration(
                                  labelText: widget.player1.name,
                                  prefixIcon: const Icon(CupertinoIcons.number),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null; // Allow empty field
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _player2Controller,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: widget.player2.name,
                                  prefixIcon: const Icon(CupertinoIcons.number),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null; // Allow empty field
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
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
                                      // If only one player's score is entered, set the other player's score to 0
                                      int player1Score =
                                          _player1Controller.text.isNotEmpty
                                          ? int.parse(_player1Controller.text)
                                          : 0;
                                      int player2Score =
                                          _player2Controller.text.isNotEmpty
                                          ? int.parse(_player2Controller.text)
                                          : 0;
                                      _addEndScore(player1Score, player2Score);
                                      _player1Controller.clear();
                                      _player2Controller.clear();
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                            const SizedBox(width: 16),
                            AppButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScoringScreen(
                                      player1: widget.player1,
                                      player2: widget.player2,
                                      currentEnd: currentEnd,
                                    ),
                                  ),
                                );
                              },
                              icon: CupertinoIcons.chart_bar_alt_fill,
                              label: 'Advanced',
                              tint: const Color(0xFF30B082),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  int _calculateTotalScore(bool isPlayer1) {
    return scores.fold(
      0,
      (sum, score) => sum + (isPlayer1 ? score['player1']! : score['player2']!),
    );
  }
}
