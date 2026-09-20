package com.app.maidattendance.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    private static final Logger log = LoggerFactory.getLogger(FirebaseConfig.class);

    @Value("${app.firebase.credentials-path:firebase-service-account.json}")
    private String credentialsPath;

    @Value("${app.firebase.enabled:true}")
    private boolean firebaseEnabled;

    @PostConstruct
    public void initializeFirebase() {
        if (!firebaseEnabled) {
            log.info("Firebase FCM explicitly disabled via configuration. Operating in SIMULATION mode.");
            return;
        }

        try {
            InputStream serviceAccount = null;
            ClassLoader classLoader = getClass().getClassLoader();
            InputStream resourceStream = classLoader.getResourceAsStream(credentialsPath);

            if (resourceStream != null) {
                serviceAccount = resourceStream;
            } else {
                File file = new File(credentialsPath);
                if (file.exists()) {
                    serviceAccount = new FileInputStream(file);
                }
            }

            if (serviceAccount == null) {
                log.info("Firebase service account credentials '{}' not found. Operating in SIMULATION mode.", credentialsPath);
                return;
            }

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
                log.info("Firebase Admin SDK successfully initialized for live push notifications (Project: {}).", options.getProjectId());
            }
        } catch (Exception e) {
            log.warn("Could not initialize Firebase Admin SDK from {}: {}. Operating in fallback simulation mode.", credentialsPath, e.getMessage());
        }
    }
}
