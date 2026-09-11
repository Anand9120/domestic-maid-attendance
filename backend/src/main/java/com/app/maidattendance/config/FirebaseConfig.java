package com.app.maidattendance.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    private static final Logger log = LoggerFactory.getLogger(FirebaseConfig.class);

    @Value("${app.firebase.credentials-path:firebase-service-account.json}")
    private String credentialsPath;

    @Value("${app.firebase.enabled:false}")
    private boolean firebaseEnabled;

    @PostConstruct
    public void initializeFirebase() {
        if (!firebaseEnabled) {
            log.info("Firebase FCM is running in SIMULATION mode (set app.firebase.enabled=true with valid credentials for live push notifications).");
            return;
        }

        try {
            InputStream serviceAccount = null;
            ClassLoader classLoader = getClass().getClassLoader();
            InputStream resourceStream = classLoader.getResourceAsStream(credentialsPath);

            if (resourceStream != null) {
                serviceAccount = resourceStream;
            } else {
                serviceAccount = new FileInputStream(credentialsPath);
            }

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
                log.info("Firebase Admin SDK successfully initialized.");
            }
        } catch (Exception e) {
            log.warn("Could not initialize Firebase Admin SDK from {}: {}. Operating in fallback simulation mode.", credentialsPath, e.getMessage());
        }
    }
}
