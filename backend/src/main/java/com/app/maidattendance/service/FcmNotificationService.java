package com.app.maidattendance.service;

import java.util.Map;

public interface FcmNotificationService {
    void sendPushNotification(Long recipientUserId, String title, String body, Map<String, String> data);
}
