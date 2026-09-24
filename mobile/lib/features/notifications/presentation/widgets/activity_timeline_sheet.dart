import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class ActivityTimelineSheet extends StatefulWidget {
  final int userId;
  final bool isContrast;
  final AccessibilityController a11y;

  const ActivityTimelineSheet({
    super.key,
    required this.userId,
    required this.isContrast,
    required this.a11y,
  });

  @override
  State<ActivityTimelineSheet> createState() => _ActivityTimelineSheetState();
}

class _ActivityTimelineSheetState extends State<ActivityTimelineSheet> {
  String _selectedFilter = 'ALL'; // ALL, AUTO_SWITCH, ATTENDANCE, GEOFENCE

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isContrast ? AppColors.hcSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isContrast ? Colors.white38 : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.isContrast
                            ? AppColors.darkPrimary.withOpacity(0.15)
                            : const Color(0xFFE0E7FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        size: 22,
                        color: widget.isContrast ? AppColors.darkPrimary : const Color(0xFF4338CA),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.a11y.tr('activity_timeline'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.isContrast ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.a11y.tr('zero_touch_desc'),
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.isContrast ? Colors.white70 : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: Text(
                        widget.a11y.tr('mark_all_read'),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: widget.isContrast ? AppColors.darkPrimary : AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        context.read<NotificationBloc>().add(
                              MarkAllNotificationsReadEvent(userId: widget.userId),
                            );
                      },
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All Activities'),
                      const SizedBox(width: 8),
                      _buildFilterChip('AUTO_SWITCH', 'Auto-Switch'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ATTENDANCE', 'Check-In/Out'),
                    ],
                  ),
                ),
              ),

              const Divider(height: 16),

              // Timeline List
              Expanded(
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is NotificationLoaded) {
                      final filtered = _filterNotifications(state.notifications);
                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 48,
                                color: widget.isContrast ? Colors.white38 : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No timeline activities recorded yet.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.isContrast ? Colors.white60 : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildTimelineTile(item);
                        },
                      );
                    }

                    if (state is NotificationFailure) {
                      return Center(
                        child: Text(
                          'Error: ${state.error}',
                          style: TextStyle(
                            color: widget.isContrast ? Colors.red.shade300 : Colors.red,
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.isContrast ? AppColors.darkPrimary : AppColors.primary)
              : (widget.isContrast ? Colors.white10 : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (widget.isContrast ? AppColors.darkPrimary : AppColors.primary)
                : (widget.isContrast ? Colors.white24 : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? (widget.isContrast ? Colors.black : Colors.white)
                : (widget.isContrast ? Colors.white70 : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  List<NotificationEntity> _filterNotifications(List<NotificationEntity> list) {
    if (_selectedFilter == 'ALL') return list;
    if (_selectedFilter == 'AUTO_SWITCH') {
      return list.where((n) => n.type == NotificationType.autoSwitch).toList();
    }
    if (_selectedFilter == 'ATTENDANCE') {
      return list
          .where((n) =>
              n.type == NotificationType.checkIn ||
              n.type == NotificationType.checkOut ||
              n.type == NotificationType.geofenceEnter ||
              n.type == NotificationType.geofenceExit)
          .toList();
    }
    return list;
  }

  Widget _buildTimelineTile(NotificationEntity item) {
    final config = _getNotificationConfig(item.type);

    return GestureDetector(
      onTap: () {
        if (!item.isRead && item.id != null) {
          context.read<NotificationBloc>().add(
                MarkNotificationReadEvent(notificationId: item.id!),
              );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead
              ? (widget.isContrast ? Colors.white.withOpacity(0.04) : const Color(0xFFFAFAFA))
              : (widget.isContrast
                  ? AppColors.darkPrimary.withOpacity(0.08)
                  : config.badgeBg.withOpacity(0.18)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead
                ? (widget.isContrast ? AppColors.hcBorder : const Color(0xFFE2E8F0))
                : (widget.isContrast ? AppColors.darkBorder : config.color.withOpacity(0.4)),
            width: item.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isContrast
                    ? (item.isRead ? Colors.white24 : AppColors.darkPrimary.withOpacity(0.25))
                    : config.badgeBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                size: 18,
                color: widget.isContrast
                    ? (item.isRead ? Colors.white70 : AppColors.darkPrimary)
                    : config.color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: widget.isContrast ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: config.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isContrast ? Colors.white70 : AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(item.createdAt),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: widget.isContrast ? Colors.white54 : const Color(0xFF94A3B8),
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

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes % 60}m ago';
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  _NotifConfig _getNotificationConfig(NotificationType type) {
    switch (type) {
      case NotificationType.autoSwitch:
        return _NotifConfig(
          icon: Icons.sync_alt_rounded,
          color: const Color(0xFF6366F1),
          badgeBg: const Color(0xFFEEF2FF),
        );
      case NotificationType.geofenceEnter:
        return _NotifConfig(
          icon: Icons.login_rounded,
          color: const Color(0xFF0D9488),
          badgeBg: const Color(0xFFCCFBF1),
        );
      case NotificationType.geofenceExit:
        return _NotifConfig(
          icon: Icons.logout_rounded,
          color: const Color(0xFFEA580C),
          badgeBg: const Color(0xFFFFEDD5),
        );
      case NotificationType.checkIn:
        return _NotifConfig(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
          badgeBg: const Color(0xFFDCFCE7),
        );
      case NotificationType.checkOut:
        return _NotifConfig(
          icon: Icons.task_alt_rounded,
          color: const Color(0xFF2563EB),
          badgeBg: const Color(0xFFDBEAFE),
        );
      case NotificationType.spoofAlert:
        return _NotifConfig(
          icon: Icons.warning_rounded,
          color: const Color(0xFFDC2626),
          badgeBg: const Color(0xFFFEE2E2),
        );
      case NotificationType.payout:
        return _NotifConfig(
          icon: Icons.payments_rounded,
          color: const Color(0xFF059669),
          badgeBg: const Color(0xFFD1FAE5),
        );
      case NotificationType.system:
        return _NotifConfig(
          icon: Icons.info_outline_rounded,
          color: const Color(0xFF64748B),
          badgeBg: const Color(0xFFF1F5F9),
        );
    }

  }
}

class _NotifConfig {
  final IconData icon;
  final Color color;
  final Color badgeBg;

  _NotifConfig({
    required this.icon,
    required this.color,
    required this.badgeBg,
  });
}
