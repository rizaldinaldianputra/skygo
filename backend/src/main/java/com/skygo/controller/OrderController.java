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
    public ResponseEntity<?> createOrder(@RequestBody CreateOrderRequest request) {
        try {
            Order order = orderService.createOrder(request);
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/{id}/accept")
    public ResponseEntity<?> acceptOrder(@PathVariable Long id, @RequestParam Long driverId) {
        try {
            Order order = orderService.acceptOrder(id, driverId);
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<?> rejectOrder(@PathVariable Long id, @RequestParam Long driverId) {
        // For simplicity, just log or trigger matching again
        return ResponseEntity.ok("Order Rejected");
    }

    @PostMapping("/{id}/start")
    public ResponseEntity<?> startTrip(@PathVariable Long id) {
        try {
            Order order = orderService.updateStatus(id, com.skygo.model.OrderStatus.ONGOING);
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/{id}/finish")
    public ResponseEntity<?> finishTrip(@PathVariable Long id) {
        try {
            Order order = orderService.updateStatus(id, com.skygo.model.OrderStatus.COMPLETED);
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}