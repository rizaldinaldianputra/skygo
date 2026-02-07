package com.skygo.controller;

import com.skygo.model.Order;
import com.skygo.model.Rating;
import com.skygo.repository.OrderRepository;
import com.skygo.repository.RatingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/ratings")
public class RatingController {

    @Autowired
    private RatingRepository ratingRepository;

    @Autowired
    private OrderRepository orderRepository;

    @PostMapping("/add")
    public ResponseEntity<com.skygo.model.dto.ApiResponse<Rating>> addRating(@RequestBody Map<String, Object> payload) {
        Long orderId = Long.valueOf(payload.get("orderId").toString());
        int score = Integer.parseInt(payload.get("score").toString());
        String comment = payload.get("comment").toString();

        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        Rating rating = new Rating();
        rating.setOrder(order);
        rating.setScore(score);
        rating.setComment(comment);

        return ResponseEntity
                .ok(com.skygo.model.dto.ApiResponse.success("Rating added", ratingRepository.save(rating)));
    }
}
