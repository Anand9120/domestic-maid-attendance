import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';


/// Interactive Live GPS Map & Sonar Radar Widget
///
/// Compliant with UX4G and GIGW 3.0 standards.
/// Visualizes real-time geofence boundary, live GPS device position,
/// accuracy radius bubble, animated radar sweep, and telemetry metrics.
class LiveGpsMapRadarWidget extends StatefulWidget {
  final double targetLat;
  final double targetLon;
  final String houseName;
  final double geofenceRadiusMeters;
  final Position? currentPosition;
  final double? distanceMeters;
  final bool isInsideGeofence;
  final int dwellCountdown;
  final int requiredDwellSeconds;
  final bool isContrast;
  final bool isInteractive;
  final ValueChanged<({double lat, double lon})>? onCoordinateTapped;
  final VoidCallback? onRefreshGps;

  const LiveGpsMapRadarWidget({
    super.key,
    required this.targetLat,
    required this.targetLon,
    this.houseName = 'Household Boundary',
    this.geofenceRadiusMeters = 50.0,
    this.currentPosition,
    this.distanceMeters,
    this.isInsideGeofence = false,
    this.dwellCountdown = 0,
    this.requiredDwellSeconds = 180,
    this.isContrast = false,
    this.isInteractive = false,
    this.onCoordinateTapped,
    this.onRefreshGps,
  });

  @override
  State<LiveGpsMapRadarWidget> createState() => _LiveGpsMapRadarWidgetState();
}

class _LiveGpsMapRadarWidgetState extends State<LiveGpsMapRadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDegraded = (widget.currentPosition?.accuracy ?? 0) > 40.0;
    final isVehicular = (widget.currentPosition?.speed ?? 0) > 3.0; // > 10.8 km/h
    final speedKmH = (widget.currentPosition?.speed ?? 0) * 3.6;
    final accuracy = widget.currentPosition?.accuracy;

    return Container(
      decoration: BoxDecoration(
        color: widget.isContrast ? AppColors.hcSurface : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isContrast ? AppColors.hcBorder : const Color(0xFF334155),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Status & GPS Precision Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: widget.isContrast ? Colors.black45 : const Color(0xFF1E293B),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isInsideGeofence
                          ? const Color(0xFF22C55E)
                          : (isDegraded ? const Color(0xFFF59E0B) : const Color(0xFF38BDF8)),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isInsideGeofence ? const Color(0xFF22C55E) : const Color(0xFF38BDF8)).withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.houseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.onRefreshGps != null)
                    InkWell(
                      onTap: widget.onRefreshGps,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('GPS Sync', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Live Animated Canvas
            SizedBox(
              height: 220,
              child: AnimatedBuilder(
                animation: _sweepController,
                builder: (context, child) {
                  return GestureDetector(
                    onTapUp: widget.isInteractive && widget.onCoordinateTapped != null
                        ? (details) {
                            final box = context.findRenderObject() as RenderBox?;
                            if (box == null) return;
                            final center = Offset(box.size.width / 2, 110);
                            final delta = details.localPosition - center;
                            // 100px = 100 meters scale
                            const scaleMetersPerPixel = 1.0;
                            final dxMeters = delta.dx * scaleMetersPerPixel;
                            final dyMeters = -delta.dy * scaleMetersPerPixel;
                            final latOffset = dyMeters / 110540.0;
                            final lonOffset = dxMeters / (111320.0 * math.cos(widget.targetLat * math.pi / 180.0));
                            widget.onCoordinateTapped!((
                              lat: widget.targetLat + latOffset,
                              lon: widget.targetLon + lonOffset,
                            ));
                          }
                        : null,
                    child: CustomPaint(
                      painter: _RadarCanvasPainter(
                        sweepAngle: _sweepController.value * 2 * math.pi,
                        targetLat: widget.targetLat,
                        targetLon: widget.targetLon,
                        radiusMeters: widget.geofenceRadiusMeters,
                        currentPos: widget.currentPosition,
                        isInside: widget.isInsideGeofence,
                        isContrast: widget.isContrast,
                      ),
                      child: Stack(
                        children: [
                          // Cardinal Directions
                          const Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                'N',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                'S',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            right: 8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Text(
                                'E',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Text(
                                'W',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Radius Scale Tag
                          Positioned(
                            left: 12,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Geofence: ${widget.geofenceRadiusMeters.toInt()}m',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // Real-Time Distance Tag
                          Positioned(
                            right: 12,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: widget.isInsideGeofence
                                    ? const Color(0xFF15803D).withOpacity(0.85)
                                    : Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.isInsideGeofence
                                      ? const Color(0xFF4ADE80)
                                      : Colors.white24,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.distanceMeters != null
                                    ? '${widget.distanceMeters!.toStringAsFixed(1)}m ${widget.isInsideGeofence ? "IN" : "AWAY"}'
                                    : 'Awaiting Fix...',
                                style: TextStyle(
                                  color: widget.isInsideGeofence
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Dwell Verification Progress Indicator (when inside)
                          if (widget.isInsideGeofence)
                            Positioned(
                              bottom: 10,
                              left: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF22C55E), width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          widget.dwellCountdown >= widget.requiredDwellSeconds
                                              ? '✅ Dwell Verified'
                                              : '⏳ Verifying Presence...',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${widget.dwellCountdown}s / ${widget.requiredDwellSeconds}s',
                                          style: TextStyle(
                                            color: widget.dwellCountdown >= widget.requiredDwellSeconds
                                                ? const Color(0xFF4ADE80)
                                                : const Color(0xFFFBBF24),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: (widget.dwellCountdown / widget.requiredDwellSeconds).clamp(0.0, 1.0),
                                        minHeight: 4,
                                        backgroundColor: Colors.white24,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          widget.dwellCountdown >= widget.requiredDwellSeconds
                                              ? const Color(0xFF22C55E)
                                              : const Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Telemetry & Edge Case Diagnostic Banners
            if (isDegraded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xFFB45309).withOpacity(0.9),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'GPS degraded (±${accuracy?.toStringAsFixed(0)}m). Move near open window/balcony for NavIC fix.',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            if (isVehicular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xFF1D4ED8).withOpacity(0.9),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'In-transit speed (${speedKmH.toStringAsFixed(1)} km/h). Dwell paused to prevent highway trigger.',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Coordinate Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: widget.isContrast ? Colors.black : const Color(0xFF0F172A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Target: ${widget.targetLat.toStringAsFixed(5)}, ${widget.targetLon.toStringAsFixed(5)}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                  if (accuracy != null)
                    Text(
                      'Fix: ±${accuracy.toStringAsFixed(1)}m',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: isDegraded ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Canvas painter for the sonar radar rings, sweep hand, geofence bubble, and blip
class _RadarCanvasPainter extends CustomPainter {
  final double sweepAngle;
  final double targetLat;
  final double targetLon;
  final double radiusMeters;
  final Position? currentPos;
  final bool isInside;
  final bool isContrast;

  _RadarCanvasPainter({
    required this.sweepAngle,
    required this.targetLat,
    required this.targetLon,
    required this.radiusMeters,
    required this.currentPos,
    required this.isInside,
    required this.isContrast,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 16;

    // Scale: Map 100 meters to maxRadius
    final pixelsPerMeter = maxRadius / 100.0;

    // 1. Concentric Distance Grid Rings (25m, 50m, 75m, 100m)
    final gridPaint = Paint()
      ..color = isContrast ? Colors.white24 : const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int m = 25; m <= 100; m += 25) {
      final r = m * pixelsPerMeter;
      canvas.drawCircle(center, r, gridPaint);
    }

    // Crosshairs
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      gridPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      gridPaint,
    );

    // 2. Animated Sonar Sweep Beam
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [
          (isInside ? const Color(0xFF22C55E) : const Color(0xFF38BDF8)).withOpacity(0.0),
          (isInside ? const Color(0xFF22C55E) : const Color(0xFF38BDF8)).withOpacity(0.25),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweepAngle);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: maxRadius),
      0,
      math.pi / 2,
      true,
      sweepPaint,
    );
    canvas.restore();

    // 3. Geofence Boundary Circle (Scaled to radiusMeters)
    final geofencePixelRadius = radiusMeters * pixelsPerMeter;
    final geofenceFillPaint = Paint()
      ..color = isInside
          ? const Color(0xFF22C55E).withOpacity(0.20)
          : const Color(0xFF0284C7).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final geofenceBorderPaint = Paint()
      ..color = isInside ? const Color(0xFF4ADE80) : const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, geofencePixelRadius, geofenceFillPaint);
    canvas.drawCircle(center, geofencePixelRadius, geofenceBorderPaint);

    // 4. Central House / Target Pin
    final houseCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, houseCenterPaint);

    final houseGlowPaint = Paint()
      ..color = (isInside ? const Color(0xFF4ADE80) : const Color(0xFF38BDF8)).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, 9, houseGlowPaint);

    // 5. Device Live Position Blip (if available)
    if (currentPos != null) {
      // Calculate delta in meters relative to house center
      final dyMeters = (targetLat - currentPos!.latitude) * 110540.0;
      final dxMeters = (currentPos!.longitude - targetLon) * (111320.0 * math.cos(targetLat * math.pi / 180.0));

      double pixelX = center.dx + (dxMeters * pixelsPerMeter);
      double pixelY = center.dy + (dyMeters * pixelsPerMeter);

      // Clamp within radar boundaries with distance indicator if out of radar view
      final distFromCenter = math.sqrt(math.pow(pixelX - center.dx, 2) + math.pow(pixelY - center.dy, 2));
      if (distFromCenter > maxRadius - 8) {
        final angle = math.atan2(pixelY - center.dy, pixelX - center.dx);
        pixelX = center.dx + math.cos(angle) * (maxRadius - 8);
        pixelY = center.dy + math.sin(angle) * (maxRadius - 8);
      }

      final blipOffset = Offset(pixelX, pixelY);

      // Accuracy Bubble around Device Blip
      final accuracyMeters = currentPos!.accuracy.clamp(3.0, 45.0);
      final accuracyPixelRadius = accuracyMeters * pixelsPerMeter;
      final accuracyPaint = Paint()
        ..color = (isInside ? const Color(0xFF22C55E) : const Color(0xFF38BDF8)).withOpacity(0.20)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(blipOffset, accuracyPixelRadius, accuracyPaint);

      // Blip Halo
      final blipHaloPaint = Paint()
        ..color = isInside ? const Color(0xFF4ADE80) : const Color(0xFF60A5FA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(blipOffset, 7, blipHaloPaint);

      // Blip Center
      final blipPaint = Paint()
        ..color = isInside ? const Color(0xFF22C55E) : const Color(0xFF2563EB)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(blipOffset, 4, blipPaint);

      // Connection dashed line from House to Maid
      final linePaint = Paint()
        ..color = Colors.white24
        ..strokeWidth = 1.0;
      canvas.drawLine(center, blipOffset, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarCanvasPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.currentPos != currentPos ||
        oldDelegate.radiusMeters != radiusMeters ||
        oldDelegate.isInside != isInside;
  }
}
