package com.skygo.model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "payment_methods")
public class PaymentMethod {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String code; // e.g. "WALLET", "TRANSFER"
    private String name; // e.g. "SkyPay", "Bank Transfer"
    private String type; // CASH, WALLET, BANK
    private String description;
    private String imageUrl; // Icon/Logo

    private boolean active = true;

    // Instructions for user (e.g. Bank Account Number)
    @Column(columnDefinition = "TEXT")
    private String instructions;
}
