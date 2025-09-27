import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/player.dart';
import '../models/end_stats.dart';
import '../utils/constants.dart';
import 'common.dart';
import 'player_toggle.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
    required this.players,
    required this.selectedId,
    required this.onPlayerChanged,
    required this.currentEnd,
    required this.onPrevEnd,
    required this.onNextEnd,
    required this.onNewEnd,
    required this.onClearEnd,
    required this.onSave,
    required this.endStats,
    required this.onOpenSettings,
  });

  final List<Player> players;
  final String selectedId;
  final ValueChanged<String> onPlayerChanged;
  final int currentEnd;
  final VoidCallback onPrevEnd;
  final VoidCallback onNextEnd;
  final VoidCallback onNewEnd;
  final VoidCallback onClearEnd;
  final VoidCallback onSave;
  final EndStats endStats;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('Players'),
              PlayerToggleDesktop(
                players: players,
                selectedId: selectedId,
                onChanged: onPlayerChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('End Controls'),
              Row(
                children: [
                  RoundIconButton(
                    icon: CupertinoIcons.back,
                    onPressed: onPrevEnd,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Text(
                        'End $currentEnd',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RoundIconButton(
                    icon: CupertinoIcons.forward,
                    onPressed: onNextEnd,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onNewEnd,
                      icon: const Icon(CupertinoIcons.add_circled),
                      label: const Text('New End'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onClearEnd,
                      icon: const Icon(CupertinoIcons.delete),
                      label: const Text('Clear End'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(CupertinoIcons.check_mark_circled_solid),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(CupertinoIcons.slider_horizontal_3),
                label: const Text('Canvas Settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('End Stats'),
              StatRow(label: 'Ring 0', value: '${endStats.ringCounts[0]}'),
              StatRow(label: 'Ring 1', value: '${endStats.ringCounts[1]}'),
              StatRow(label: 'Ring 2', value: '${endStats.ringCounts[2]}'),
              StatRow(label: 'Ring 3', value: '${endStats.ringCounts[3]}'),
              StatRow(label: 'Ring 4', value: '${endStats.ringCounts[4]}'),
              const Divider(),
              StatRow(label: 'Ditch', value: '${endStats.wood}'),
              const Divider(),
              StatRow(
                label: 'Arya shots',
                value: '${endStats.perPlayerShots['p1'] ?? 0}',
              ),
              StatRow(
                label: 'Rohit shots',
                value: '${endStats.perPlayerShots['p2'] ?? 0}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
