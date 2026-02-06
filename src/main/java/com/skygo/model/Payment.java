package com.skygo.model;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "payments")
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "order_id")
    private Order order;

    private double amount;

    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod; // CASH, MIDTRANS

    @Enumerated(EnumType.STRING)
    private PaymentStatus status; // PENDING, PAID, EXPIRED, CANCELLED

    @CreationTimestamp
    private LocalDateTime createdAt;
}
