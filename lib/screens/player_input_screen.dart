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
    // Ensure the form key is properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    const Text(
                      'Welcome to\nMat & Wood',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Player name inputs wrapped in GlassPill
                    GlassPill(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter Player Names',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _player1Controller,
                              decoration: InputDecoration(
                                labelText: 'Player 1',
                                prefixIcon: const Icon(
                                  CupertinoIcons.person_fill,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter player 1 name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _player2Controller,
                              decoration: InputDecoration(
                                labelText: 'Player 2',
                                prefixIcon: const Icon(
                                  CupertinoIcons.person_fill,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter player 2 name';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Start Game button using AppButton
                    AppButton(
                      onPressed: () {
                        try {
                          if (_formKey.currentState?.validate() ?? false) {
                            final player1 = Player(
                              id: '1',
                              name: _player1Controller.text,
                              color: const Color(
                                0xFF5BE7C4,
                              ), // Same as scoring screen
                            );
                            final player2 = Player(
                              id: '2',
                              name: _player2Controller.text,
                              color: const Color(
                                0xFFFFD166,
                              ), // Same as scoring screen
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
                      icon: CupertinoIcons.play_fill,
                      label: 'Start Game',
                      color: const Color(
                        0xFF30B082,
                      ), // Same green as scoring screen
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }
}
