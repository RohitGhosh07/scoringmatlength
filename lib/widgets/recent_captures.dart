import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../state/scoring_state.dart';

class RecentCaptures extends StatelessWidget {
  final List<ScoringEntry> entries;
  final VoidCallback onUndoLast;

  const RecentCaptures({
    super.key,
    required this.entries,
    required this.onUndoLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 16),
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child:
                  _CaptureChip(
                        entry: entries[i],
                        onUndo: i == 0 ? onUndoLast : null,
                      )
                      .animate()
                      .scale(duration: 200.ms, curve: Curves.easeOutCubic)
                      .slideX(
                        begin: 0.5,
                        duration: 200.ms,
                        curve: Curves.easeOutCubic,
                        delay: (50 * i).ms,
                      ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _CaptureChip extends StatelessWidget {
  final ScoringEntry entry;
  final VoidCallback? onUndo;

  const _CaptureChip({required this.entry, this.onUndo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.toString(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (onUndo != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onUndo,
              child: Icon(
                Icons.close,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
