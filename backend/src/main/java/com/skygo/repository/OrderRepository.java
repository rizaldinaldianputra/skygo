package com.skygo.repository;

import com.skygo.model.Order;
import com.skygo.model.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDateTime;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByUserIdOrderByCreatedAtDesc(Long userId);

    List<Order> findByDriverIdOrderByCreatedAtDesc(Long driverId);

    List<Order> findByStatusOrderByCreatedAtDesc(OrderStatus status);

    // Paginated versions
    Page<Order> findByStatus(OrderStatus status, Pageable pageable);

    Page<Order> findByUserId(Long userId, Pageable pageable);

    Page<Order> findByDriverId(Long driverId, Pageable pageable);

    // Count orders by date range (for dashboard charts)
    long countByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
}
