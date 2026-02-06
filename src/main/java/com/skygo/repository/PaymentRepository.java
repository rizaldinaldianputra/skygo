package com.skygo.repository;

import com.skygo.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository extends JpaRepository<Payment, Long> {

    java.util.Optional<com.skygo.model.Payment> findByOrder(com.skygo.model.Order order);
}
