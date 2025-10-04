import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EndSelector extends StatelessWidget {
  const EndSelector({
    super.key,
    required this.currentEnd,
    required this.onPrev,
    required this.onNext,
    required this.leftScore,
    required this.rightScore,
    this.leftLabel,
    this.rightLabel,
  });

  final int currentEnd;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  /// Scores to show on the left and right of the End badge
  final int leftScore;
  final int rightScore;

  /// Optional team labels under the scores
  final String? leftLabel;
  final String? rightLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // lets the arrows sit at the extremes
      child: Row(
        children: [
          // Extreme left arrow
          MiniGlassButton(
            icon: CupertinoIcons.chevron_left,
            onTap: onPrev,
            tooltip: 'Previous End',
          ),

          // Center area expands; scores flank the End badge
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScorePill(value: leftScore, label: leftLabel),
                  const SizedBox(width: 10),
                  EndBadge(value: currentEnd),
                  const SizedBox(width: 10),
                  ScorePill(value: rightScore, label: rightLabel),
                ],
              ),
            ),
          ),

          // Extreme right arrow
          MiniGlassButton(
            icon: CupertinoIcons.chevron_right,
            onTap: onNext,
            tooltip: 'Next End',
          ),
        ],
      ),
    );
  }
}

class MiniGlassButton extends StatelessWidget {
  const MiniGlassButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class EndBadge extends StatelessWidget {
  const EndBadge({super.key, required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
      child: Container(
        key: ValueKey(value),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Icon(
            //   CupertinoIcons.circle_grid_3x3,
            //   size: 14,
            //   color: Colors.white70,
            // ),
            // const SizedBox(width: 6),
            Text(
              'End $value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScorePill extends StatelessWidget {
  const ScorePill({super.key, required this.value, this.label});

  final int value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 2),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10.5,
                height: 1.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
