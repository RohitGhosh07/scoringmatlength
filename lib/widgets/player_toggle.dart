import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class PlayerToggle extends StatelessWidget {
  final String player1Name;
  final String player2Name;
  final String selectedPlayer;
  final Function(String) onPlayerSelected;
  final Map<String, PlayerStats> playerStats;

  const PlayerToggle({
    super.key,
    required this.player1Name,
    required this.player2Name,
    required this.selectedPlayer,
    required this.onPlayerSelected,
    required this.playerStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Player selector
        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _PlayerSegment(
                  name: player1Name,
                  isSelected: selectedPlayer == player1Name,
                  onTap: () => onPlayerSelected(player1Name),
                ),
              ),
              Expanded(
                child: _PlayerSegment(
                  name: player2Name,
                  isSelected: selectedPlayer == player2Name,
                  onTap: () => onPlayerSelected(player2Name),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Stats row
        if (playerStats.containsKey(selectedPlayer))
          Text(
            'Ends: ${playerStats[selectedPlayer]!.ends} | Last: ${playerStats[selectedPlayer]!.lastScore}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ).animate().fadeIn(),
      ],
    );
  }
}

class _PlayerSegment extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayerSegment({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.surface
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
              border: isSelected
                  ? Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                name,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.labelLarge?.color?.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class PlayerStats {
  final int ends;
  final String lastScore;

  const PlayerStats({required this.ends, required this.lastScore});
}
