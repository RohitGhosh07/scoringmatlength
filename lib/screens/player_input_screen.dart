import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/player.dart';
import '../widgets/common.dart';
import 'basic_scoring_screen.dart';

class PlayerInputScreen extends StatefulWidget {
  const PlayerInputScreen({Key? key}) : super(key: key);

  @override
  _PlayerInputScreenState createState() => _PlayerInputScreenState();
}

class _PlayerInputScreenState extends State<PlayerInputScreen> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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

  // ———————— visual helpers (UI only) ————————
  BoxDecoration _glassCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.10),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 28,
          offset: const Offset(0, 14),
          color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(CupertinoIcons.person_fill),
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF30B082), width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient + subtle radial glow background (dark green theme)
      body: Stack(
        children: [
          Positioned.fill(
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF052E25), // very dark green
                    Color(0xFF0B3D2E), // deep jungle green
                    Color(0xFF145A40), // forest green
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.05,
                    center: const Alignment(-0.55, -0.8),
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand title
                      Text(
                        'Mat & Wood',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: 0.85,
                        child: Text(
                          'Quick Match Setup',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBFEFE3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Input card (glassy)
                      Container(
                        decoration: _glassCard(context),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.person_2_fill,
                                    color: Color(0xFF30B082),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Opacity(
                                    opacity: 0.9,
                                    child: const Text(
                                      'Enter Player Names',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                  color: Colors.white,
                                ), // typed text
                                controller: _player1Controller,
                                textInputAction: TextInputAction.next,
                                decoration: _fieldDecoration('Player 1')
                                    .copyWith(
                                      labelStyle: const TextStyle(
                                        color: Colors
                                            .white, // 👈 label text in white
                                        fontWeight: FontWeight.w600,
                                      ),
                                      prefixIconColor: Colors.white70,
                                    ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'Please enter player 1 name'
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                cursorColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                controller: _player2Controller,
                                textInputAction: TextInputAction.done,
                                decoration: _fieldDecoration('Player 2')
                                    .copyWith(
                                      labelStyle: const TextStyle(
                                        color: Colors
                                            .white, // 👈 label text in white
                                        fontWeight: FontWeight.w600,
                                      ),
                                      prefixIconColor: Colors.white70,
                                    ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'Please enter player 2 name'
                                    : null,
                              ),

                              const SizedBox(height: 4),

                              // // Tiny helper tip
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //     left: 4,
                              //     top: 8,
                              //     bottom: 8,
                              //   ),
                              //   child: Opacity(
                              //     opacity: 0.7,
                              //     child: const Text(
                              //       'Tip: You can change colors later in Settings.',
                              //       style: TextStyle(
                              //         fontSize: 11,
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Start button (kept AppButton to preserve your style)
                      AppButton(
                        onPressed: () {
                          try {
                            if (_formKey.currentState?.validate() ?? false) {
                              final player1 = Player(
                                id: '1',
                                name: _player1Controller.text.trim(),
                                color: const Color(
                                  0xFF5BE7C4,
                                ), // same as scoring screen
                              );
                              final player2 = Player(
                                id: '2',
                                name: _player2Controller.text.trim(),
                                color: const Color(
                                  0xFFFFD166,
                                ), // same as scoring screen
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BasicScoringScreen(
                                    player1: player1,
                                    player2: player2,
                                  ),
                                ),
                              );
                            }
                          } catch (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error validating form. Please try again.',
                                ),
                              ),
                            );
                          }
                        },
                        icon: CupertinoIcons.play_fill,
                        label: 'Start Game',
                        color: const Color(0xFF30B082),
                      ),

                      const SizedBox(height: 8),

                      // Subtle footer / brand line
                      Center(
                        child: Opacity(
                          opacity: 0.6,
                          child: const Text(
                            'Scoring made simple.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFBFEFE3),
                            ),
                          ),
                        ),
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
}
