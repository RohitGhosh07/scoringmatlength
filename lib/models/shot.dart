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

  // Convert Shot to JSON
  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'normPosX': normPos.dx,
    'normPosY': normPos.dy,
    'value': value,
    'end': end,
  };

  // Create Shot from JSON
  factory Shot.fromJson(Map<String, dynamic> json) => Shot(
    playerId: json['playerId'],
    normPos: Offset(json['normPosX'], json['normPosY']),
    value: json['value'],
    end: json['end'],
  );
}
