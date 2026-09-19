import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../household/domain/entities/household_entity.dart';

class HouseholdSelectorTabs extends StatelessWidget {
  final List<HouseholdEntity> households;
  final HouseholdEntity? selectedHousehold;
  final Map<int, double> householdDistances;
  final bool isContrast;
  final ValueChanged<HouseholdEntity> onSelect;

  const HouseholdSelectorTabs({
    super.key,
    required this.households,
    required this.selectedHousehold,
    required this.householdDistances,
    required this.isContrast,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (households.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: households.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final h = households[index];
          final isSelected = selectedHousehold != null && selectedHousehold!.id == h.id;
          final dist = householdDistances[h.id];
          final isInside = dist != null && dist <= h.geofenceRadiusMeters;

          return GestureDetector(
            onTap: () => onSelect(h),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isContrast
                        ? Colors.yellow
                        : (isInside ? const Color(0xFF0F766E) : AppColors.primary))
                    : (isContrast ? AppColors.hcSurface : Colors.white),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? (isContrast ? Colors.yellow : Colors.transparent)
                      : (isInside
                          ? const Color(0xFF22C55E)
                          : (isContrast ? AppColors.hcBorder : AppColors.border)),
                  width: isInside ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isContrast ? Colors.yellow : AppColors.primary).withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isInside)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isContrast ? Colors.black : Colors.white)
                            : const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Icon(
                    Icons.home_rounded,
                    size: 16,
                    color: isSelected
                        ? (isContrast ? Colors.black : Colors.white)
                        : (isContrast ? Colors.white70 : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    h.houseName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? (isContrast ? Colors.black : Colors.white)
                          : (isContrast ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  if (dist != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black.withOpacity(0.15)
                            : (isContrast ? Colors.white12 : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${dist.toInt()}m',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isContrast ? Colors.black : Colors.white.withOpacity(0.9))
                              : (isContrast ? Colors.white70 : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
