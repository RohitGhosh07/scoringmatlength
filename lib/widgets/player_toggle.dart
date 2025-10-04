import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerToggle extends StatelessWidget {
  const PlayerToggle({
    super.key,
    required this.players,
    required this.selectedId,
    required this.onChanged,
    required this.scores,
    required this.shotsLeft,
    required this.endScores,
    required this.currentEnd,
  });

  final Map<String, int> endScores;
  final int currentEnd;
  final List<Player> players;
  final String selectedId;
  final ValueChanged<String> onChanged;
  final Map<String, int> scores;
  final Map<String, int> shotsLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: players.map((p) {
          final selected = p.id == selectedId;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: selected ? p.color.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: p.color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onChanged(p.id),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: p.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 4),
                    // Column(
                    //   children: [
                    //     Text(
                    //       'End $currentEnd: ${endScores[p.id == 'p1' ? 'player1' : 'player2'] ?? 0}',
                    //       style: TextStyle(
                    //         color: p.color,
                    //         fontSize: 13,
                    //         fontWeight: FontWeight.w700,
                    //       ),
                    //     ),
                    //     Text(
                    //       '${shotsLeft[p.id] ?? 4} shots left',
                    //       style: TextStyle(
                    //         color: Colors.white.withOpacity(0.7),
                    //         fontSize: 11,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PlayerToggleDesktop extends StatelessWidget {
  const PlayerToggleDesktop({
    super.key,
    required this.players,
    required this.selectedId,
    required this.onChanged,
  });
  final List<Player> players;
  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: players.map((p) {
        final selected = p.id == selectedId;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: ElevatedButton(
              onPressed: () => onChanged(p.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: selected
                    ? p.color
                    : Colors.white.withOpacity(0.08),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
