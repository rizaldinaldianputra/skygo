package com.skygo.controller;

import com.skygo.service.DriverService;
import com.skygo.service.TrackingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/tracking")
public class TrackingController {

    @Autowired
    private TrackingService trackingService;

    @Autowired
    private DriverService driverService;

    // Endpoint for Traccar to forward positions to
    // or for Driver App to ping directly if needed
    @PostMapping("/update")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<String>> updatePosition(
            @RequestBody Map<String, Object> payload) {
        // Assume simplified payload: { "driverId": 1, "lat": -6.2, "lng": 106.8 }
        Long driverId = Long.valueOf(payload.get("driverId").toString());
        double lat = Double.parseDouble(payload.get("lat").toString());
        double lng = Double.parseDouble(payload.get("lng").toString());

        trackingService.updateDriverLocation(driverId, lat, lng);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Location updated", "Location updated"));
    }

    @PostMapping("/driver/{id}/online")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<String>> goOnline(@PathVariable Long id) {
        driverService.setDriverAvailability(id, true);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Driver is ONLINE", "Driver is ONLINE"));
    }

    @PostMapping("/driver/{id}/offline")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<String>> goOffline(@PathVariable Long id) {
        driverService.setDriverAvailability(id, false);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Driver is OFFLINE", "Driver is OFFLINE"));
    }

    @GetMapping("/driver/{id}/location")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<java.util.Map<String, Double>>> getDriverLocation(
            @PathVariable Long id) {
        java.util.Map<String, Double> location = trackingService.getDriverLocation(id);
        if (location != null) {
            return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Driver location retrieved", location));
        }
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.error("Driver location not available"));
    }
}
