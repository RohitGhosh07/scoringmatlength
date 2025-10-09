import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/player.dart';
import '../models/shot.dart';
import '../screens/scoringscreen.dart';
import '../utils/url_utils.dart';

final router = GoRouter(
  initialLocation: '/scoring',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/scoring',
      builder: (context, state) {
        // Get query parameters from location
        final location = html.window.location;
        final search = location.search ?? '';
        final hash = location.hash ?? '';

        Map<String, String> params = {};

        // Try to get parameters from search string first
        if (search.isNotEmpty) {
          final searchUri = Uri.parse('http://placeholder$search');
          params.addAll(searchUri.queryParameters);
        }

        // If no parameters in search, try hash fragment
        if (params.isEmpty && hash.isNotEmpty) {
          final hashParts = hash.split('?');
          if (hashParts.length > 1) {
            final hashUri = Uri.parse('http://placeholder?${hashParts[1]}');
            params.addAll(hashUri.queryParameters);
          }
        }

        debugPrint('Location: ${location.href}');
        debugPrint('Search: $search');
        debugPrint('Hash: $hash');
        debugPrint('Parsed Parameters: $params');
        debugPrint('Parsed Parameters: $params');
        debugPrint('URL Parameters: $params');

        // Extract player names
        final player1Name = params['player1Name'] ?? 'Player 1';
        final player2Name = params['player2Name'] ?? 'Player 2';

        // Create player objects with distinct colors
        final player1 = Player(
          id: 'p1',
          name: player1Name,
          color: const Color.fromARGB(
            255,
            255,
            174,
            0,
          ), // Yellow color for player 1
        );
        final player2 = Player(
          id: 'p2',
          name: player2Name,
          color: const Color.fromARGB(
            255,
            0,
            251,
            255,
          ), // Orange color for player 2
        );

        // Parse end information
        final currentEnd = int.tryParse(params['currentEnd'] ?? '') ?? 1;
        final totalEnds = int.tryParse(params['totalEnds'] ?? '') ?? 7;

        // Parse scores
        final player1Score = int.tryParse(params['player1Score'] ?? '') ?? 0;
        final player2Score = int.tryParse(params['player2Score'] ?? '') ?? 0;

        // Parse end scores
        final endScore = {
          'p1': int.tryParse(params['player1EndScore'] ?? '') ?? 0,
          'p2': int.tryParse(params['player2EndScore'] ?? '') ?? 0,
        };

        // Parse shot coordinates using UrlUtils
        Map<int, Map<String, List<Shot>>> shots = {};

        // Initialize shots for current end using UrlUtils
        shots[currentEnd] = {
          'p1': UrlUtils.parseShotsFromUrl(
            'p1',
            params['p1_shots'],
            currentEnd,
          ),
          'p2': UrlUtils.parseShotsFromUrl(
            'p2',
            params['p2_shots'],
            currentEnd,
          ),
        };

        return ScoringScreen(
          player1: player1,
          player2: player2,
          currentEnd: currentEnd,
          totalEnds: totalEnds,
          player1TotalScore: player1Score,
          player2TotalScore: player2Score,
          endScore: endScore,
          initialShots: shots,
        );
      },
    ),
  ],
);
