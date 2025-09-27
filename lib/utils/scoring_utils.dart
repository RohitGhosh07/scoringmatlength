import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/shot.dart';

String classifyTap(Offset localPos, Size size, double outerFraction) {
  final center = Offset(size.width / 2, size.height / 2);
  final dx = localPos.dx - center.dx;
  final dy = localPos.dy - center.dy;
  final r = math.sqrt(dx * dx + dy * dy);

  final halfMin = math.min(size.width, size.height) / 2;
  final thresholds = [
    0.18 * halfMin,
    0.36 * halfMin,
    0.54 * halfMin,
    0.72 * halfMin,
    outerFraction * halfMin, // adjustable outer ring
  ];
  for (int i = 0; i < thresholds.length; i++) {
    if (r <= thresholds[i]) return '$i';
  }
  return 'Ditch';
}

Map<String, int> computeScores(
  Map<int, Map<String, List<Shot>>> shots,
  List<String> playerIds,
) {
  final scores = <String, int>{};
  for (final playerId in playerIds) {
    scores[playerId] = 0;
  }

  for (final end in shots.entries) {
    for (final playerId in playerIds) {
      final playerShots = end.value[playerId] ?? [];
      for (final shot in playerShots) {
        if (shot.value != 'Ditch') {
          scores[playerId] =
              (scores[playerId] ?? 0) + (4 - int.parse(shot.value));
        }
      }
    }
  }
  return scores;
}
