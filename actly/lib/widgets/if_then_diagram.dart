import 'dart:math' as math;

import 'package:actly/core/design/actly_colors.dart';
import 'package:flutter/material.dart';

class IfThenDiagram extends StatelessWidget {
  const IfThenDiagram({
    required this.trigger,
    required this.action,
    super.key,
    this.compact = false,
    this.actionAccent = ActlyColors.signalCyan,
  });

  final String trigger;
  final String action;
  final bool compact;
  final Color actionAccent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'If $trigger, then $action',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 520;
          if (horizontal) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Expanded(
                  child: _Node(
                    label: 'IF',
                    value: trigger,
                    accent: ActlyColors.mutedSteel,
                    compact: compact,
                  ),
                ),
                SizedBox(
                  width: 74,
                  child: CustomPaint(
                    painter: _ConnectorPainter(color: actionAccent),
                  ),
                ),
                Expanded(
                  child: _Node(
                    label: 'THEN',
                    value: action,
                    accent: actionAccent,
                    compact: compact,
                  ),
                ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _Node(
                label: 'IF',
                value: trigger,
                accent: ActlyColors.mutedSteel,
                compact: compact,
              ),
              SizedBox(
                height: 52,
                child: CustomPaint(
                  painter: _VerticalConnectorPainter(color: actionAccent),
                ),
              ),
              _Node(
                label: 'THEN',
                value: action,
                accent: actionAccent,
                compact: compact,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.label,
    required this.value,
    required this.accent,
    required this.compact,
  });

  final String label;
  final String value;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 86 : 110),
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: ActlyColors.blueprintBlue,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.78)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              '01.${label == 'IF' ? 'A' : 'B'}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent.withValues(alpha: 0.65),
                    fontSize: 10,
                  ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(height: compact ? 7 : 10),
              Text(
                value,
                style: (compact
                        ? Theme.of(context).textTheme.titleMedium
                        : Theme.of(context).textTheme.titleLarge)
                    ?.copyWith(height: 1.25),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 5.0;
    const gap = 4.0;
    final y = size.height / 2;
    var x = 6.0;
    while (x < size.width - 14) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dash, size.width - 14), y),
        paint,
      );
      x += dash + gap;
    }
    canvas.drawLine(
      Offset(size.width - 19, y - 6),
      Offset(size.width - 12, y),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 19, y + 6),
      Offset(size.width - 12, y),
      paint,
    );
    canvas.drawCircle(Offset(6, y), 3, paint);
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _VerticalConnectorPainter extends CustomPainter {
  const _VerticalConnectorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 5.0;
    const gap = 4.0;
    final x = size.width / 2;
    var y = 5.0;
    while (y < size.height - 13) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, math.min(y + dash, size.height - 13)),
        paint,
      );
      y += dash + gap;
    }
    canvas.drawLine(
      Offset(x - 6, size.height - 19),
      Offset(x, size.height - 12),
      paint,
    );
    canvas.drawLine(
      Offset(x + 6, size.height - 19),
      Offset(x, size.height - 12),
      paint,
    );
    canvas.drawCircle(Offset(x, 5), 3, paint);
  }

  @override
  bool shouldRepaint(covariant _VerticalConnectorPainter oldDelegate) =>
      oldDelegate.color != color;
}
