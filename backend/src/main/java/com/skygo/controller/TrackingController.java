package com.skygo.controller;

import com.skygo.model.dto.ApiResponse;
import com.skygo.service.DriverService;
import com.skygo.service.TrackingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/tracking")
public class TrackingController {

    @Autowired
    private TrackingService trackingService;

    @Autowired
    private DriverService driverService;

    @PostMapping("/update")
    public ResponseEntity<ApiResponse<String>> updatePosition(
            @RequestBody Map<String, Object> payload) {
        Long driverId = Long.valueOf(payload.get("driverId").toString());
        double lat = Double.parseDouble(payload.get("lat").toString());
        double lng = Double.parseDouble(payload.get("lng").toString());

        trackingService.updateDriverLocation(driverId, lat, lng);
        return ResponseEntity.ok(ApiResponse.success("Location updated", "Location updated"));
    }

    @PostMapping("/driver/{id}/online")
    public ResponseEntity<ApiResponse<String>> goOnline(@PathVariable Long id) {
        driverService.setDriverAvailability(id, true);
        return ResponseEntity.ok(ApiResponse.success("Driver is ONLINE", "Driver is ONLINE"));
    }

    @PostMapping("/driver/{id}/offline")
    public ResponseEntity<ApiResponse<String>> goOffline(@PathVariable Long id) {
        driverService.setDriverAvailability(id, false);
        return ResponseEntity.ok(ApiResponse.success("Driver is OFFLINE", "Driver is OFFLINE"));
    }

    @GetMapping("/driver/{id}/location")
    public ResponseEntity<ApiResponse<Map<String, Double>>> getDriverLocation(
            @PathVariable Long id) {
        Map<String, Double> location = trackingService.getDriverLocation(id);
        if (location != null) {
            return ResponseEntity.ok(ApiResponse.success("Driver location retrieved", location));
        }
        return ResponseEntity.ok(ApiResponse.error("Driver location not available"));
    }

    /**
     * Get all online driver locations from Redis Geo.
     * Returns list of { driverId, lat, lng } objects.
     */
    @GetMapping("/online-drivers")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllOnlineDriverLocations() {
        List<Map<String, Object>> locations = trackingService.getAllOnlineDriverLocations();
        return ResponseEntity.ok(ApiResponse.success("Online driver locations", locations));
    }
}
