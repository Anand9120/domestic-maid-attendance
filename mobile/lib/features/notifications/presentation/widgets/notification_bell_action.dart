import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_state.dart';
import 'activity_timeline_sheet.dart';

class NotificationBellAction extends StatelessWidget {
  final int userId;
  final bool isContrast;
  final AccessibilityController a11y;

  const NotificationBellAction({
    super.key,
    required this.userId,
    required this.isContrast,
    required this.a11y,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                unreadCount > 0
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: isContrast
                    ? (unreadCount > 0 ? Colors.yellow : Colors.white)
                    : (unreadCount > 0 ? AppColors.primary : AppColors.textPrimary),
                size: 24,
              ),
              tooltip: a11y.tr('activity_timeline'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ActivityTimelineSheet(
                    userId: userId,
                    isContrast: isContrast,
                    a11y: a11y,
                  ),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isContrast ? Colors.yellow : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isContrast ? Colors.black : Colors.white,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
