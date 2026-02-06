package com.skygo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@Service
public class TrackingService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Autowired
    private org.springframework.messaging.simp.SimpMessagingTemplate messagingTemplate;

    private static final String GEO_KEY = "drivers:online";

    public void updateDriverLocation(Long driverId, double lat, double lng) {
        // Add to Redis Geo
        redisTemplate.opsForGeo().add(GEO_KEY, new Point(lng, lat), driverId.toString());

        // Broadcast to WebSocket clients (e.g., users looking at map)
        // Format: "driverId:lat,lng"
        String message = driverId + ":" + lat + "," + lng;
        // Generic "all drivers" topic (for finding nearby)
        messagingTemplate.convertAndSend("/topic/drivers", message);
        // Specific driver topic (for tracking during trip)
        messagingTemplate.convertAndSend("/topic/driver/" + driverId, message);
    }

    public void removeDriverFromGeo(Long driverId) {
        redisTemplate.opsForGeo().remove(GEO_KEY, driverId.toString());
    }
}
