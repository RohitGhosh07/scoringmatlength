import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EndSelector extends StatelessWidget {
  const EndSelector({
    super.key,
    required this.currentEnd,
    required this.onPrev,
    required this.onNext,
  });

  final int currentEnd;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiniGlassButton(
          icon: CupertinoIcons.chevron_left,
          onTap: onPrev,
          tooltip: 'Previous End',
        ),
        const SizedBox(width: 8),
        EndBadge(value: currentEnd),
        const SizedBox(width: 8),
        MiniGlassButton(
          icon: CupertinoIcons.chevron_right,
          onTap: onNext,
          tooltip: 'Next End',
        ),
      ],
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
            const Icon(
              CupertinoIcons.circle_grid_3x3,
              size: 14,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
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
