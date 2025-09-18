import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoringEntry {
  final bool isWood;
  final int? matLength;

  const ScoringEntry({required this.isWood, this.matLength});

  @override
  String toString() {
    return isWood ? 'Wood' : matLength.toString();
  }
}

final scoringHistoryProvider =
    StateNotifierProvider<ScoringHistoryNotifier, List<ScoringEntry>>((ref) {
      return ScoringHistoryNotifier();
    });

class ScoringHistoryNotifier extends StateNotifier<List<ScoringEntry>> {
  ScoringHistoryNotifier() : super([]);

  void addMatLength(int length) {
    state = [
      ScoringEntry(isWood: false, matLength: length),
      ...state,
    ].take(4).toList(); // Keep last 4 entries
  }

  void addWood() {
    state = [
      const ScoringEntry(isWood: true),
      ...state,
    ].take(4).toList(); // Keep last 4 entries
  }

  void undoLast() {
    if (state.isNotEmpty) {
      state = state.sublist(1);
    }
  }
}
