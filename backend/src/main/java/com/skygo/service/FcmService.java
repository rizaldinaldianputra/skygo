package com.skygo.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.stereotype.Service;

@Service
public class FcmService {

    public void sendNotification(String token, String title, String body, java.util.Map<String, String> data) {
        if (token == null || token.isEmpty())
            return;

        try {
            // Check if Firebase is initialized
            if (com.google.firebase.FirebaseApp.getApps().isEmpty()) {
                System.out.println("LOG [FCM Mock] To: " + token + " | " + title + ": " + body);
                return;
            }

            Message.Builder messageBuilder = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build());

            if (data != null) {
                messageBuilder.putAllData(data);
            }

            FirebaseMessaging.getInstance().send(messageBuilder.build());

        } catch (Exception e) {
            // Fallback logging if FCM fails or keys invalid
            System.err.println("Error sending FCM: " + e.getMessage());
        }
    }

    // Overload for backward compatibility
    public void sendNotification(String token, String title, String body) {
        sendNotification(token, title, body, null);
    }
}
