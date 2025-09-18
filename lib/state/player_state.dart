import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/player_toggle.dart';

final selectedPlayerProvider = StateProvider<String>((ref) => 'Arya');

final playerStatsProvider = Provider<Map<String, PlayerStats>>((ref) {
  // This is demo data - in a real app, this would be maintained in state
  return {
    'Arya': const PlayerStats(ends: 6, lastScore: '2'),
    'Rohit': const PlayerStats(ends: 5, lastScore: 'Wood'),
  };
});
