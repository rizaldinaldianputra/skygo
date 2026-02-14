package com.skygo.controller;

import com.skygo.model.Discount;
import com.skygo.model.dto.ApiResponse;
import com.skygo.service.DiscountService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/discounts")
@RequiredArgsConstructor
public class DiscountController {

    private final DiscountService discountService;

    @GetMapping
    public ResponseEntity<ApiResponse<Page<Discount>>> getAllDiscounts(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Discounts fetched",
                discountService.getAllDiscounts(pageable)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Discount>> createDiscount(@RequestBody Discount discount) {
        return ResponseEntity.ok(
                ApiResponse.success("Discount created", discountService.createDiscount(discount)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Discount>> updateDiscount(@PathVariable Long id,
            @RequestBody Discount discount) {
        return ResponseEntity.ok(ApiResponse.success("Discount updated",
                discountService.updateDiscount(id, discount)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteDiscount(@PathVariable Long id) {
        discountService.deleteDiscount(id);
        return ResponseEntity.ok(ApiResponse.success("Discount deleted", null));
    }
}
