import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/typography.dart';
import '../foundation/icons.dart';

enum StepperOrientation { horizontal, vertical }

enum StepperLineStyle { solid, dashed }

enum StepperLinePlacement { center, bottom }

class Ux4gStepItem {
  final String title;
  final String? description;
  final String? statusLabel;
  final bool isError;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? statusStyle;

  const Ux4gStepItem({
    required this.title,
    this.description,
    this.statusLabel,
    this.isError = false,
    this.titleStyle,
    this.descriptionStyle,
    this.statusStyle,
  });
}

class Ux4gStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final StepperOrientation orientation;
  final StepperLineStyle lineStyle;
  final StepperLinePlacement linePlacement;
  final List<Ux4gStepItem> steps;
  final double stepSize;
  final bool showLabels;
  final bool edgeLabelAlignment;
  final bool activeStepBackground;
  final double stepSpacing;
  final bool alignIconWithDescription;

  const Ux4gStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.orientation = StepperOrientation.horizontal,
    this.lineStyle = StepperLineStyle.solid,
    this.linePlacement = StepperLinePlacement.center,
    this.steps = const [],
    this.stepSize = 32,
    this.showLabels = true,
    this.edgeLabelAlignment = false,
    this.activeStepBackground = false,
    this.stepSpacing = 24.0,
    this.alignIconWithDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    if (orientation == StepperOrientation.horizontal) {
      return _HorizontalStepper(
        totalSteps: totalSteps,
        currentStep: currentStep,
        lineStyle: lineStyle,
        linePlacement: linePlacement,
        steps: steps,
        stepSize: stepSize,
        showLabels: showLabels,
        edgeLabelAlignment: edgeLabelAlignment,
        activeStepBackground: activeStepBackground,
      );
    }

    return _VerticalStepper(
      totalSteps: totalSteps,
      currentStep: currentStep,
      lineStyle: lineStyle,
      steps: steps,
      stepSize: stepSize,
      showLabels: showLabels,
      stepSpacing: stepSpacing,
      alignIconWithDescription: alignIconWithDescription,
    );
  }
}

class _HorizontalStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final StepperLineStyle lineStyle;
  final StepperLinePlacement linePlacement;
  final List<Ux4gStepItem> steps;
  final double stepSize;
  final bool showLabels;
  final bool edgeLabelAlignment;
  final bool activeStepBackground;

  const _HorizontalStepper({
    required this.totalSteps,
    required this.currentStep,
    required this.lineStyle,
    required this.linePlacement,
    required this.steps,
    required this.stepSize,
    required this.showLabels,
    required this.edgeLabelAlignment,
    required this.activeStepBackground,
  });

  @override
  Widget build(BuildContext context) {
    if (linePlacement == StepperLinePlacement.bottom) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(totalSteps, (i) {
          final stepIndex = i + 1;
          final isCompleted = currentStep > stepIndex;
          final isActive = currentStep == stepIndex;
          final isPending = currentStep < stepIndex;
          final stepData = i < steps.length ? steps[i] : null;

          final showActiveBg = activeStepBackground && isActive;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bgColor = showActiveBg
              ? (isDark ? Ux4gColors.primary900 : Ux4gColors.primary50)
              : Colors.transparent;

          return Expanded(
            child: Container(
              color: bgColor,
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: stepSize,
                    height: stepSize,
                    child: Center(
                      child: _StepIcon(
                        stepIndex: stepIndex,
                        isCompleted: isCompleted,
                        isActive: isActive,
                        isPending: isPending,
                        isError: stepData?.isError ?? false,
                        size: stepSize,
                      ),
                    ),
                  ),
                  if (showLabels) ...[
                    const SizedBox(height: 8),
                    _StepLabels(
                      title: stepData?.title ?? 'Step $stepIndex',
                      description: stepData?.description,
                      statusLabel: stepData?.statusLabel,
                      isCompleted: isCompleted,
                      isActive: isActive,
                      isPending: isPending,
                      isError: stepData?.isError ?? false,
                      textAlign: TextAlign.center,
                      titleStyle: stepData?.titleStyle,
                      descriptionStyle: stepData?.descriptionStyle,
                      statusStyle: stepData?.statusStyle,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 0 : 4.0,
                      right: i == totalSteps - 1 ? 0 : 4.0,
                    ),
                    child: _StepperLine(
                      isCompleted: isCompleted,
                      orientation: StepperOrientation.horizontal,
                      lineStyle: lineStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: stepSize / 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(totalSteps, (i) {
              return Expanded(
                child: Row(
                  children: [
                    if (edgeLabelAlignment && i == 0)
                      SizedBox(width: stepSize)
                    else if (i == 0)
                      const Expanded(child: SizedBox())
                    else
                      Expanded(
                        child: _StepperLine(
                          isCompleted: currentStep > i,
                          orientation: StepperOrientation.horizontal,
                          lineStyle: lineStyle,
                        ),
                      ),
                    if (!(edgeLabelAlignment && i == 0) &&
                        !(edgeLabelAlignment && i == totalSteps - 1))
                      SizedBox(width: stepSize),
                    if (edgeLabelAlignment && i == totalSteps - 1)
                      SizedBox(width: stepSize)
                    else if (i == totalSteps - 1)
                      const Expanded(child: SizedBox())
                    else
                      Expanded(
                        child: _StepperLine(
                          isCompleted: currentStep > i + 1,
                          orientation: StepperOrientation.horizontal,
                          lineStyle: lineStyle,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(totalSteps, (i) {
            final stepIndex = i + 1;
            final isCompleted = currentStep > stepIndex;
            final isActive = currentStep == stepIndex;
            final isPending = currentStep < stepIndex;
            final stepData = i < steps.length ? steps[i] : null;

            TextAlign textAlign = TextAlign.center;
            CrossAxisAlignment columnAlignment = CrossAxisAlignment.center;
            if (edgeLabelAlignment) {
              if (i == 0) {
                textAlign = TextAlign.left;
                columnAlignment = CrossAxisAlignment.start;
              }
              if (i == totalSteps - 1) {
                textAlign = TextAlign.right;
                columnAlignment = CrossAxisAlignment.end;
              }
            }

            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: columnAlignment,
                children: [
                  SizedBox(
                    width: stepSize,
                    height: stepSize,
                    child: Center(
                      child: _StepIcon(
                        stepIndex: stepIndex,
                        isCompleted: isCompleted,
                        isActive: isActive,
                        isPending: isPending,
                        isError: stepData?.isError ?? false,
                        size: stepSize,
                      ),
                    ),
                  ),
                  if (showLabels) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _StepLabels(
                        title: stepData?.title ?? 'Step $stepIndex',
                        description: stepData?.description,
                        statusLabel: stepData?.statusLabel,
                        isCompleted: isCompleted,
                        isActive: isActive,
                        isPending: isPending,
                        isError: stepData?.isError ?? false,
                        textAlign: textAlign,
                        titleStyle: stepData?.titleStyle,
                        descriptionStyle: stepData?.descriptionStyle,
                        statusStyle: stepData?.statusStyle,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _VerticalStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final StepperLineStyle lineStyle;
  final List<Ux4gStepItem> steps;
  final double stepSize;
  final bool showLabels;
  final double stepSpacing;
  final bool alignIconWithDescription;

  const _VerticalStepper({
    required this.totalSteps,
    required this.currentStep,
    required this.lineStyle,
    required this.steps,
    required this.stepSize,
    required this.showLabels,
    required this.stepSpacing,
    required this.alignIconWithDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(totalSteps, (i) {
        final stepIndex = i + 1;
        final isCompleted = currentStep > stepIndex;
        final isActive = currentStep == stepIndex;
        final isPending = currentStep < stepIndex;
        final stepData = i < steps.length ? steps[i] : null;

        return IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: stepSize,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (alignIconWithDescription &&
                        stepData != null &&
                        stepData.title.isNotEmpty)
                      SizedBox(
                        height: 28,
                        child: i > 0
                            ? _StepperLine(
                                isCompleted: currentStep > i,
                                orientation: StepperOrientation.vertical,
                                lineStyle: lineStyle,
                              )
                            : null,
                      ),
                    _StepIcon(
                      stepIndex: stepIndex,
                      isCompleted: isCompleted,
                      isActive: isActive,
                      isPending: isPending,
                      isError: stepData?.isError ?? false,
                      size: stepSize,
                    ),
                    if (i < totalSteps - 1)
                      if (showLabels)
                        Expanded(
                          child: _StepperLine(
                            isCompleted: isCompleted,
                            orientation: StepperOrientation.vertical,
                            lineStyle: lineStyle,
                          ),
                        )
                      else
                        SizedBox(
                          height: stepSpacing,
                          child: _StepperLine(
                            isCompleted: isCompleted,
                            orientation: StepperOrientation.vertical,
                            lineStyle: lineStyle,
                          ),
                        ),
                  ],
                ),
              ),
              if (showLabels) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 4,
                      bottom: i < totalSteps - 1 ? stepSpacing : 0,
                    ),
                    child: _StepLabels(
                      title: stepData?.title ?? 'Step $stepIndex',
                      description: stepData?.description,
                      statusLabel: stepData?.statusLabel,
                      isCompleted: isCompleted,
                      isActive: isActive,
                      isPending: isPending,
                      isError: stepData?.isError ?? false,
                      textAlign: TextAlign.start,
                      titleStyle: stepData?.titleStyle,
                      descriptionStyle: stepData?.descriptionStyle,
                      statusStyle: stepData?.statusStyle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _StepIcon extends StatelessWidget {
  final int stepIndex;
  final bool isCompleted;
  final bool isActive;
  final bool isPending;
  final bool isError;
  final double size;

  const _StepIcon({
    required this.stepIndex,
    required this.isCompleted,
    required this.isActive,
    required this.isPending,
    required this.isError,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onPrimary =
        ux4gColors?.onPrimary ?? materialTheme.colorScheme.onPrimary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;
    final error = ux4gColors?.error ?? materialTheme.colorScheme.error;

    final backgroundColor = isError
        ? Colors.transparent
        : isCompleted
        ? primary
        : Colors.transparent;
    final borderColor = isError
        ? error
        : isCompleted || isActive
        ? primary
        : onSurface.withValues(alpha: 0.2);

    final iconSize = size * 0.625;

    Widget child;
    if (isError) {
      child = Icon(Ux4gIcons.error, size: iconSize, color: error);
    } else if (isCompleted) {
      child = Icon(Ux4gIcons.check, size: iconSize, color: onPrimary);
    } else if (isActive) {
      child = Container(
        width: size * 0.375,
        height: size * 0.375,
        decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
      );
    } else {
      child = Text(
        '$stepIndex',
        style:
            (ux4gTypography?.lM_default ?? materialTheme.textTheme.labelMedium)
                ?.copyWith(
                  color: onSurface.withValues(alpha: 0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.375,
                ),
      );
    }

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: backgroundColor),
      duration: const Duration(milliseconds: 300),
      builder: (context, animatedBackground, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: animatedBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: isActive || isPending ? 2 : 0,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}

class _StepLabels extends StatelessWidget {
  final String title;
  final String? description;
  final String? statusLabel;
  final bool isCompleted;
  final bool isActive;
  final bool isPending;
  final bool isError;
  final TextAlign textAlign;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? statusStyle;

  const _StepLabels({
    required this.title,
    this.description,
    this.statusLabel,
    required this.isCompleted,
    required this.isActive,
    required this.isPending,
    required this.isError,
    required this.textAlign,
    this.titleStyle,
    this.descriptionStyle,
    this.statusStyle,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;
    final error = ux4gColors?.error ?? materialTheme.colorScheme.error;
    final success = ux4gColors?.success ?? Colors.green;

    final titleColor = isError
        ? error
        : isPending
        ? onSurface.withValues(alpha: 0.4)
        : onSurface;
    final resolvedDescriptionColor = isError
        ? error
        : onSurface.withValues(alpha: 0.4);
    final resolvedStatus = statusLabel;
    final statusColor = isError
        ? error
        : isCompleted
        ? success
        : isActive
        ? primary
        : onSurface.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : (textAlign == TextAlign.right
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start),
      children: [
        Text(
          title,
          style:
              (titleStyle ??
                      ux4gTypography?.lL_strong ??
                      materialTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ))
                  ?.copyWith(color: titleStyle?.color ?? titleColor),
          textAlign: textAlign,
        ),
        if (description != null)
          Text(
            description!,
            style:
                (descriptionStyle ??
                        ux4gTypography?.lM_default ??
                        materialTheme.textTheme.labelMedium)
                    ?.copyWith(
                      color:
                          descriptionStyle?.color ?? resolvedDescriptionColor,
                    ),
            textAlign: textAlign,
          ),
        if (resolvedStatus != null)
          Text(
            resolvedStatus,
            style:
                (statusStyle ??
                        ux4gTypography?.lS_strong ??
                        materialTheme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ))
                    ?.copyWith(color: statusStyle?.color ?? statusColor),
            textAlign: textAlign,
          ),
      ],
    );
  }
}

class _StepperLine extends StatelessWidget {
  final bool isCompleted;
  final StepperOrientation orientation;
  final StepperLineStyle lineStyle;

  const _StepperLine({
    required this.isCompleted,
    required this.orientation,
    required this.lineStyle,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;

    final targetColor = isCompleted
        ? primary
        : onSurface.withValues(alpha: 0.2);

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: targetColor),
      duration: const Duration(milliseconds: 500),
      builder: (context, animatedColor, _) {
        return CustomPaint(
          painter: _LinePainter(
            color: animatedColor ?? targetColor,
            isDashed: lineStyle == StepperLineStyle.dashed,
            isHorizontal: orientation == StepperOrientation.horizontal,
          ),
          child: SizedBox(
            height: orientation == StepperOrientation.horizontal
                ? 2
                : double.infinity,
            width: orientation == StepperOrientation.vertical
                ? 2
                : double.infinity,
          ),
        );
      },
    );
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  final bool isDashed;
  final bool isHorizontal;

  const _LinePainter({
    required this.color,
    required this.isDashed,
    required this.isHorizontal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final start = isHorizontal
        ? Offset(0, size.height / 2)
        : Offset(size.width / 2, 0);
    final end = isHorizontal
        ? Offset(size.width, size.height / 2)
        : Offset(size.width / 2, size.height);

    if (!isDashed) {
      canvas.drawLine(start, end, paint);
      return;
    }

    const dashWidth = 12.0;
    const dashSpace = 8.0;
    final distance = (end - start).distance;
    final direction = (end - start) / distance;

    double currentDistance = 0;
    while (currentDistance < distance) {
      final nextDistance = (currentDistance + dashWidth)
          .clamp(0, distance)
          .toDouble();
      canvas.drawLine(
        start + direction * currentDistance,
        start + direction * nextDistance,
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return color != oldDelegate.color ||
        isDashed != oldDelegate.isDashed ||
        isHorizontal != oldDelegate.isHorizontal;
  }
}

enum Ux4gCompactStepperLayout { linear, rightAligned, centered, centeredBetween, split }

@Deprecated('Use Ux4gCompactStepperLayout instead')
typedef Ux4gCapsuleStepperLayout = Ux4gCompactStepperLayout;

@Deprecated('Use Ux4gCompactStepper instead')
typedef Ux4gCapsuleStepper = Ux4gCompactStepper;

class Ux4gCompactStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final String stepLabel;
  final String? description;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Ux4gCompactStepperLayout layout;
  final CrossAxisAlignment labelAlignment;
  final Color? activeColor;
  final Color? inactiveColor;

  const Ux4gCompactStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabel,
    this.description,
    this.onNext = _noop,
    this.onPrevious = _noop,
    this.layout = Ux4gCompactStepperLayout.linear,
    this.labelAlignment = CrossAxisAlignment.start,
    this.activeColor,
    this.inactiveColor,
  });

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;

    final resolvedActiveColor = activeColor ?? primary;
    final resolvedInactiveColor =
        inactiveColor ?? onSurface.withValues(alpha: 0.2);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (layout == Ux4gCompactStepperLayout.linear)
            _LinearCapsuleStepper(
              totalSteps: totalSteps,
              currentStep: currentStep,
              stepLabel: stepLabel,
              description: description,
              onNext: onNext,
              onPrevious: onPrevious,
              labelAlignment: labelAlignment,
              activeColor: resolvedActiveColor,
              inactiveColor: resolvedInactiveColor,
            )
          else if (layout == Ux4gCompactStepperLayout.rightAligned)
            _RightAlignedCapsuleStepper(
              totalSteps: totalSteps,
              currentStep: currentStep,
              stepLabel: stepLabel,
              description: description,
              onNext: onNext,
              onPrevious: onPrevious,
              activeColor: resolvedActiveColor,
              inactiveColor: resolvedInactiveColor,
            )
          else if (layout == Ux4gCompactStepperLayout.centered)
            _CenteredCapsuleStepper(
              totalSteps: totalSteps,
              currentStep: currentStep,
              stepLabel: stepLabel,
              description: description,
              onNext: onNext,
              onPrevious: onPrevious,
              activeColor: resolvedActiveColor,
              inactiveColor: resolvedInactiveColor,
            )
          else if (layout == Ux4gCompactStepperLayout.centeredBetween)
            _CenteredBetweenCapsuleStepper(
              totalSteps: totalSteps,
              currentStep: currentStep,
              stepLabel: stepLabel,
              description: description,
              onNext: onNext,
              onPrevious: onPrevious,
              activeColor: resolvedActiveColor,
              inactiveColor: resolvedInactiveColor,
            )
          else
            _SplitCapsuleStepper(
              totalSteps: totalSteps,
              currentStep: currentStep,
              stepLabel: stepLabel,
              description: description,
              onNext: onNext,
              onPrevious: onPrevious,
              activeColor: resolvedActiveColor,
              inactiveColor: resolvedInactiveColor,
            ),
        ],
      ),
    );
  }
}

class _CapsuleIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final MainAxisSize mainAxisSize;
  final bool shrinkToFit;

  const _CapsuleIndicator({
    required this.totalSteps,
    required this.currentStep,
    required this.activeColor,
    required this.inactiveColor,
    this.mainAxisSize = MainAxisSize.min,
    this.shrinkToFit = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisSize == MainAxisSize.max 
          ? MainAxisAlignment.spaceBetween 
          : MainAxisAlignment.start,
      children: List.generate(totalSteps, (i) {
        final isActive = i + 1 == currentStep;

        return Padding(
          padding: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 8),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: isActive ? 32 : 16),
            duration: const Duration(milliseconds: 300),
            builder: (context, width, _) {
              return TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: isActive ? activeColor : inactiveColor),
                duration: const Duration(milliseconds: 300),
                builder: (context, color, child) {
                  return Container(
                    width: width,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
    );

    if (!shrinkToFit) {
      return row;
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: row,
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onClick;

  const _StepperIconButton({
    required this.icon,
    required this.enabled,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;
    final surface = ux4gColors?.surface ?? materialTheme.colorScheme.surface;

    final contentColor = enabled ? primary : onSurface.withValues(alpha: 0.3);
    final borderColor = enabled
        ? primary.withValues(alpha: 0.12)
        : onSurface.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: enabled ? onClick : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: surface,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: contentColor),
      ),
    );
  }
}

class _LinearCapsuleStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final String stepLabel;
  final String? description;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final CrossAxisAlignment labelAlignment;
  final Color activeColor;
  final Color inactiveColor;

  const _LinearCapsuleStepper({
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabel,
    required this.description,
    required this.onNext,
    required this.onPrevious,
    required this.labelAlignment,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;

    final centered = labelAlignment == CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StepperIconButton(
              icon: Ux4gIcons.arrowLeft,
              enabled: currentStep > 1,
              onClick: onPrevious,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Center(
                child: _CapsuleIndicator(
                  totalSteps: totalSteps,
                  currentStep: currentStep,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  shrinkToFit: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _StepperIconButton(
              icon: Ux4gIcons.arrowRight,
              enabled: currentStep < totalSteps,
              onClick: onNext,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: labelAlignment,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style:
                  (ux4gTypography?.lM_strong ??
                          materialTheme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ))
                      ?.copyWith(color: onSurface),
              textAlign: centered ? TextAlign.center : TextAlign.start,
            ),
            Text(
              stepLabel,
              style:
                  (ux4gTypography?.lL_strong ??
                          materialTheme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ))
                      ?.copyWith(color: primary),
              textAlign: centered ? TextAlign.center : TextAlign.start,
            ),
            if (description != null)
              Text(
                description!,
                style:
                    (ux4gTypography?.lM_default ??
                            materialTheme.textTheme.labelMedium)
                        ?.copyWith(color: onSurface.withValues(alpha: 0.5)),
                textAlign: centered ? TextAlign.center : TextAlign.start,
              ),
          ],
        ),
      ],
    );
  }
}

class _RightAlignedCapsuleStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final String stepLabel;
  final String? description;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Color activeColor;
  final Color inactiveColor;

  const _RightAlignedCapsuleStepper({
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabel,
    required this.description,
    required this.onNext,
    required this.onPrevious,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StepperIconButton(
              icon: Ux4gIcons.arrowLeft,
              enabled: currentStep > 1,
              onClick: onPrevious,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Center(
                child: _CapsuleIndicator(
                  totalSteps: totalSteps,
                  currentStep: currentStep,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  shrinkToFit: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _StepperIconButton(
              icon: Ux4gIcons.arrowRight,
              enabled: currentStep < totalSteps,
              onClick: onNext,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style:
                  (ux4gTypography?.lM_strong ??
                          materialTheme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ))
                      ?.copyWith(color: onSurface),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stepLabel,
                  style:
                      (ux4gTypography?.lL_strong ??
                              materialTheme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ))
                          ?.copyWith(color: primary),
                ),
                if (description != null)
                  Text(
                    description!,
                    style:
                        (ux4gTypography?.lM_default ??
                                materialTheme.textTheme.labelMedium)
                            ?.copyWith(color: onSurface.withValues(alpha: 0.5)),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CenteredCapsuleStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final String stepLabel;
  final String? description;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Color activeColor;
  final Color inactiveColor;

  const _CenteredCapsuleStepper({
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabel,
    required this.description,
    required this.onNext,
    required this.onPrevious,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;

    return Column(
      children: [
        _CapsuleIndicator(
          totalSteps: totalSteps,
          currentStep: currentStep,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          mainAxisSize: MainAxisSize.max,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepperIconButton(
              icon: Ux4gIcons.arrowLeft,
              enabled: currentStep > 1,
              onClick: onPrevious,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Step $currentStep of $totalSteps',
                style:
                    (ux4gTypography?.lM_strong ??
                            materialTheme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ))
                        ?.copyWith(color: onSurface),
              ),
            ),
            _StepperIconButton(
              icon: Ux4gIcons.arrowRight,
              enabled: currentStep < totalSteps,
              onClick: onNext,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          stepLabel,
          style:
              (ux4gTypography?.lL_strong ??
                      materialTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ))
                  ?.copyWith(color: primary),
          textAlign: TextAlign.center,
        ),
        if (description != null)
          Text(
            description!,
            style:
                (ux4gTypography?.lM_default ??
                        materialTheme.textTheme.labelMedium)
                    ?.copyWith(color: onSurface.withValues(alpha: 0.5)),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class _CenteredBetweenCapsuleStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final String stepLabel;
  final String? description;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Color activeColor;
  final Color inactiveColor;

  const _CenteredBetweenCapsuleStepper({
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabel,
    required this.description,
    required this.onNext,
    required this.onPrevious,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;

    return Column(
      children: [
        _CapsuleIndicator(
          totalSteps: totalSteps,
          currentStep: currentStep,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          mainAxisSize: MainAxisSize.max,
        ),
        const SizedBox(height: 16),
        Text(
          'Step $currentStep of $totalSteps',
          style:
              (ux4gTypography?.lM_strong ??
                      materialTheme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ))
                  ?.copyWith(color: onSurface),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _StepperIconButton(
              icon: Ux4gIcons.arrowLeft,
              enabled: currentStep > 1,
              onClick: onPrevious,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stepLabel,
                    style:
                        (ux4gTypography?.lL_strong ??
                                materialTheme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ))
                            ?.copyWith(color: primary),
                    textAlign: TextAlign.center,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style:
                          (ux4gTypography?.lM_default ??
                                  materialTheme.textTheme.labelMedium)
                              ?.copyWith(color: onSurface.withValues(alpha: 0.5)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            _StepperIconButton(
              icon: Ux4gIcons.arrowRight,
              enabled: currentStep < totalSteps,
              onClick: onNext,
            ),
          ],
        ),
      ],
    );
  }
}

class _SplitCapsuleStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final String stepLabel;
  final String? description;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Color activeColor;
  final Color inactiveColor;

  const _SplitCapsuleStepper({
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabel,
    required this.description,
    required this.onNext,
    required this.onPrevious,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final ux4gColors = materialTheme.extension<Ux4gThemeColors>();
    final ux4gTypography = materialTheme.extension<Ux4gTypography>();

    final primary = ux4gColors?.primary ?? materialTheme.colorScheme.primary;
    final onSurface =
        ux4gColors?.onSurface ?? materialTheme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CapsuleIndicator(
          totalSteps: totalSteps,
          currentStep: currentStep,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          mainAxisSize: MainAxisSize.max,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stepLabel,
                    style:
                        (ux4gTypography?.lL_strong ??
                                materialTheme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ))
                            ?.copyWith(color: primary),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style:
                          (ux4gTypography?.lM_default ??
                                  materialTheme.textTheme.labelMedium)
                              ?.copyWith(color: onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Step $currentStep of $totalSteps',
                  style:
                      (ux4gTypography?.lM_strong ??
                              materialTheme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ))
                          ?.copyWith(color: onSurface),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepperIconButton(
                      icon: Ux4gIcons.arrowLeft,
                      enabled: currentStep > 1,
                      onClick: onPrevious,
                    ),
                    const SizedBox(width: 8),
                    _StepperIconButton(
                      icon: Ux4gIcons.arrowRight,
                      enabled: currentStep < totalSteps,
                      onClick: onNext,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
