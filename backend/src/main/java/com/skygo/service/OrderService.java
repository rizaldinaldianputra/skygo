package com.skygo.service;

import com.skygo.model.Order;
import com.skygo.model.OrderStatus;
import com.skygo.model.User;
import com.skygo.model.dto.CreateOrderRequest;
import com.skygo.model.Driver;
import com.skygo.repository.DriverRepository;
import com.skygo.repository.OrderRepository;
import com.skygo.repository.UserRepository;
import com.skygo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private org.camunda.bpm.engine.RuntimeService runtimeService;

    @Autowired
    private org.camunda.bpm.engine.TaskService taskService;

    // Simple pricing strategy
    private double calculatePrice(double distanceKm) {
        return 10000 + (distanceKm * 2000);
    }

    // Haversine Formula for distance
    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Radius of the earth in km
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                        * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    public com.skygo.model.dto.FareEstimateResponse getFareEstimate(com.skygo.model.dto.FareEstimateRequest request) {
        double distance = calculateDistance(
                request.getPickupLat(), request.getPickupLng(),
                request.getDestinationLat(), request.getDestinationLng());
        double price = calculatePrice(distance);
        return new com.skygo.model.dto.FareEstimateResponse(price, distance);
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

        // Start Camunda Process
        runtimeService.startProcessInstanceByKey("order_process", String.valueOf(saved.getId()),
                java.util.Map.of("orderId", saved.getId()));

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

    @Transactional
    public Order acceptOrder(Long orderId, Long driverId) {
        // 1. Find the Camunda Task for this order
        org.camunda.bpm.engine.task.Task task = taskService.createTaskQuery()
                .processVariableValueEquals("orderId", orderId)
                .taskCandidateGroup("driver")
                .singleResult();

        if (task == null) {
            throw new RuntimeException("Order is not available for acceptance (Task not found or already taken)");
        }

        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new RuntimeException("Driver not found"));

        // 2. Claim the task (Optimistic locking handled by Camunda)
        try {
            taskService.claim(task.getId(), String.valueOf(driverId));
        } catch (org.camunda.bpm.engine.TaskAlreadyClaimedException e) {
            throw new RuntimeException("Order already taken by another driver");
        }

        // 3. Update Domain Model
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setDriver(driver);
        order.setStatus(OrderStatus.ACCEPTED);

        // Update Driver Status to ON_TRIP
        driverService.setDriverAvailability(driverId, false);

        Order saved = orderRepository.save(order);

        // 4. Complete the task
        taskService.complete(task.getId(), java.util.Map.of("driverId", driverId));

        // Notify User via WebSocket
        messagingTemplate.convertAndSend("/topic/user/" + order.getUser().getId() + "/orders", saved);

        // Notify User via FCM
        fcmService.sendNotification(
                order.getUser().getFcmToken(),
                "Driver Found!",
                "Driver " + driver.getName() + " is on the way.");

        return saved;
    }

    @Autowired
    private GlobalConfigService configService;

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

            // Award Points
            int pointsPerOrder = configService.getPointsPerOrder();
            if (pointsPerOrder > 0) {
                User user = order.getUser();
                user.setPoints((user.getPoints() == null ? 0 : user.getPoints()) + pointsPerOrder);
                userRepository.save(user);
            }
        }

        return saved;
    }

    public java.util.List<Order> getOrderHistory(Long userId, String role) {
        if ("DRIVER".equalsIgnoreCase(role)) {
            return orderRepository.findByDriverIdOrderByCreatedAtDesc(userId);
        } else {
            return orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
        }
    }

    public Order getOrderDetails(Long orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
    }

    public Order rateOrder(Long orderId, Integer rating, String feedback) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (order.getStatus() != OrderStatus.COMPLETED) {
            throw new RuntimeException("Cannot rate an incomplete order");
        }

        order.setRating(rating);
        order.setFeedback(feedback);
        return orderRepository.save(order);
    }
}
