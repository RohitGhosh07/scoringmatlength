import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scoringmatlength/screens/scoringscreen.dart';




void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mat & Wood',
     
      themeMode: ThemeMode.system, // Automatically use system theme
      home: const MatWoodScreen(),
    );
  }
}
