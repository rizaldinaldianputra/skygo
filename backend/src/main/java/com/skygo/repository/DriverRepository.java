package com.skygo.repository;

import com.skygo.model.Driver;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface DriverRepository extends JpaRepository<Driver, Long> {
    Optional<Driver> findByPhone(String phone);

    Optional<Driver> findByEmail(String email);

    boolean existsByEmail(String email);

    boolean existsByPhone(String phone);

    java.util.List<Driver> findAllByStatus(com.skygo.model.DriverStatus status);

    org.springframework.data.domain.Page<Driver> findAllByStatus(com.skygo.model.DriverStatus status,
            org.springframework.data.domain.Pageable pageable);

    long countByStatus(com.skygo.model.DriverStatus status);

    long countByAvailability(com.skygo.model.DriverAvailability availability);

    java.util.List<Driver> findAllByAvailability(com.skygo.model.DriverAvailability availability);
}
