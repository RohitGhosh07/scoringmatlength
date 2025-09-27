import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../models/player.dart';
import '../models/shot.dart';
import 'rings_painter.dart';

class CanvasArea extends StatefulWidget {
  const CanvasArea({
    super.key,
    required this.lastTapLocal,
    required this.hoverLocal,
    required this.ripple,
    required this.currentEnd,
    required this.shots,
    required this.players,
    required this.selectedPlayerId,
    required this.outerFraction,
    required this.onTapResolved,
    required this.onHover,
  });

  final Offset? lastTapLocal;
  final Offset? hoverLocal;
  final Animation<double> ripple;
  final int currentEnd;
  final Map<int, Map<String, List<Shot>>> shots;
  final List<Player> players;
  final String selectedPlayerId;
  final double outerFraction;
  final void Function(Offset localPos, Size canvasSize) onTapResolved;
  final ValueChanged<Offset?> onHover;

  @override
  State<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> {
  ui.Image? _jackImage;

  @override
  void initState() {
    super.initState();
    _loadJackImage();
  }

  Future<void> _loadJackImage() async {
    try {
      final data = await rootBundle.load('assets/images/jack.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      setState(() => _jackImage = frame.image);
    } catch (e) {
      print('Error loading jack image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => widget.onHover(e.localPosition),
      onExit: (_) => widget.onHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => widget.onTapResolved(
          d.localPosition,
          context.size ?? const Size(0, 0),
        ),
        child: AnimatedBuilder(
          animation: widget.ripple,
          builder: (_, __) {
            return CustomPaint(
              painter: RingsPainter(
                lastTap: widget.lastTapLocal,
                hover: widget.hoverLocal,
                rippleValue: widget.ripple.value,
                currentEnd: widget.currentEnd,
                shots: widget.shots,
                players: widget.players,
                selectedPlayerId: widget.selectedPlayerId,
                outerFraction: widget.outerFraction,
                jackImage: _jackImage,
              ),
            );
          },
        ),
      ),
    );
  }
}
