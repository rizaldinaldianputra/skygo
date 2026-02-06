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
    public ResponseEntity<?> updatePosition(@RequestBody Map<String, Object> payload) {
        // Assume simplified payload: { "driverId": 1, "lat": -6.2, "lng": 106.8 }
        try {
            Long driverId = Long.valueOf(payload.get("driverId").toString());
            double lat = Double.parseDouble(payload.get("lat").toString());
            double lng = Double.parseDouble(payload.get("lng").toString());

            trackingService.updateDriverLocation(driverId, lat, lng);
            return ResponseEntity.ok("Location updated");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Invalid payload");
        }
    }

    @PostMapping("/driver/{id}/online")
    public ResponseEntity<?> goOnline(@PathVariable Long id) {
        driverService.setDriverAvailability(id, true);
        return ResponseEntity.ok("Driver is ONLINE");
    }

    @PostMapping("/driver/{id}/offline")
    public ResponseEntity<?> goOffline(@PathVariable Long id) {
        driverService.setDriverAvailability(id, false);
        return ResponseEntity.ok("Driver is OFFLINE");
    }
}
