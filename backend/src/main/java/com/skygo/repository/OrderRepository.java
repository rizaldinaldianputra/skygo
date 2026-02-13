package com.skygo.repository;

import com.skygo.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByUserIdOrderByCreatedAtDesc(Long userId);

    List<Order> findByDriverIdOrderByCreatedAtDesc(Long driverId);

    List<Order> findByStatusOrderByCreatedAtDesc(com.skygo.model.OrderStatus status);
}
