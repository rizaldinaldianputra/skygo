package com.skygo.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FareEstimateResponse {
    private double estimatedPrice;
    private double distanceKm;
}
