package com.skygo.controller;

import com.skygo.dto.DriverRegistrationRequest;
import com.skygo.model.Driver;
import com.skygo.model.DriverStatus;
import com.skygo.service.DriverService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.skygo.model.dto.ApiResponse;
import com.skygo.model.dto.PaginatedResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

@RestController
@RequestMapping("/api/drivers")
@RequiredArgsConstructor
public class DriverController {

    private final DriverService driverService;

    @PostMapping(value = "/register", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Driver>> registerDriver(@ModelAttribute DriverRegistrationRequest request) {
        try {
            Driver driver = driverService.registerDriver(request);
            return ResponseEntity.ok(ApiResponse.success("Driver registered successfully", driver));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<ApiResponse<Driver>> updateDriverStatus(@PathVariable Long id,
            @RequestParam DriverStatus status) {
        try {
            Driver driver = driverService.updateDriverStatus(id, status);
            return ResponseEntity.ok(ApiResponse.success("Driver status updated", driver));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/pending")
    public ResponseEntity<ApiResponse<java.util.List<Driver>>> getPendingDrivers() {
        return ResponseEntity.ok(ApiResponse.success("Pending drivers fetched", driverService.getPendingDrivers()));
    }

    @GetMapping("/pending/paginated")
    public ResponseEntity<PaginatedResponse<java.util.List<Driver>>> getPendingDriversPaginated(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("id").descending());
        Page<Driver> driverPage = driverService.getPendingDrivers(pageable);

        return ResponseEntity.ok(new PaginatedResponse<>(
                true,
                "Pending drivers fetched successfully",
                driverPage.getContent(),
                driverPage.getNumber(),
                driverPage.getSize(),
                driverPage.getTotalElements(),
                driverPage.getTotalPages()));
    }
}
