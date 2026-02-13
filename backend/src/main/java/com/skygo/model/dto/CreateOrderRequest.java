package com.skygo.model.dto;

import lombok.Data;

@Data
public class CreateOrderRequest {
    private Long userId;
    private String pickupAddress;
    private double pickupLat;
    private double pickupLng;
    private String destinationAddress;
    private double destinationLat;
    private double destinationLng;
    private String vehicleType; // MOTOR or CAR
    private String paymentMethod; // CASH or WALLET
    private String paymentProofUrl;
}
