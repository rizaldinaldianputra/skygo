package com.skygo.controller;

import com.skygo.model.Discount;
import com.skygo.service.DiscountService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/discounts")
@RequiredArgsConstructor
public class DiscountController {

    private final DiscountService discountService;

    @GetMapping
    public ResponseEntity<com.skygo.model.dto.ApiResponse<List<Discount>>> getAllDiscounts() {
        return ResponseEntity
                .ok(com.skygo.model.dto.ApiResponse.success("Discounts fetched", discountService.getAllDiscounts()));
    }

    @PostMapping
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Discount>> createDiscount(@RequestBody Discount discount) {
        return ResponseEntity.ok(
                com.skygo.model.dto.ApiResponse.success("Discount created", discountService.createDiscount(discount)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Discount>> updateDiscount(@PathVariable Long id,
            @RequestBody Discount discount) {
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Discount updated",
                discountService.updateDiscount(id, discount)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Void>> deleteDiscount(@PathVariable Long id) {
        discountService.deleteDiscount(id);
        return ResponseEntity.ok(com.skygo.model.dto.ApiResponse.success("Discount deleted", null));
    }
}
