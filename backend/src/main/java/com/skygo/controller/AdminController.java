package com.skygo.controller;

import com.skygo.model.*;
import com.skygo.model.dto.ApiResponse;
import com.skygo.repository.*;
import com.skygo.service.MinioService;
import com.skygo.service.TrackingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.*;

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
    private PaymentMethodRepository paymentMethodRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private DriverRepository driverRepository;
    @Autowired
    private OrderRepository orderRepository;
    @Autowired
    private DiscountRepository discountRepository;
    @Autowired
    private TrackingService trackingService;
    @Autowired
    private MinioService minioService;

    // --- Common Image Upload ---
    @PostMapping("/upload")
    public ResponseEntity<ApiResponse<String>> uploadImage(@RequestParam("file") MultipartFile file) {
        String url = minioService.uploadFile(file, "admin-assets");
        return ResponseEntity.ok(ApiResponse.success("Uploaded", url));
    }

    // ===================== BANNERS =====================
    @GetMapping("/banners")
    public ResponseEntity<ApiResponse<Page<Banner>>> getBanners(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Banners fetched", bannerRepository.findAll(pageable)));
    }

    @PostMapping("/banners")
    public ResponseEntity<ApiResponse<Banner>> createBanner(@RequestBody Banner banner) {
        return ResponseEntity.ok(ApiResponse.success(bannerRepository.save(banner)));
    }

    @PutMapping("/banners/{id}")
    public ResponseEntity<ApiResponse<Banner>> updateBanner(@PathVariable Long id, @RequestBody Banner banner) {
        Banner existing = bannerRepository.findById(id).orElseThrow(() -> new RuntimeException("Banner not found"));
        existing.setTitle(banner.getTitle());
        existing.setImageUrl(banner.getImageUrl());
        existing.setActionUrl(banner.getActionUrl());
        existing.setDisplayOrder(banner.getDisplayOrder());
        existing.setActive(banner.isActive());
        return ResponseEntity.ok(ApiResponse.success(bannerRepository.save(existing)));
    }

    @DeleteMapping("/banners/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteBanner(@PathVariable Long id) {
        bannerRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    // ===================== NEWS =====================
    @GetMapping("/news")
    public ResponseEntity<ApiResponse<Page<News>>> getNews(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("News fetched", newsRepository.findAll(pageable)));
    }

    @PostMapping("/news")
    public ResponseEntity<ApiResponse<News>> createNews(@RequestBody News news) {
        return ResponseEntity.ok(ApiResponse.success(newsRepository.save(news)));
    }

    @PutMapping("/news/{id}")
    public ResponseEntity<ApiResponse<News>> updateNews(@PathVariable Long id, @RequestBody News news) {
        News existing = newsRepository.findById(id).orElseThrow(() -> new RuntimeException("News not found"));
        existing.setTitle(news.getTitle());
        existing.setContent(news.getContent());
        existing.setImageUrl(news.getImageUrl());
        existing.setActive(news.isActive());
        return ResponseEntity.ok(ApiResponse.success(newsRepository.save(existing)));
    }

    @DeleteMapping("/news/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteNews(@PathVariable Long id) {
        newsRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    // ===================== PROMOS =====================
    @GetMapping("/promos")
    public ResponseEntity<ApiResponse<Page<Promo>>> getPromos(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Promos fetched", promoRepository.findAll(pageable)));
    }

    @PostMapping("/promos")
    public ResponseEntity<ApiResponse<Promo>> createPromo(@RequestBody Promo promo) {
        return ResponseEntity.ok(ApiResponse.success(promoRepository.save(promo)));
    }

    @PutMapping("/promos/{id}")
    public ResponseEntity<ApiResponse<Promo>> updatePromo(@PathVariable Long id, @RequestBody Promo promo) {
        Promo existing = promoRepository.findById(id).orElseThrow(() -> new RuntimeException("Promo not found"));
        existing.setTitle(promo.getTitle());
        existing.setDescription(promo.getDescription());
        existing.setImageUrl(promo.getImageUrl());
        existing.setCode(promo.getCode());
        existing.setDiscountAmount(promo.getDiscountAmount());
        existing.setDiscountType(promo.getDiscountType());
        existing.setActive(promo.isActive());
        return ResponseEntity.ok(ApiResponse.success(promoRepository.save(existing)));
    }

    @DeleteMapping("/promos/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePromo(@PathVariable Long id) {
        promoRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    // ===================== PAYMENT METHODS =====================
    @GetMapping("/payment-methods")
    public ResponseEntity<ApiResponse<Page<PaymentMethod>>> getPaymentMethods(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Payment methods fetched",
                paymentMethodRepository.findAll(pageable)));
    }

    @PostMapping("/payment-methods")
    public ResponseEntity<ApiResponse<PaymentMethod>> createPaymentMethod(@RequestBody PaymentMethod method) {
        return ResponseEntity.ok(ApiResponse.success(paymentMethodRepository.save(method)));
    }

    @PutMapping("/payment-methods/{id}")
    public ResponseEntity<ApiResponse<PaymentMethod>> updatePaymentMethod(@PathVariable Long id,
            @RequestBody PaymentMethod method) {
        PaymentMethod existing = paymentMethodRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Payment Method not found"));
        existing.setCode(method.getCode());
        existing.setName(method.getName());
        existing.setType(method.getType());
        existing.setDescription(method.getDescription());
        existing.setInstructions(method.getInstructions());
        existing.setImageUrl(method.getImageUrl());
        existing.setActive(method.isActive());
        return ResponseEntity.ok(ApiResponse.success(paymentMethodRepository.save(existing)));
    }

    @DeleteMapping("/payment-methods/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePaymentMethod(@PathVariable Long id) {
        paymentMethodRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    // ===================== USERS =====================
    @GetMapping("/users")
    public ResponseEntity<ApiResponse<Page<User>>> getUsers(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Users fetched", userRepository.findAll(pageable)));
    }

    // ===================== ALL DRIVERS (Admin view) =====================
    @GetMapping("/drivers")
    public ResponseEntity<ApiResponse<Page<Driver>>> getDrivers(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Drivers fetched", driverRepository.findAll(pageable)));
    }

    // ===================== ALL ORDERS (Admin view) =====================
    @GetMapping("/orders")
    public ResponseEntity<ApiResponse<Page<Order>>> getOrders(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Orders fetched", orderRepository.findAll(pageable)));
    }

    // ===================== ALL DISCOUNTS (Admin view) =====================
    @GetMapping("/discounts")
    public ResponseEntity<ApiResponse<Page<Discount>>> getDiscounts(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success("Discounts fetched", discountRepository.findAll(pageable)));
    }

    // ===================== ONLINE DRIVERS (for monitoring) =====================
    @GetMapping("/online-drivers")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getOnlineDriversWithLocation() {
        List<Driver> onlineDrivers = driverRepository.findAllByAvailability(DriverAvailability.ONLINE);
        List<Driver> onTripDrivers = driverRepository.findAllByAvailability(DriverAvailability.ON_TRIP);

        List<Map<String, Object>> result = new ArrayList<>();

        // Combine online + on_trip drivers
        List<Driver> allActive = new ArrayList<>(onlineDrivers);
        allActive.addAll(onTripDrivers);

        for (Driver driver : allActive) {
            Map<String, Double> location = trackingService.getDriverLocation(driver.getId());
            Map<String, Object> driverData = new HashMap<>();
            driverData.put("id", driver.getId());
            driverData.put("name", driver.getName());
            driverData.put("phone", driver.getPhone());
            driverData.put("vehicleType", driver.getVehicleType());
            driverData.put("vehiclePlate", driver.getVehiclePlate());
            driverData.put("availability", driver.getAvailability().name());
            driverData.put("rating", driver.getRating());
            if (location != null) {
                driverData.put("lat", location.get("lat"));
                driverData.put("lng", location.get("lng"));
            }
            result.add(driverData);
        }

        return ResponseEntity.ok(ApiResponse.success("Online drivers", result));
    }

    // ===================== DASHBOARD STATS =====================
    @GetMapping("/dashboard-stats")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();

        // Counts
        stats.put("totalDrivers", driverRepository.count());
        stats.put("totalUsers", userRepository.count());
        stats.put("totalOrders", orderRepository.count());
        stats.put("totalDiscounts", discountRepository.count());
        stats.put("totalBanners", bannerRepository.count());
        stats.put("totalNews", newsRepository.count());
        stats.put("totalPromos", promoRepository.count());
        stats.put("totalPaymentMethods", paymentMethodRepository.count());

        // Online / on-trip driver counts
        long onlineDrivers = driverRepository.findAllByAvailability(DriverAvailability.ONLINE).size();
        long onTripDrivers = driverRepository.findAllByAvailability(DriverAvailability.ON_TRIP).size();
        stats.put("onlineDrivers", onlineDrivers);
        stats.put("onTripDrivers", onTripDrivers);

        // Weekly order data for charts (last 7 days)
        List<Map<String, Object>> weeklyOrders = new ArrayList<>();
        java.time.LocalDate today = java.time.LocalDate.now();
        String[] dayNames = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" };

        for (int i = 6; i >= 0; i--) {
            java.time.LocalDate date = today.minusDays(i);
            java.time.LocalDateTime startOfDay = date.atStartOfDay();
            java.time.LocalDateTime endOfDay = date.atTime(23, 59, 59);

            long orderCount = orderRepository.countByCreatedAtBetween(startOfDay, endOfDay);

            Map<String, Object> dayData = new HashMap<>();
            dayData.put("name", dayNames[date.getDayOfWeek().getValue() - 1]);
            dayData.put("date", date.toString());
            dayData.put("orders", orderCount);
            weeklyOrders.add(dayData);
        }
        stats.put("weeklyOrders", weeklyOrders);

        return ResponseEntity.ok(ApiResponse.success("Dashboard stats", stats));
    }
}
