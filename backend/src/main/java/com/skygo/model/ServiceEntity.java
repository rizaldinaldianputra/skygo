package com.skygo.model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "services")
public class ServiceEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name; // e.g. "SkyRide"
    private String code; // e.g. "MOTOR"
    private String description;
    private String iconUrl;

    private boolean active = true;
    private int displayOrder;
}
