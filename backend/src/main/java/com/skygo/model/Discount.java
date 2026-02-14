package com.skygo.model;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "discounts")
public class Discount {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String code;

    private String description;

    @Enumerated(EnumType.STRING)
    private DiscountType discountType; // FIXED or PERCENTAGE

    private double discountValue; // Value of discount

    private double minOrderAmount; // Minimum order amount to apply

    private int maxUsage; // Maximum number of times this discount can be used

    private boolean active = true;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum DiscountType {
        FIXED,
        PERCENTAGE
    }
}
