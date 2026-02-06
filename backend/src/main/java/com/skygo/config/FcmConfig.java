package com.skygo.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FcmConfig {

    // @PostConstruct
    public void initialize() {
        try {
            // Placeholder: In production, put firebase-service-account.json in resources
            // For now, we wrap in try-catch or just don't init if file missing to avoid
            // crash
            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.getApplicationDefault())
                        // .setCredentials(GoogleCredentials.fromStream(new
                        // ClassPathResource("firebase-key.json").getInputStream()))
                        .build();
                FirebaseApp.initializeApp(options);
            }
        } catch (Exception e) {
            System.out.println("Firebase init failed (expected if no key provided): " + e.getMessage());
        }
    }
}
