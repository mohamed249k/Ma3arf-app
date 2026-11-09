import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-screen or sectional authentic Islamic geometric background.
/// Renders a traditional 8-point Islamic star tessellation (Khatam / Rub el Hizb)
/// with interlocking polygons and connecting diamond stars.
class IslamicGeometricBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Color? patternColor;
  final bool showVignette;

  const IslamicGeometricBackground({
    super.key,
    required this.child,
    this.opacity = 0.045,
    this.patternColor,
    this.showVignette = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor =
        patternColor ??
        (isDark ? const Color(0xFFD7B56D) : const Color(0xFF0B6623));
    final effectiveOpacity = isDark ? opacity : opacity * 0.7;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _IslamicTessellationPainter(
                  color: baseColor.withValues(alpha: effectiveOpacity),
                  tileSize: 90.0,
                ),
              ),
            ),
          ),
        ),
        if (showVignette)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.3,
                    colors: [
                      Colors.transparent,
                      (isDark
                              ? const Color(0xFF0B1512)
                              : const Color(0xFFFDFBF7))
                          .withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}

/// Lightweight CustomPainter rendering an authentic Islamic 8-pointed star tessellation.
class _IslamicTessellationPainter extends CustomPainter {
  final Color color;
  final double tileSize;

  _IslamicTessellationPainter({required this.color, required this.tileSize});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cols = (size.width / tileSize).ceil() + 1;
    final rows = (size.height / tileSize).ceil() + 1;

    final starRadius = tileSize * 0.28;
    final innerRadius = tileSize * 0.16;

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        final cx = i * tileSize;
        final cy = j * tileSize;
        final center = Offset(cx, cy);

        // 1. Draw 8-point Islamic star (two rotated squares at 45 degrees)
        _drawEightPointStar(canvas, center, starRadius, strokePaint);

        // 2. Draw inner rosette
        _drawEightPointStar(canvas, center, innerRadius, strokePaint);

        // 3. Connect corner points to adjacent tile points (interlocking geometry)
        canvas.drawCircle(center, tileSize * 0.04, strokePaint);

        // 4. Interlaced diamond between 4 adjacent star centers
        final midX = cx + tileSize / 2;
        final midY = cy + tileSize / 2;
        if (midX < size.width + tileSize && midY < size.height + tileSize) {
          _drawDiamondOrnament(
            canvas,
            Offset(midX, midY),
            tileSize * 0.14,
            strokePaint,
          );
        }
      }
    }
  }

  void _drawEightPointStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    // Square 1: aligned at 0 deg
    _drawSquare(canvas, center, radius, 0, paint);
    // Square 2: rotated at 45 deg (pi / 4)
    _drawSquare(canvas, center, radius, math.pi / 4, paint);
  }

  void _drawSquare(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = angle + i * (math.pi / 2);
      final x = center.dx + radius * math.cos(a);
      final y = center.dy + radius * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamondOrnament(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();
    canvas.drawPath(path, paint);

    // Inner diamond cross
    canvas.drawLine(
      Offset(center.dx, center.dy - size * 0.5),
      Offset(center.dx, center.dy + size * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - size * 0.5, center.dy),
      Offset(center.dx + size * 0.5, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _IslamicTessellationPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.tileSize != tileSize;
}

/// Draws an authentic ornamental 8-point Islamic star pattern as a decorative watermark or header ornament.
class IslamicStarPattern extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const IslamicStarPattern({
    super.key,
    this.size = 120,
    required this.color,
    this.opacity = 0.09,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(size, size),
        painter: _IslamicStarPainter(color: color),
      ),
    );
  }
}

class _IslamicStarPainter extends CustomPainter {
  final Color color;

  _IslamicStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer concentric decorative rings
    canvas.drawCircle(center, radius * 0.95, paint);
    canvas.drawCircle(center, radius * 0.82, paint);

    // Draw 8-point star (two overlapping rotated squares)
    final squarePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    _drawRotatedSquare(canvas, center, radius * 0.72, 0, squarePaint);
    _drawRotatedSquare(canvas, center, radius * 0.72, math.pi / 4, squarePaint);

    // Draw inner 8-point star
    _drawRotatedSquare(canvas, center, radius * 0.46, math.pi / 8, paint);
    _drawRotatedSquare(canvas, center, radius * 0.46, 3 * math.pi / 8, paint);

    // Center circular ornament with delicate fill
    canvas.drawCircle(center, radius * 0.22, paint);
    final centerFill = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.16, centerFill);
  }

  void _drawRotatedSquare(
    Canvas canvas,
    Offset center,
    double r,
    double angle,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = angle + i * (math.pi / 2);
      final x = center.dx + r * math.cos(a);
      final y = center.dy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicStarPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// An ornamental Islamic divider with centered 8-pointed star rosette and flourishing gold-tinted lines.
class IslamicDivider extends StatelessWidget {
  final Color? color;
  final double height;

  const IslamicDivider({super.key, this.color, this.height = 24});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.secondary;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    effectiveColor.withValues(alpha: 0.0),
                    effectiveColor.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CustomPaint(
                painter: _MiniIslamicStarPainter(color: effectiveColor),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1.2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    effectiveColor.withValues(alpha: 0.5),
                    effectiveColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniIslamicStarPainter extends CustomPainter {
  final Color color;

  _MiniIslamicStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Mini 8-pointed star
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final outerAngle = i * (math.pi / 4);
      final innerAngle = outerAngle + (math.pi / 8);
      final ox = center.dx + r * math.cos(outerAngle);
      final oy = center.dy + r * math.sin(outerAngle);
      final ix = center.dx + (r * 0.5) * math.cos(innerAngle);
      final iy = center.dy + (r * 0.5) * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniIslamicStarPainter oldDelegate) =>
      oldDelegate.color != color;
}
