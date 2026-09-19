package com.app.maidattendance.service;

import com.app.maidattendance.entity.NotificationLog;
import java.util.List;

public interface NotificationService {
    NotificationLog recordNotification(Long userId, Long householdId, String title, String body, String type);
    List<NotificationLog> getUserNotifications(Long userId);
    Long getUnreadCount(Long userId);
    void markAsRead(Long notificationId);
    void markAllAsRead(Long userId);
}
