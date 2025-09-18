import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'target_painters.dart';

class TargetArea extends StatefulWidget {
  final Function(int) onMatLengthSelected;
  final Function() onWoodSelected;
  final String? placeholder;

  const TargetArea({
    super.key,
    required this.onMatLengthSelected,
    required this.onWoodSelected,
    this.placeholder,
  });

  @override
  State<TargetArea> createState() => _TargetAreaState();
}

class _TargetAreaState extends State<TargetArea>
    with SingleTickerProviderStateMixin {
  Offset? _tapPosition;
  int? _selectedRing;
  bool _isWood = false;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(vsync: this, duration: 600.ms);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    final radius = math.min(constraints.maxWidth, constraints.maxHeight) / 2;

    // Calculate distance from center as a percentage of radius
    final distance = (localPosition - center).distance;
    final percentage = distance / radius;

    setState(() {
      _tapPosition = localPosition;
      if (percentage > 1.0) {
        // Tap outside the square
        _selectedRing = null;
        _isWood = false;
      } else {
        // Check which ring was tapped
        _isWood = true; // Default to wood
        for (var i = 4; i >= 0; i--) {
          if (percentage <= (i + 1) * 0.2) {
            _selectedRing = i;
            _isWood = false;
            break;
          }
        }
      }
    });

    // Start ripple animation
    _rippleController
      ..reset()
      ..forward();

    // Call the appropriate callback
    if (_isWood) {
      widget.onWoodSelected();
    } else if (_selectedRing != null) {
      widget.onMatLengthSelected(_selectedRing!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapDown: (details) => _handleTapDown(details, constraints),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withOpacity(0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Custom painter for rings
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: TargetPainter(
                      ringColors: AppColors.ringColors,
                      selectedRing: _selectedRing,
                      isWood: _isWood,
                      theme: Theme.of(context),
                    ),
                  ),
                  // Ring labels
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return Text(
                          '$index',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.color?.withOpacity(0.7),
                              ),
                        );
                      }).reversed.toList(),
                    ),
                  ),
                  // Tap position indicator
                  if (_tapPosition != null)
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          painter: TapRipplePainter(
                            position: _tapPosition!,
                            progress: _rippleController.value,
                            color: _isWood
                                ? Theme.of(context).colorScheme.secondary
                                : AppColors.ringColors[_selectedRing ?? 0],
                          ),
                        );
                      },
                    ),
                  // Placeholder text
                  if (widget.placeholder != null && _tapPosition == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          widget.placeholder!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                              ),
                        ),
                      ),
                    ),
                  // Helper hint
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 8,
                    child: Text(
                      'Tap rings for mat length. Tap outside rings (inside the square) for Wood.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
