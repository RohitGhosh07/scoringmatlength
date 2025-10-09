import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/shot.dart';

class UrlUtils {
  /// Parses shot coordinates from URL parameter string
  /// Format: "x1,y1;x2,y2;x3,y3" where x,y are normalized coordinates (0-1)
  static List<Shot> parseShotsFromUrl(
    String playerId,
    String? shotsParam,
    int end,
  ) {
    if (shotsParam == null) return [];

    List<Shot> result = [];
    final shotPairs = shotsParam.split(';');

    for (var pair in shotPairs) {
      final coords = pair.split(',');
      if (coords.length == 2) {
        final x = double.tryParse(coords[0]);
        final y = double.tryParse(coords[1]);
        if (x != null && y != null && x >= 0 && x <= 1 && y >= 0 && y <= 1) {
          // Calculate distance from center to determine shot value
          final center = const Offset(0.5, 0.5);
          final pos = Offset(x, y);
          final dist = (pos - center).distance;

          // Classify shot value based on distance
          String value;
          if (dist <= 0.18)
            value = '0';
          else if (dist <= 0.36)
            value = '1';
          else if (dist <= 0.54)
            value = '2';
          else if (dist <= 0.72)
            value = '3';
          else if (dist <= 0.90)
            value = '4';
          else
            value = 'Ditch';

          result.add(
            Shot(playerId: playerId, normPos: pos, value: value, end: end),
          );
        }
      }
    }
    return result;
  }

  /// Converts shots back to URL parameter string format
  static String shotsToUrlParam(List<Shot> shots) {
    return shots
        .map(
          (s) =>
              '${s.normPos.dx.toStringAsFixed(2)},${s.normPos.dy.toStringAsFixed(2)}',
        )
        .join(';');
  }
}
