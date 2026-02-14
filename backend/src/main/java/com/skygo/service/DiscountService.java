package com.skygo.service;

import com.skygo.model.Discount;
import com.skygo.repository.DiscountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DiscountService {

    private final DiscountRepository discountRepository;

    public List<Discount> getAllDiscounts() {
        return discountRepository.findAll();
    }

    public Page<Discount> getAllDiscounts(Pageable pageable) {
        return discountRepository.findAll(pageable);
    }

    public Discount createDiscount(Discount discount) {
        if (discountRepository.existsByCode(discount.getCode())) {
            throw new RuntimeException("Discount code already exists");
        }
        return discountRepository.save(discount);
    }

    public Discount updateDiscount(Long id, Discount discountDetails) {
        Discount discount = discountRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Discount not found"));

        discount.setCode(discountDetails.getCode());
        discount.setAmount(discountDetails.getAmount());
        discount.setType(discountDetails.getType());
        discount.setValidUntil(discountDetails.getValidUntil());
        discount.setActive(discountDetails.isActive());

        return discountRepository.save(discount);
    }

    public void deleteDiscount(Long id) {
        discountRepository.deleteById(id);
    }

    public Discount getDiscountByCode(String code) {
        return discountRepository.findByCode(code)
                .orElseThrow(() -> new RuntimeException("Discount not found"));
    }
}
