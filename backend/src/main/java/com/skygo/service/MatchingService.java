package com.skygo.service;

import com.skygo.model.Order;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.geo.Circle;
import org.springframework.data.geo.Distance;
import org.springframework.data.geo.GeoResults;
import org.springframework.data.geo.Metrics;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MatchingService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private FcmService fcmService;

    // In a real app, this should be in a separate Service/Repository to get Driver
    // entity by ID
    // or we cache the token in Redis too.
    @Autowired
    private com.skygo.repository.DriverRepository driverRepository;

    private static final String GEO_KEY = "drivers:online";

    public void findDrivers(Order order) {
        // Radius 3 KM
        Point pickupPoint = new Point(order.getPickupLng(), order.getPickupLat());
        Distance radius = new Distance(3.0, Metrics.KILOMETERS);
        Circle circle = new Circle(pickupPoint, radius);

        RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs
                .newGeoRadiusArgs()
                .includeDistance()
                .sortAscending();

        GeoResults<RedisGeoCommands.GeoLocation<String>> results = redisTemplate.opsForGeo().radius(GEO_KEY, circle,
                args);

        if (results != null) {
            List<String> nearbyDrivers = results.getContent().stream()
                    .map(res -> res.getContent().getName())
                    .collect(Collectors.toList());

            // In a real app, we would offer to the first one, then next.
            // Simplified: Broadcast to all nearby drivers
            for (String driverIdStr : nearbyDrivers) {
                Long driverId = Long.parseLong(driverIdStr);

                driverRepository.findById(driverId).ifPresent(driver -> {
                    // Filter by Vehicle Type (if specified in order)
                    if (order.getServiceType() != null &&
                            !order.getServiceType().equalsIgnoreCase(driver.getVehicleType())) {
                        return;
                    }

                    // Send Order Request to Driver via WebSocket
                    messagingTemplate.convertAndSend("/topic/driver/" + driverIdStr + "/orders", order);

                    // Send FCM
                    java.util.Map<String, String> data = new java.util.HashMap<>();
                    data.put("orderId", String.valueOf(order.getId()));
                    data.put("pickupAddress", order.getPickupAddress());
                    data.put("destinationAddress", order.getDestinationAddress());
                    data.put("price", String.valueOf(order.getEstimatedPrice()));
                    data.put("distance", String.valueOf(order.getDistanceKm()));

                    fcmService.sendNotification(
                            driver.getFcmToken(),
                            "New Order Available!",
                            "Pickup at: " + order.getPickupAddress(),
                            data);
                });
            }
        }
    }
}
