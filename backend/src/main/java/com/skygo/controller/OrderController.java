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
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> createOrder(@RequestBody CreateOrderRequest request) {
        Order order = orderService.createOrder(request);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order created", order));
    }

    @PostMapping("/{id}/accept")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Order>> acceptOrder(@PathVariable Long id,
            @RequestParam Long driverId) {
        Order order = orderService.acceptOrder(id, driverId);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order accepted", order));
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<String>> rejectOrder(@PathVariable Long id,
            @RequestParam Long driverId) {
        // For simplicity, just log or trigger matching again
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Order rejected", "Order Rejected"));
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

    @PostMapping("/estimate-fare")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<com.skygo.model.dto.FareEstimateResponse>> estimateFare(
            @RequestBody com.skygo.model.dto.FareEstimateRequest request) {
        com.skygo.model.dto.FareEstimateResponse response = orderService.getFareEstimate(request);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Fare estimated", response));
    }
}