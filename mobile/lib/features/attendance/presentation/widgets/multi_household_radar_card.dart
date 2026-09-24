import 'package:flutter/material.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../household/domain/entities/household_entity.dart';
import '../controllers/geofence_tracking_controller.dart';

class MultiHouseholdRadarCard extends StatelessWidget {
  final GeofenceTrackingController controller;
  final bool isContrast;
  final AccessibilityController a11y;
  final Function(HouseholdEntity)? onHouseholdSelected;

  const MultiHouseholdRadarCard({
    super.key,
    required this.controller,
    required this.isContrast,
    required this.a11y,
    this.onHouseholdSelected,
  });

  @override
  Widget build(BuildContext context) {
    final households = controller.assignedHouseholds;
    final active = controller.activeHousehold;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isContrast ? AppColors.hcBorder : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          if (!isContrast)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: controller.isInsideGeofence
                      ? (isContrast ? AppColors.darkPresentBg : AppColors.present.withOpacity(0.12))
                      : (isContrast ? Colors.white12 : const Color(0xFFE0E7FF)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share_location_rounded,
                  size: 24,
                  color: controller.isInsideGeofence
                      ? (isContrast ? AppColors.darkPresent : AppColors.present)
                      : (isContrast ? Colors.white70 : const Color(0xFF4338CA)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a11y.tr('multi_household_radar'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.isLoadingGps
                          ? a11y.tr('auto_detecting')
                          : '${households.length} ${a11y.tr('all_assigned_homes')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: controller.isInsideGeofence
                      ? (isContrast ? AppColors.darkPresentBg : const Color(0xFFDCFCE7))
                      : (isContrast ? Colors.white12 : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.radar_rounded,
                      size: 13,
                      color: controller.isInsideGeofence
                          ? (isContrast ? AppColors.darkPresent : const Color(0xFF16A34A))
                          : (isContrast ? Colors.white60 : Colors.blueGrey),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.isInsideGeofence ? 'LOCKED' : 'SCANNING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: controller.isInsideGeofence
                            ? (isContrast ? AppColors.darkPresent : const Color(0xFF166534))
                            : (isContrast ? Colors.white70 : Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // List of Households
          if (households.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No households registered yet.',
                style: TextStyle(
                  fontSize: 13,
                  color: isContrast ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: households.map((h) {
                final isSelected = active != null && active.id == h.id;
                final dist = controller.householdDistances[h.id];
                final isInside = dist != null && dist <= h.geofenceRadiusMeters;

                return GestureDetector(
                  onTap: () {
                    if (onHouseholdSelected != null) {
                      onHouseholdSelected!(h);
                    } else {
                      controller.setActiveHousehold(h);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isContrast
                              ? (isInside ? AppColors.darkPresentBg : Colors.white10)
                              : (isInside ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC)))
                          : (isContrast ? Colors.transparent : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (isInside
                                ? (isContrast ? AppColors.darkPresent : const Color(0xFF22C55E))
                                : (isContrast ? Colors.white38 : const Color(0xFF94A3B8)))
                            : (isContrast ? Colors.white12 : const Color(0xFFE2E8F0)),
                        width: isSelected ? (isInside ? 2 : 1.5) : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: isInside
                                    ? (isContrast ? AppColors.darkPresent : const Color(0xFF22C55E))
                                    : (isContrast ? Colors.white24 : const Color(0xFFE2E8F0)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isInside ? Icons.check_circle_rounded : Icons.home_work_rounded,
                                size: 16,
                                color: isInside
                                    ? Colors.white
                                    : (isContrast ? Colors.white70 : const Color(0xFF64748B)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          h.houseName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isContrast ? Colors.white : AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isInside
                                                ? (isContrast ? AppColors.darkPresent : const Color(0xFF16A34A))
                                                : (isContrast ? Colors.white24 : const Color(0xFF64748B)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            isInside ? a11y.tr('auto_switch_badge') : 'SELECTED',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (h.address != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      h.address!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isContrast ? Colors.white60 : AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  dist != null ? '${dist.toStringAsFixed(1)}m' : '...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isInside
                                        ? (isContrast ? AppColors.darkPresent : const Color(0xFF16A34A))
                                        : (dist != null && dist <= 100
                                            ? (isContrast ? Colors.amber : const Color(0xFFEA580C))
                                            : (isContrast ? Colors.white70 : AppColors.textSecondary)),
                                  ),
                                ),
                                Text(
                                  isInside ? 'Inside 50m' : 'Outside',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isInside
                                        ? (isContrast ? AppColors.darkPresent : const Color(0xFF16A34A))
                                        : (isContrast ? Colors.white54 : AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // If this household is actively dwelling
                        if (isSelected && isInside && !controller.hasCheckedInToday) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (controller.dwellCountdown / controller.requiredDwellSeconds)
                                  .clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: isContrast ? Colors.white24 : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                controller.dwellCountdown >= controller.requiredDwellSeconds
                                    ? (isContrast ? AppColors.darkPresent : AppColors.present)
                                    : (isContrast ? Colors.amber : AppColors.late),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${a11y.tr('dwell_verifying')} (${controller.dwellCountdown}s / ${controller.requiredDwellSeconds}s)',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isContrast ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${((controller.dwellCountdown / controller.requiredDwellSeconds) * 100).clamp(0, 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isContrast ? AppColors.darkPresent : AppColors.present,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
