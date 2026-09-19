package com.app.maidattendance.service.impl;

import com.app.maidattendance.entity.NotificationLog;
import com.app.maidattendance.repository.NotificationLogRepository;
import com.app.maidattendance.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class NotificationServiceImpl implements NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationServiceImpl.class);
    private final NotificationLogRepository notificationLogRepository;

    public NotificationServiceImpl(NotificationLogRepository notificationLogRepository) {
        this.notificationLogRepository = notificationLogRepository;
    }

    @Override
    public NotificationLog recordNotification(Long userId, Long householdId, String title, String body, String type) {
        NotificationLog notification = new NotificationLog(userId, householdId, title, body, type);
        NotificationLog saved = notificationLogRepository.save(notification);
        log.info("Recorded in-app notification for user {}: '{}' (Type: {})", userId, title, type);
        return saved;
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationLog> getUserNotifications(Long userId) {
        return notificationLogRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public Long getUnreadCount(Long userId) {
        return notificationLogRepository.countByUserIdAndIsReadFalse(userId);
    }

    @Override
    public void markAsRead(Long notificationId) {
        notificationLogRepository.findById(notificationId).ifPresent(n -> {
            n.setIsRead(true);
            notificationLogRepository.save(n);
        });
    }

    @Override
    public void markAllAsRead(Long userId) {
        List<NotificationLog> notifications = notificationLogRepository.findByUserIdOrderByCreatedAtDesc(userId);
        for (NotificationLog n : notifications) {
            if (!Boolean.TRUE.equals(n.getIsRead())) {
                n.setIsRead(true);
            }
        }
        notificationLogRepository.saveAll(notifications);
    }
}
