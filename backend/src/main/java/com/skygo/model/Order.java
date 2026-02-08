package com.skygo.model;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "driver_id")
    private Driver driver;

    private String pickupAddress;
    private double pickupLat;
    private double pickupLng;

    private String destinationAddress;
    private double destinationLat;
    private double destinationLng;

    private double distanceKm;
    private double estimatedPrice;

    @Enumerated(EnumType.STRING)
    private OrderStatus status = OrderStatus.REQUESTED;

    private Integer rating; // 1-5
    private String feedback;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
