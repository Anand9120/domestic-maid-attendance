package com.app.maidattendance.service.impl;

import com.app.maidattendance.entity.FcmDeviceToken;
import com.app.maidattendance.repository.FcmDeviceTokenRepository;
import com.app.maidattendance.service.FcmNotificationService;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class FcmNotificationServiceImpl implements FcmNotificationService {

    private static final Logger log = LoggerFactory.getLogger(FcmNotificationServiceImpl.class);

    private final FcmDeviceTokenRepository fcmDeviceTokenRepository;

    public FcmNotificationServiceImpl(FcmDeviceTokenRepository fcmDeviceTokenRepository) {
        this.fcmDeviceTokenRepository = fcmDeviceTokenRepository;
    }

    @Async
    @Override
    public void sendPushNotification(Long recipientUserId, String title, String body, Map<String, String> data) {
        List<FcmDeviceToken> tokens = fcmDeviceTokenRepository.findByUserId(recipientUserId);

        if (tokens.isEmpty()) {
            log.info("No FCM tokens registered for user ID: {}. Skipping push notification.", recipientUserId);
            return;
        }

        boolean isFirebaseReady = !FirebaseApp.getApps().isEmpty();

        for (FcmDeviceToken token : tokens) {
            String tokenValue = token.getFcmToken();

            if (!isFirebaseReady) {
                // PRD US-E01: Real-time Push Notification alert logged in dev / simulation mode
                log.info("[FCM SIMULATION] Push Notification sent to user {}: Title='{}', Body='{}', Token='{}'", 
                        recipientUserId, title, body, tokenValue);
                continue;
            }

            try {
                Message.Builder messageBuilder = Message.builder()
                        .setToken(tokenValue)
                        .setNotification(Notification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .build());

                if (data != null && !data.isEmpty()) {
                    messageBuilder.putAllData(data);
                }

                String response = FirebaseMessaging.getInstance().send(messageBuilder.build());
                log.info("FCM push notification successfully dispatched! Response ID: {}", response);
            } catch (FirebaseMessagingException e) {
                log.error("Failed to send FCM notification to token {}: {}", tokenValue, e.getMessage());
                if (e.getMessagingErrorCode() == MessagingErrorCode.UNREGISTERED) {
                    fcmDeviceTokenRepository.deleteByFcmToken(tokenValue);
                }
            }
        }
    }
}
