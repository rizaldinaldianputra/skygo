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
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Integer>> getPointsPerOrder() {
        return ResponseEntity.ok(
                com.skygo.model.dto.ApiResponse.success("Points config fetched", configService.getPointsPerOrder()));
    }

    @PostMapping("/points")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Void>> setPointsPerOrder(@RequestBody PointsRequest request) {
        configService.setPointsPerOrder(request.getPoints());
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Points config updated", null));
    }

    @Data
    public static class PointsRequest {
        private int points;
    }
}
