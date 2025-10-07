import 'package:flutter/material.dart';
import '../models/shot.dart';

class UrlParser {
  static List<Shot> parseShots(String shotsString, String playerId, int end) {
    if (shotsString.isEmpty) return [];

    return shotsString.split(',').map((shot) {
      if (shot == 'D') {
        // For ditch shots, use a default position at the edge
        return Shot(
          playerId: playerId,
          value: 'Ditch',
          normPos: const Offset(0.5, 0.9), // Position near the edge
          end: end,
        );
      } else {
        // For regular shots, use a position based on the ring value
        final value = int.tryParse(shot) ?? 0;
        // Calculate a position within the appropriate ring
        final distance = 0.1 + (value * 0.1); // Further out for higher numbers
        final angle = value * 45.0; // Spread shots around the circle
        final dx = 0.5 + (distance * cos(angle));
        final dy = 0.5 + (distance * sin(angle));

        return Shot(
          playerId: playerId,
          value: shot,
          normPos: Offset(dx, dy),
          end: end,
        );
      }
    }).toList();
  }
}

// Helper function to convert degrees to radians
double cos(double degrees) => degrees * (3.141592653589793 / 180.0);

double sin(double degrees) => degrees * (3.141592653589793 / 180.0);
