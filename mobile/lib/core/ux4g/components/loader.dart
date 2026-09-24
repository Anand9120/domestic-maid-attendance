import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../foundation/colors.dart';
import '../theme/theme.dart';

@Deprecated('Use Ux4gSpinner instead')
typedef Ux4gLoader = Ux4gSpinner;

/// UX4G Standard Spinner Sizes
enum Ux4gSpinnerSize {
  small(16, 2.0),
  medium(24, 2.5),
  large(36, 3.2),
  extraLarge(48, 4.0);

  final double dimension;
  final double strokeWidth;
  const Ux4gSpinnerSize(this.dimension, this.strokeWidth);
}

/// Official UX4G Circular Loading Spinner Component
/// Complies with Government of India UX4G design standard & GIGW 3.0 accessibility.
class Ux4gSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  final List<Color>? gradientColors;
  final double percentage; // 0 to 100 sweep
  final double? strokeWidth;
  final int rotationDurationMillis;
  final String? semanticLabel;

  const Ux4gSpinner({
    super.key,
    this.size = 36,
    this.color,
    this.gradientColors,
    this.percentage = 78,
    this.strokeWidth,
    this.rotationDurationMillis = 1100,
    this.semanticLabel,
  });

  /// 16px Small Spinner (Buttons, tags, inline indicators)
  const Ux4gSpinner.small({
    super.key,
    this.color,
    this.gradientColors,
    this.percentage = 78,
    this.rotationDurationMillis = 1100,
    this.semanticLabel,
  })  : size = 16,
        strokeWidth = 2.0;

  /// 24px Medium Spinner (Input fields, list items, card headers)
  const Ux4gSpinner.medium({
    super.key,
    this.color,
    this.gradientColors,
    this.percentage = 78,
    this.rotationDurationMillis = 1100,
    this.semanticLabel,
  })  : size = 24,
        strokeWidth = 2.5;

  /// 36px Large Spinner (Cards, dialogs, sections)
  const Ux4gSpinner.large({
    super.key,
    this.color,
    this.gradientColors,
    this.percentage = 78,
    this.rotationDurationMillis = 1100,
    this.semanticLabel,
  })  : size = 36,
        strokeWidth = 3.2;

  /// 48px Extra-Large Spinner (Full-screen loaders, dashboard initial sync)
  const Ux4gSpinner.extraLarge({
    super.key,
    this.color,
    this.gradientColors,
    this.percentage = 78,
    this.rotationDurationMillis = 1100,
    this.semanticLabel,
  })  : size = 48,
        strokeWidth = 4.0;

  @override
  State<Ux4gSpinner> createState() => _Ux4gSpinnerState();
}

class _Ux4gSpinnerState extends State<Ux4gSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.rotationDurationMillis),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? (Ux4gTheme.colors(context).primary == lightUx4gColors.primary
            ? darkUx4gColors.primary
            : Ux4gTheme.colors(context).primary)
        : Ux4gTheme.colors(context).primary;
    final color = widget.color ?? defaultColor;
    final effectiveStrokeWidth =
        widget.strokeWidth ?? math.max(1.8, widget.size * 0.09);

    return Semantics(
      label:
          widget.semanticLabel ?? 'प्रतीक्षा करें... लोड हो रहा है (Loading...)',
      liveRegion: true,
      child: RotationTransition(
        turns: _controller,
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _LoaderPainter(
              color: color,
              gradientColors: widget.gradientColors,
              percentage: widget.percentage,
              strokeWidth: effectiveStrokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final Color color;
  final List<Color>? gradientColors;
  final double percentage;
  final double strokeWidth;

  _LoaderPainter({
    required this.color,
    this.gradientColors,
    required this.percentage,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Subtract strokeWidth to prevent bounding-box edge clipping
    final radius = math.max(1.0, (size.width - strokeWidth) / 2);
    final normalized = (percentage / 100).clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * normalized;

    final List<Color> sweepColors =
        (gradientColors != null && gradientColors!.length >= 2)
            ? gradientColors!
            : [color.withValues(alpha: 0.0), color];

    final List<double> stops = sweepColors.length == 2
        ? [0.0, normalized]
        : List<double>.generate(
            sweepColors.length,
            (i) => (i / (sweepColors.length - 1)) * normalized,
          );

    final paint = Paint()
      ..shader = SweepGradient(
        colors: sweepColors,
        stops: stops,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      sweepAngle,
      false,
      paint,
    );

    final capPaint = Paint()
      ..color = sweepColors.last
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final capX = center.dx + radius * math.cos(sweepAngle);
    final capY = center.dy + radius * math.sin(sweepAngle);
    canvas.drawCircle(Offset(capX, capY), strokeWidth / 2, capPaint);
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.percentage != percentage ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Official UX4G Centered Loading Indicator with optional bilingual status message
class Ux4gLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;
  final TextStyle? messageStyle;
  final double spacing;

  const Ux4gLoadingIndicator({
    super.key,
    this.size = 36,
    this.color,
    this.message,
    this.messageStyle,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Ux4gSpinner(
              size: size,
              color: color,
            ),
            if (message != null) ...[
              SizedBox(height: spacing),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: messageStyle ??
                    TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
