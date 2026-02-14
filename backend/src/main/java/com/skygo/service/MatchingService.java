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

        /**
         * Find the CLOSEST driver to the pickup location and send notification ONLY to
         * that driver.
         * Gojek-style: one driver at a time, sorted by distance (ascending).
         */
        public void findDrivers(Order order) {
                // Radius 3 KM
                Point pickupPoint = new Point(order.getPickupLng(), order.getPickupLat());
                Distance radius = new Distance(3.0, Metrics.KILOMETERS);
                Circle circle = new Circle(pickupPoint, radius);

                RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs
                                .newGeoRadiusArgs()
                                .includeDistance()
                                .sortAscending(); // Closest first

                System.out.println("[MatchingService] Searching CLOSEST driver near pickup: lat=" + order.getPickupLat()
                                + ", lng=" + order.getPickupLng() + " within 3km radius");

                GeoResults<RedisGeoCommands.GeoLocation<String>> results = redisTemplate.opsForGeo().radius(GEO_KEY,
                                circle,
                                args);

                if (results == null || results.getContent().isEmpty()) {
                        System.out.println("[MatchingService] NO drivers found in Redis Geo within 3km radius. "
                                        + "Make sure drivers are ONLINE and sending location updates.");
                        return;
                }

                List<String> nearbyDrivers = results.getContent().stream()
                                .map(res -> res.getContent().getName())
                                .collect(Collectors.toList());

                System.out.println("[MatchingService] Found " + nearbyDrivers.size() + " nearby driver(s) in Redis: "
                                + nearbyDrivers);

                // Find the CLOSEST matching driver (first valid one in sorted list)
                for (String driverIdStr : nearbyDrivers) {
                        Long driverId = Long.parseLong(driverIdStr);

                        var driverOpt = driverRepository.findById(driverId);
                        if (driverOpt.isEmpty()) {
                                System.out.println(
                                                "[MatchingService] Skipping driver " + driverId + " - not found in DB");
                                continue;
                        }

                        var driver = driverOpt.get();

                        // Filter by Vehicle Type (if specified in order)
                        if (order.getServiceType() != null &&
                                        !order.getServiceType().equalsIgnoreCase(driver.getVehicleType())) {
                                System.out.println("[MatchingService] Skipping driver " + driverId
                                                + " - vehicle type mismatch (order=" + order.getServiceType()
                                                + ", driver=" + driver.getVehicleType() + ")");
                                continue;
                        }

                        // Check FCM token
                        if (driver.getFcmToken() == null || driver.getFcmToken().isEmpty()) {
                                System.out.println("[MatchingService] Skipping driver " + driverId
                                                + " - no FCM token, cannot send notification");
                                continue;
                        }

                        // This is the closest valid driver — send notification ONLY to this one
                        System.out.println("[MatchingService] Selected CLOSEST driver " + driverId
                                        + " (token="
                                        + driver.getFcmToken().substring(0, Math.min(10, driver.getFcmToken().length()))
                                        + "..."
                                        + ") for order " + order.getId());

                        // Send Order Request to Driver via WebSocket
                        messagingTemplate.convertAndSend("/topic/driver/" + driverIdStr + "/orders", order);

                        // Send FCM notification
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

                        System.out.println("[MatchingService] Notification sent to closest driver " + driverId
                                        + " for order " + order.getId());
                        return; // Done — only notify the closest driver
                }

                System.out.println("[MatchingService] No eligible driver found for order " + order.getId()
                                + " (all nearby drivers were filtered out)");
        }
}
