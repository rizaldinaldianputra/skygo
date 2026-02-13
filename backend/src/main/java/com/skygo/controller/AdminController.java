package com.skygo.controller;

import com.skygo.model.*;
import com.skygo.model.dto.ApiResponse;
import com.skygo.repository.*;
import com.skygo.service.MinioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private BannerRepository bannerRepository;
    @Autowired
    private NewsRepository newsRepository;
    @Autowired
    private PromoRepository promoRepository;
    @Autowired
    private ServiceRepository serviceRepository;
    @Autowired
    private PaymentMethodRepository paymentMethodRepository;
    @Autowired
    private MinioService minioService;

    // --- Common Image Upload ---
    @PostMapping("/upload")
    public ResponseEntity<ApiResponse<String>> uploadImage(@RequestParam("file") MultipartFile file) {
        String url = minioService.uploadFile(file, "admin-assets");
        return ResponseEntity.ok(ApiResponse.success("Uploaded", url));
    }

    // --- Banners ---
    @GetMapping("/banners")
    public ResponseEntity<ApiResponse<List<Banner>>> getBanners() {
        return ResponseEntity.ok(ApiResponse.success(bannerRepository.findAll()));
    }

    @PostMapping("/banners")
    public ResponseEntity<ApiResponse<Banner>> createBanner(@RequestBody Banner banner) {
        return ResponseEntity.ok(ApiResponse.success(bannerRepository.save(banner)));
    }

    @DeleteMapping("/banners/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteBanner(@PathVariable Long id) {
        bannerRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    // --- News ---
    @GetMapping("/news")
    public ResponseEntity<ApiResponse<List<News>>> getNews() {
        return ResponseEntity.ok(ApiResponse.success(newsRepository.findAll()));
    }

    @PostMapping("/news")
    public ResponseEntity<ApiResponse<News>> createNews(@RequestBody News news) {
        return ResponseEntity.ok(ApiResponse.success(newsRepository.save(news)));
    }

    @DeleteMapping("/news/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteNews(@PathVariable Long id) {
        newsRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    // --- Promos ---
    @GetMapping("/promos")
    public ResponseEntity<ApiResponse<List<Promo>>> getPromos() {
        return ResponseEntity.ok(ApiResponse.success(promoRepository.findAll()));
    }

    @PostMapping("/promos")
    public ResponseEntity<ApiResponse<Promo>> createPromo(@RequestBody Promo promo) {
        return ResponseEntity.ok(ApiResponse.success(promoRepository.save(promo)));
    }

    @DeleteMapping("/promos/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePromo(@PathVariable Long id) {
        promoRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    // --- Services ---
    @GetMapping("/services")
    public ResponseEntity<ApiResponse<List<ServiceEntity>>> getServices() {
        return ResponseEntity.ok(ApiResponse.success(serviceRepository.findAll()));
    }

    @PostMapping("/services")
    public ResponseEntity<ApiResponse<ServiceEntity>> createService(@RequestBody ServiceEntity service) {
        return ResponseEntity.ok(ApiResponse.success(serviceRepository.save(service)));
    }

    @DeleteMapping("/services/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteService(@PathVariable Long id) {
        serviceRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    // --- Payment Methods ---
    @GetMapping("/payment-methods")
    public ResponseEntity<ApiResponse<List<PaymentMethod>>> getPaymentMethods() {
        return ResponseEntity.ok(ApiResponse.success(paymentMethodRepository.findAll()));
    }

    @PostMapping("/payment-methods")
    public ResponseEntity<ApiResponse<PaymentMethod>> createPaymentMethod(@RequestBody PaymentMethod method) {
        return ResponseEntity.ok(ApiResponse.success(paymentMethodRepository.save(method)));
    }

    @DeleteMapping("/payment-methods/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePaymentMethod(@PathVariable Long id) {
        paymentMethodRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }
}
