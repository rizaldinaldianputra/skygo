package com.skygo.controller;

import com.skygo.service.GlobalConfigService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/config")
@RequiredArgsConstructor
public class GlobalConfigController {

    private final GlobalConfigService configService;

    @GetMapping("/points")
    public ResponseEntity<Integer> getPointsPerOrder() {
        return ResponseEntity.ok(configService.getPointsPerOrder());
    }

    @PostMapping("/points")
    public ResponseEntity<Void> setPointsPerOrder(@RequestBody PointsRequest request) {
        configService.setPointsPerOrder(request.getPoints());
        return ResponseEntity.ok().build();
    }

    @Data
    public static class PointsRequest {
        private int points;
    }
}
