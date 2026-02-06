package com.skygo.service;

import com.skygo.model.Order;
import com.skygo.model.OrderStatus;
import com.skygo.model.User;
import com.skygo.model.dto.CreateOrderRequest;
import com.skygo.model.Driver;
import com.skygo.repository.DriverRepository;
import com.skygo.repository.OrderRepository;
import com.skygo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MatchingService matchingService;

    // Simple pricing strategy
    private double calculatePrice(double distanceKm) {
        return 10000 + (distanceKm * 2000);
    }

    // Haversine Formula for distance
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Radius of the earth in km
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                        * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    public Order createOrder(CreateOrderRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        double distance = calculateDistance(
                request.getPickupLat(), request.getPickupLng(),
                request.getDestinationLat(), request.getDestinationLng());

        double price = calculatePrice(distance);

        Order order = new Order();
        order.setUser(user);
        order.setPickupAddress(request.getPickupAddress());
        order.setPickupLat(request.getPickupLat());
        order.setPickupLng(request.getPickupLng());
        order.setDestinationAddress(request.getDestinationAddress());
        order.setDestinationLat(request.getDestinationLat());
        order.setDestinationLng(request.getDestinationLng());
        order.setDistanceKm(distance);
        order.setEstimatedPrice(price);
        order.setStatus(OrderStatus.REQUESTED);

        Order saved = orderRepository.save(order);

        // Trigger Matching
        matchingService.findDrivers(saved);

        return saved;
    }

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private com.skygo.service.DriverService driverService;

    @Autowired
    private org.springframework.messaging.simp.SimpMessagingTemplate messagingTemplate;

    @Autowired
    private FcmService fcmService;

    public Order acceptOrder(Long orderId, Long driverId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (order.getStatus() != OrderStatus.REQUESTED) {
            throw new RuntimeException("Order already taken or cancelled");
        }

        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new RuntimeException("Driver not found"));

        order.setDriver(driver);
        order.setStatus(OrderStatus.ACCEPTED);

        // Update Driver Status to ON_TRIP
        driverService.setDriverAvailability(driverId, false);

        Order saved = orderRepository.save(order);

        // Notify User via WebSocket
        messagingTemplate.convertAndSend("/topic/user/" + order.getUser().getId() + "/orders", saved);

        // Notify User via FCM
        fcmService.sendNotification(
                order.getUser().getFcmToken(),
                "Driver Found!",
                "Driver " + driver.getName() + " is on the way.");

        return saved;
    }

    public Order updateStatus(Long orderId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setStatus(newStatus);
        Order saved = orderRepository.save(order);

        // Notify User
        messagingTemplate.convertAndSend("/topic/user/" + order.getUser().getId() + "/orders", saved);

        // Notify User via FCM
        fcmService.sendNotification(
                order.getUser().getFcmToken(),
                "Order Update",
                "Status is now: " + newStatus);

        if (newStatus == OrderStatus.COMPLETED) {
            // Unlock driver
            if (order.getDriver() != null) {
                driverService.setDriverAvailability(order.getDriver().getId(), true);
            }
        }

        return saved;
    }
}
