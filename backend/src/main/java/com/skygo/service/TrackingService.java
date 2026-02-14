package com.skygo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class TrackingService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Autowired
    private org.springframework.messaging.simp.SimpMessagingTemplate messagingTemplate;

    private static final String GEO_KEY = "drivers:online";

    public void updateDriverLocation(Long driverId, double lat, double lng) {
        redisTemplate.opsForGeo().add(GEO_KEY, new Point(lng, lat), driverId.toString());

        String message = driverId + ":" + lat + "," + lng;
        messagingTemplate.convertAndSend("/topic/drivers", message);
        messagingTemplate.convertAndSend("/topic/driver/" + driverId, message);
    }

    public void removeDriverFromGeo(Long driverId) {
        redisTemplate.opsForGeo().remove(GEO_KEY, driverId.toString());
    }

    /**
     * Get the current location of a driver from Redis Geo.
     */
    public Map<String, Double> getDriverLocation(Long driverId) {
        List<org.springframework.data.geo.Point> positions = redisTemplate.opsForGeo()
                .position(GEO_KEY, driverId.toString());
        if (positions != null && !positions.isEmpty() && positions.get(0) != null) {
            org.springframework.data.geo.Point point = positions.get(0);
            Map<String, Double> location = new HashMap<>();
            location.put("lat", point.getY());
            location.put("lng", point.getX());
            return location;
        }
        return null;
    }

    /**
     * Get all online driver locations from Redis Geo.
     * Returns list of maps with driverId, lat, lng.
     */
    public List<Map<String, Object>> getAllOnlineDriverLocations() {
        List<Map<String, Object>> result = new ArrayList<>();

        // Get all members from the geo set
        Set<String> members = redisTemplate.opsForZSet().range(GEO_KEY, 0, -1);
        if (members == null || members.isEmpty()) {
            return result;
        }

        // Get positions for all members
        String[] memberArray = members.toArray(new String[0]);
        List<org.springframework.data.geo.Point> positions = redisTemplate.opsForGeo()
                .position(GEO_KEY, memberArray);

        if (positions != null) {
            int i = 0;
            for (String memberId : memberArray) {
                if (i < positions.size() && positions.get(i) != null) {
                    org.springframework.data.geo.Point point = positions.get(i);
                    Map<String, Object> driverLocation = new HashMap<>();
                    driverLocation.put("driverId", Long.parseLong(memberId));
                    driverLocation.put("lat", point.getY());
                    driverLocation.put("lng", point.getX());
                    result.add(driverLocation);
                }
                i++;
            }
        }

        return result;
    }
}
