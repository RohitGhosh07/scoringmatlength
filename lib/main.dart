import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scoringmatlength/screens/scoringscreen.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'widgets/responsive_layout_container.dart';
import 'widgets/player_toggle.dart';
import 'widgets/target_area.dart';
import 'widgets/recent_captures.dart';
import 'state/player_state.dart';
import 'state/scoring_state.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mat & Wood',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically use system theme
      home: const MatWoodScreen(),
    );
  }
}
