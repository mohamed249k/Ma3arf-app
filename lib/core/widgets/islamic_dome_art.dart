import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicDomeArt extends StatefulWidget {
  final double width;
  final double height;
  final bool animate;

  const IslamicDomeArt({
    super.key,
    this.width = 160,
    this.height = 120,
    this.animate = true,
  });

  @override
  State<IslamicDomeArt> createState() => _IslamicDomeArtState();
}

class _IslamicDomeArtState extends State<IslamicDomeArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _DomePainter(
          primaryColor: theme.colorScheme.primary,
          goldColor: const Color(0xFFD7B56D),
          isDark: isDark,
        ),
      ),
    );
  }
}

class _DomePainter extends CustomPainter {
  final Color primaryColor;
  final Color goldColor;
  final bool isDark;

  _DomePainter({
    required this.primaryColor,
    required this.goldColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 200.0;
    final sy = size.height / 150.0;

    canvas.save();
    canvas.scale(sx, sy);

    final path = Path();
    path.moveTo(100, 10);
    path.cubicTo(150, 40, 180, 80, 180, 150);
    path.lineTo(20, 150);
    path.cubicTo(20, 80, 50, 40, 100, 10);
    path.close();

    // Fill glow
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, glowPaint);

    // Dashed or smooth golden contour line
    final strokePaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw dashed path
    _drawDashedPath(canvas, path, strokePaint, 6.0, 4.0);

    // Crescent finial at apex (x=100, y=10)
    final finialPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(100, 10), 4.0, finialPaint);

    // Spire
    final spirePath = Path();
    spirePath.moveTo(98, 10);
    spirePath.lineTo(102, 10);
    spirePath.lineTo(100, 2);
    spirePath.close();
    canvas.drawPath(spirePath, finialPaint);

    // Mini Crescent at tip
    final cresPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      const Rect.fromLTWH(97, -3, 6, 6),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      cresPaint,
    );

    canvas.restore();
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(dashWidth, metric.length - distance);
        canvas.drawPath(metric.extractPath(distance, distance + length), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DomePainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.goldColor != goldColor ||
        oldDelegate.isDark != isDark;
  }
}
