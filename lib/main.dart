import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'screens/player_input_screen.dart';
import 'screens/scoringscreen.dart';
import 'models/player.dart';
import 'utils/url_parser.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Parse initial URL if any
    final initialUri = Uri.parse(Uri.base.toString());
    final initialRoute = _getInitialRoute(initialUri);

    return MaterialApp(
      title: 'Mat & Wood',
      themeMode: ThemeMode.light, // Always use light theme
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        // Handle both direct /scoring and /#/scoring routes
        if (settings.name?.contains('scoring') == true) {
          final params = Uri.parse(settings.name!).queryParameters;
          return MaterialPageRoute(
            builder: (context) => ScoringScreen(
              player1: Player(
                id: 'p1',
                name: params['player1Name'] ?? 'Player 1',
                color: Colors.blue,
              ),
              player2: Player(
                id: 'p2',
                name: params['player2Name'] ?? 'Player 2',
                color: Colors.red,
              ),
              currentEnd: int.tryParse(params['currentEnd'] ?? '') ?? 1,
              totalEnds: int.tryParse(params['totalEnds'] ?? '') ?? 7,
              player1TotalScore:
                  int.tryParse(params['player1Score'] ?? '') ?? 0,
              player2TotalScore:
                  int.tryParse(params['player2Score'] ?? '') ?? 0,
              endScore: {
                'player1': int.tryParse(params['player1EndScore'] ?? '') ?? 0,
                'player2': int.tryParse(params['player2EndScore'] ?? '') ?? 0,
              },
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const PlayerInputScreen(),
        );
      },
    );
  }

  String _getInitialRoute(Uri uri) {
    // Check if we have a hash route
    if (uri.fragment.isNotEmpty) {
      // Convert hash route to normal route
      final withoutHash = uri.fragment;
      if (withoutHash.startsWith('/')) {
        return withoutHash;
      }
      return '/$withoutHash';
    }
    // Check if we have a direct route
    if (uri.path.contains('scoring')) {
      return uri.path;
    }
    return '/';
  }
}
