package com.skygo.repository;

import com.skygo.model.Discount;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface DiscountRepository extends JpaRepository<Discount, Long> {
    Optional<Discount> findByCode(String code);

    boolean existsByCode(String code);
}
