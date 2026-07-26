import 'dart:math' as math;

import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/core/design/actly_typography.dart';
import 'package:flutter/material.dart';

class RadialGauge extends StatelessWidget {
  const RadialGauge({
    required this.value,
    super.key,
    this.size = 188,
    this.animate = true,
  });

  final int value;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      label: 'Confidence $value out of 10',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 10).toDouble()),
        duration: animate && !reducedMotion
            ? const Duration(milliseconds: 650)
            : Duration.zero,
        curve: Curves.easeOutCubic,
        builder: (context, animated, child) {
          return SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _GaugePainter(value: animated),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      animated.round().toString(),
                      style: ActlyTypography.data(size: size * 0.28),
                    ),
                    Text(
                      '/ 10',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 10;
    const start = math.pi * 0.78;
    const sweep = math.pi * 1.44;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 11
      ..color = ActlyColors.divider.withValues(alpha: 0.8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      track,
    );

    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 11
      ..color = value < 7 ? ActlyColors.rescueAmber : ActlyColors.signalCyan;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep * (value / 10),
      false,
      progress,
    );

    final tick = Paint()
      ..color = ActlyColors.mutedSteel
      ..strokeWidth = 1;
    for (var index = 0; index <= 10; index++) {
      final angle = start + sweep * index / 10;
      final outer = Offset(
        center.dx + math.cos(angle) * (radius + 6),
        center.dy + math.sin(angle) * (radius + 6),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - 3),
        center.dy + math.sin(angle) * (radius - 3),
      );
      canvas.drawLine(inner, outer, tick);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value;
}
