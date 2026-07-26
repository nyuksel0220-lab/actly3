import 'package:actly/core/design/actly_colors.dart';
import 'package:flutter/material.dart';

class BlueprintScaffold extends StatelessWidget {
  const BlueprintScaffold({
    required this.body,
    super.key,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(child: CustomPaint(painter: _GridPainter())),
          SafeArea(child: body),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = ActlyColors.gridLine.withValues(alpha: 0.18)
      ..strokeWidth = 0.6;
    final major = Paint()
      ..color = ActlyColors.gridLine.withValues(alpha: 0.32)
      ..strokeWidth = 0.8;

    const spacing = 20.0;
    for (double x = 0; x <= size.width; x += spacing) {
      final paint = (x % 100 == 0) ? major : minor;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      final paint = (y % 100 == 0) ? major : minor;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
