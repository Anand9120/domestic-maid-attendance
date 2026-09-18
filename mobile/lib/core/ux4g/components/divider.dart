import 'package:flutter/material.dart';
import '../foundation/colors.dart';

enum Ux4gDividerOrientation { horizontal, vertical }

enum Ux4gDividerStyle { solid, dashed, dotted }

class Ux4gDivider extends StatelessWidget {
  final Ux4gDividerOrientation orientation;
  final Color? color;
  final double thickness;
  final Ux4gDividerStyle style;
  final double startIndent;
  final double endIndent;
  final Widget? label;
  final double labelSpacing;
  final double? width;
  final double? height;

  const Ux4gDivider({
    super.key,
    this.orientation = Ux4gDividerOrientation.horizontal,
    this.color,
    this.thickness = 1.0,
    this.style = Ux4gDividerStyle.solid,
    this.startIndent = 0.0,
    this.endIndent = 0.0,
    this.label,
    this.labelSpacing = 8.0,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final dividerColor =
        color ??
        (ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface)
            .withValues(alpha: 0.2);

    if (label != null) {
      Widget labeledWidget;
      if (orientation == Ux4gDividerOrientation.horizontal) {
        labeledWidget = Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _Ux4gDividerLine(
                orientation: orientation,
                color: dividerColor,
                thickness: thickness,
                style: style,
                startIndent: startIndent,
                endIndent: 0,
                height: height,
              ),
            ),
            SizedBox(width: labelSpacing),
            label!,
            SizedBox(width: labelSpacing),
            Expanded(
              child: _Ux4gDividerLine(
                orientation: orientation,
                color: dividerColor,
                thickness: thickness,
                style: style,
                startIndent: 0,
                endIndent: endIndent,
                height: height,
              ),
            ),
          ],
        );
      } else {
        labeledWidget = Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _Ux4gDividerLine(
                orientation: orientation,
                color: dividerColor,
                thickness: thickness,
                style: style,
                startIndent: startIndent,
                endIndent: 0,
                width: width,
              ),
            ),
            SizedBox(height: labelSpacing),
            label!,
            SizedBox(height: labelSpacing),
            Expanded(
              child: _Ux4gDividerLine(
                orientation: orientation,
                color: dividerColor,
                thickness: thickness,
                style: style,
                startIndent: 0,
                endIndent: endIndent,
                width: width,
              ),
            ),
          ],
        );
      }
      if (width != null || height != null) {
        return SizedBox(width: width, height: height, child: labeledWidget);
      }
      return labeledWidget;
    }

    return _Ux4gDividerLine(
      orientation: orientation,
      color: dividerColor,
      thickness: thickness,
      style: style,
      startIndent: startIndent,
      endIndent: endIndent,
      width: width,
      height: height,
    );
  }
}

class _Ux4gDividerLine extends StatelessWidget {
  final Ux4gDividerOrientation orientation;
  final Color color;
  final double thickness;
  final Ux4gDividerStyle style;
  final double startIndent;
  final double endIndent;
  final double? width;
  final double? height;

  const _Ux4gDividerLine({
    required this.orientation,
    required this.color,
    required this.thickness,
    required this.style,
    required this.startIndent,
    required this.endIndent,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (orientation == Ux4gDividerOrientation.horizontal) {
      return SizedBox(
        height: height ?? thickness,
        width: width ?? double.infinity,
        child: CustomPaint(
          painter: _DividerPainter(
            orientation: orientation,
            color: color,
            thickness: thickness,
            style: style,
            startIndent: startIndent,
            endIndent: endIndent,
          ),
        ),
      );
    } else {
      return SizedBox(
        width: width ?? thickness,
        height: height ?? double.infinity,
        child: CustomPaint(
          painter: _DividerPainter(
            orientation: orientation,
            color: color,
            thickness: thickness,
            style: style,
            startIndent: startIndent,
            endIndent: endIndent,
          ),
        ),
      );
    }
  }
}

class _DividerPainter extends CustomPainter {
  final Ux4gDividerOrientation orientation;
  final Color color;
  final double thickness;
  final Ux4gDividerStyle style;
  final double startIndent;
  final double endIndent;

  _DividerPainter({
    required this.orientation,
    required this.color,
    required this.thickness,
    required this.style,
    required this.startIndent,
    required this.endIndent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    double dashWidth = 0;
    double dashSpace = 0;

    switch (style) {
      case Ux4gDividerStyle.solid:
        break;
      case Ux4gDividerStyle.dashed:
        dashWidth = 12.0;
        dashSpace = 8.0;
        break;
      case Ux4gDividerStyle.dotted:
        dashWidth = 4.0;
        dashSpace = 4.0;
        break;
    }

    if (orientation == Ux4gDividerOrientation.horizontal) {
      final y = size.height / 2;
      final startX = startIndent;
      final endX = size.width - endIndent;

      if (style == Ux4gDividerStyle.solid) {
        canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      } else {
        double currentX = startX;
        while (currentX < endX) {
          final nextX = (currentX + dashWidth).clamp(startX, endX);
          canvas.drawLine(Offset(currentX, y), Offset(nextX, y), paint);
          currentX += dashWidth + dashSpace;
        }
      }
    } else {
      final x = size.width / 2;
      final startY = startIndent;
      final endY = size.height - endIndent;

      if (style == Ux4gDividerStyle.solid) {
        canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
      } else {
        double currentY = startY;
        while (currentY < endY) {
          final nextY = (currentY + dashWidth).clamp(startY, endY);
          canvas.drawLine(Offset(x, currentY), Offset(x, nextY), paint);
          currentY += dashWidth + dashSpace;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DividerPainter oldDelegate) {
    return oldDelegate.orientation != orientation ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.style != style ||
        oldDelegate.startIndent != startIndent ||
        oldDelegate.endIndent != endIndent;
  }
}
