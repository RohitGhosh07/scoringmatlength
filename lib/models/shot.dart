import 'package:flutter/material.dart';

class Shot {
  final String playerId;
  final Offset normPos; // [0..1] x [0..1]
  final String value; // '0'..'4' or 'Ditch'
  final int end;
  const Shot({
    required this.playerId,
    required this.normPos,
    required this.value,
    required this.end,
  });
}
