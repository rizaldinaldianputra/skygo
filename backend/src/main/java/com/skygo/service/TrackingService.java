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

    /**
     * Get the current location of a driver from Redis Geo.
     * Returns a Map with "lat" and "lng" keys, or null if not found.
     */
    public java.util.Map<String, Double> getDriverLocation(Long driverId) {
        java.util.List<org.springframework.data.geo.Point> positions = redisTemplate.opsForGeo()
                .position(GEO_KEY, driverId.toString());
        if (positions != null && !positions.isEmpty() && positions.get(0) != null) {
            org.springframework.data.geo.Point point = positions.get(0);
            java.util.Map<String, Double> location = new java.util.HashMap<>();
            location.put("lat", point.getY()); // Y = latitude
            location.put("lng", point.getX()); // X = longitude
            return location;
        }
        return null;
    }
}
