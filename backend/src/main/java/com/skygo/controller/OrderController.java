package com.skygo.controller;

import com.skygo.model.Order;
import com.skygo.model.dto.CreateOrderRequest;
import com.skygo.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PostMapping("/create")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> createOrder(@RequestBody CreateOrderRequest request,
            @org.springframework.security.core.annotation.AuthenticationPrincipal org.springframework.security.oauth2.jwt.Jwt jwt) {
        String email = jwt.getSubject();
        Order order = orderService.createOrder(request, email);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order created", order));
    }

    @PostMapping("/{id}/accept")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> acceptOrder(@PathVariable Long id,
            @org.springframework.security.core.annotation.AuthenticationPrincipal org.springframework.security.oauth2.jwt.Jwt jwt) {
        String email = jwt.getSubject(); // Driver's email from token
        Order order = orderService.acceptOrder(id, email);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order accepted", order));
    }

    @GetMapping("/available")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<java.util.List<Order>>> getAvailableOrders() {
        java.util.List<Order> orders = orderService.getAvailableOrders();
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Available orders retrieved", orders));
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<String>> rejectOrder(@PathVariable Long id,
            @RequestParam Long driverId) {
        // For simplicity, just log or trigger matching again
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order rejected", "Order Rejected"));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> cancelOrder(@PathVariable Long id) {
        Order order = orderService.updateStatus(id, com.skygo.model.OrderStatus.CANCELLED);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order cancelled", order));
    }

    @PostMapping("/{id}/start")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> startTrip(@PathVariable Long id) {
        Order order = orderService.updateStatus(id, com.skygo.model.OrderStatus.ONGOING);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Trip started", order));
    }

    @PostMapping("/{id}/finish")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> finishTrip(@PathVariable Long id) {
        Order order = orderService.updateStatus(id, com.skygo.model.OrderStatus.COMPLETED);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Trip finished", order));
    }

    @GetMapping("/history")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<java.util.List<Order>>> getOrderHistory(
            @RequestParam Long userId, @RequestParam String role) {
        java.util.List<Order> history = orderService.getOrderHistory(userId, role);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order history retrieved", history));
    }

    @GetMapping("/{id}")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> getOrderDetails(@PathVariable Long id) {
        Order order = orderService.getOrderDetails(id);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order details retrieved", order));
    }

    @PostMapping("/{id}/rate")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> rateOrder(@PathVariable Long id,
            @RequestBody com.skygo.model.dto.RateOrderRequest request) {
        Order order = orderService.rateOrder(id, request.getRating(), request.getFeedback());
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order rated", order));
    }

    @GetMapping("/{id}/invoice")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> getInvoice(@PathVariable Long id) {
        Order order = orderService.getOrderDetails(id);
        // For now, invoice data is just the order data
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Invoice data retrieved", order));
    }

    @PostMapping("/estimate-fare")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<com.skygo.model.dto.FareEstimateResponse>> estimateFare(
            @RequestBody com.skygo.model.dto.FareEstimateRequest request) {
        com.skygo.model.dto.FareEstimateResponse response = orderService.getFareEstimate(request);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Fare estimated", response));
    }
}