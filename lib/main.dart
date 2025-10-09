import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'config/router_config.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  // Configure for web
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mat & Wood',
      themeMode: ThemeMode.light, // Always use light theme
      routerConfig: router,
    );
  }
}
