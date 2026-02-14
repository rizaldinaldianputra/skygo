package com.skygo.controller;

import com.skygo.model.Order;
import com.skygo.model.OrderStatus;
import com.skygo.model.dto.ApiResponse;
import com.skygo.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PostMapping("/create")
    public ResponseEntity<ApiResponse<Order>> createOrder(@RequestBody com.skygo.model.dto.CreateOrderRequest request,
            @org.springframework.security.core.annotation.AuthenticationPrincipal org.springframework.security.oauth2.jwt.Jwt jwt) {
        String email = jwt.getSubject();
        Order order = orderService.createOrder(request, email);
        return ResponseEntity.ok(ApiResponse.success("Order created", order));
    }

    @PostMapping("/{id}/accept")
    public ResponseEntity<ApiResponse<Order>> acceptOrder(@PathVariable Long id,
            @org.springframework.security.core.annotation.AuthenticationPrincipal org.springframework.security.oauth2.jwt.Jwt jwt) {
        String email = jwt.getSubject();
        Order order = orderService.acceptOrder(id, email);
        return ResponseEntity.ok(ApiResponse.success("Order accepted", order));
    }

    @GetMapping("/available")
    public ResponseEntity<ApiResponse<Page<Order>>> getAvailableOrders(
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Available orders retrieved",
                orderService.getAvailableOrders(pageable)));
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<ApiResponse<String>> rejectOrder(@PathVariable Long id,
            @RequestParam Long driverId) {
        return ResponseEntity.ok(ApiResponse.success("Order rejected", "Order Rejected"));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<Order>> cancelOrder(@PathVariable Long id) {
        Order order = orderService.updateStatus(id, OrderStatus.CANCELLED);
        return ResponseEntity.ok(ApiResponse.success("Order cancelled", order));
    }

    @PostMapping("/{id}/start")
    public ResponseEntity<ApiResponse<Order>> startTrip(@PathVariable Long id) {
        Order order = orderService.updateStatus(id, OrderStatus.ONGOING);
        return ResponseEntity.ok(ApiResponse.success("Trip started", order));
    }

    @PostMapping("/{id}/finish")
    public ResponseEntity<ApiResponse<Order>> finishTrip(@PathVariable Long id) {
        Order order = orderService.updateStatus(id, OrderStatus.COMPLETED);
        return ResponseEntity.ok(ApiResponse.success("Trip finished", order));
    }

    @GetMapping("/history")
    public ResponseEntity<ApiResponse<Page<Order>>> getOrderHistory(
            @RequestParam Long userId, @RequestParam String role,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Order history retrieved",
                orderService.getOrderHistory(userId, role, pageable)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Order>> getOrderDetails(@PathVariable Long id) {
        Order order = orderService.getOrderDetails(id);
        return ResponseEntity.ok(ApiResponse.success("Order details retrieved", order));
    }

    @PostMapping("/{id}/rate")
    public ResponseEntity<ApiResponse<Order>> rateOrder(@PathVariable Long id,
            @RequestBody com.skygo.model.dto.RateOrderRequest request) {
        Order order = orderService.rateOrder(id, request.getRating(), request.getFeedback());
        return ResponseEntity.ok(ApiResponse.success("Order rated", order));
    }

    @GetMapping("/{id}/invoice")
    public ResponseEntity<ApiResponse<Order>> getInvoice(@PathVariable Long id) {
        Order order = orderService.getOrderDetails(id);
        return ResponseEntity.ok(ApiResponse.success("Invoice data retrieved", order));
    }

    @PostMapping("/estimate-fare")
    public ResponseEntity<ApiResponse<com.skygo.model.dto.FareEstimateResponse>> estimateFare(
            @RequestBody com.skygo.model.dto.FareEstimateRequest request) {
        com.skygo.model.dto.FareEstimateResponse response = orderService.getFareEstimate(request);
        return ResponseEntity.ok(ApiResponse.success("Fare estimated", response));
    }
}