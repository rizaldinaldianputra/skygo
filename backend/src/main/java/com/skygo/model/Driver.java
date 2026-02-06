package com.skygo.model;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "drivers")
public class Driver {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String email;
    private String password;

    @Column(unique = true, nullable = false)
    private String phone;

    private String vehicleType; // MOTOR or CAR
    private String vehiclePlate;

    // PENDING, ACTIVE, SUSPENDED
    @Enumerated(EnumType.STRING)
    private DriverStatus status = DriverStatus.PENDING;

    // OFFLINE, ONLINE, ON_TRIP
    @Enumerated(EnumType.STRING)
    private DriverAvailability availability = DriverAvailability.OFFLINE;

    private String fcmToken;

    private String simUrl;
    private String ktpUrl;
    private String photoUrl;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
