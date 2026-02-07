package com.skygo.model.dto;

import lombok.Data;

@Data
public class FareEstimateRequest {
    private double pickupLat;
    private double pickupLng;
    private double destinationLat;
    private double destinationLng;
}
