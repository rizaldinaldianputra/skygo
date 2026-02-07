package com.skygo.controller;

import com.skygo.model.DriverAvailability;
import com.skygo.model.DriverStatus;
import com.skygo.model.dto.ApiResponse;
import com.skygo.model.dto.DashboardStats;
import com.skygo.repository.DriverRepository;
import com.skygo.repository.OrderRepository;
import com.skygo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DriverRepository driverRepository;
    private final UserRepository userRepository;
    private final OrderRepository orderRepository;

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<DashboardStats>> getStats() {
        long totalDrivers = driverRepository.count();
        long activeDrivers = driverRepository.countByStatus(DriverStatus.ACTIVE);
        long onlineDrivers = driverRepository.countByAvailability(DriverAvailability.ONLINE);
        long totalUsers = userRepository.count();
        long totalOrders = orderRepository.count();

        DashboardStats stats = DashboardStats.builder()
                .totalDrivers(totalDrivers)
                .activeDrivers(activeDrivers)
                .onlineDrivers(onlineDrivers)
                .totalUsers(totalUsers)
                .totalOrders(totalOrders)
                .build();

        return ResponseEntity.ok(ApiResponse.success("Dashboard stats fetched", stats));
    }
}
