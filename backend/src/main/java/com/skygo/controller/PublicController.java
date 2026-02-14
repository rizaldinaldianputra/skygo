package com.skygo.controller;

import com.skygo.model.*;
import com.skygo.model.dto.ApiResponse;
import com.skygo.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/public")
public class PublicController {

    @Autowired
    private BannerRepository bannerRepository;

    @Autowired
    private PromoRepository promoRepository;

    @Autowired
    private NewsRepository newsRepository;

    @GetMapping("/banners")
    public ResponseEntity<ApiResponse<List<Banner>>> getActiveBanners() {
        List<Banner> banners = bannerRepository.findAllByActiveTrueOrderByDisplayOrderAsc();
        return ResponseEntity.ok(ApiResponse.success("Active banners", banners));
    }

    @GetMapping("/promos")
    public ResponseEntity<ApiResponse<List<Promo>>> getActivePromos() {
        List<Promo> promos = promoRepository.findAllByActiveTrueOrderByCreatedAtDesc();
        return ResponseEntity.ok(ApiResponse.success("Active promos", promos));
    }

    @GetMapping("/news")
    public ResponseEntity<ApiResponse<List<News>>> getActiveNews() {
        List<News> news = newsRepository.findAllByActiveTrueOrderByPublishedAtDesc();
        return ResponseEntity.ok(ApiResponse.success("Active news", news));
    }
}
