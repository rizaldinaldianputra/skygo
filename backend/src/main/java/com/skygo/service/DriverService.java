package com.skygo.service;

import com.skygo.dto.DriverRegistrationRequest;
import com.skygo.model.Driver;
import com.skygo.model.DriverAvailability;
import com.skygo.model.DriverStatus;
import com.skygo.repository.DriverRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class DriverService {

    private final DriverRepository driverRepository;
    private final MinioService minioService;
    // private final PasswordEncoder passwordEncoder; // Assuming we might need this
    // later

    @Transactional
    public Driver registerDriver(DriverRegistrationRequest request) {
        // Validate required fields
        if (request.getPhone() == null || request.getPhone().isEmpty()) {
            throw new IllegalArgumentException("Phone number is required");
        }
        if (request.getKtpNumber() == null || request.getKtpNumber().isEmpty()) {
            throw new IllegalArgumentException("KTP Number is required");
        }
        if (request.getSimNumber() == null || request.getSimNumber().isEmpty()) {
            throw new IllegalArgumentException("SIM Number is required");
        }
        if (request.getName() == null || request.getName().isEmpty()) {
            throw new IllegalArgumentException("Name is required");
        }
        if (request.getEmail() == null || request.getEmail().isEmpty()) {
            throw new IllegalArgumentException("Email is required");
        }

        // validate email/phone uniqueness if needed
        if (driverRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered");
        }
        if (driverRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Phone already registered");
        }

        Driver driver = new Driver();
        driver.setName(request.getName());
        driver.setEmail(request.getEmail());
        driver.setPhone(request.getPhone());
        driver.setPassword(request.getPassword()); // In real app, hash this or offload to Keycloak
        driver.setVehicleType(request.getVehicleType());
        driver.setVehiclePlate(request.getVehiclePlate());
        driver.setKtpNumber(request.getKtpNumber());
        driver.setSimNumber(request.getSimNumber());
        if (request.getFcmToken() != null && !request.getFcmToken().isEmpty()) {
            driver.setFcmToken(request.getFcmToken());
        }
        driver.setStatus(DriverStatus.PENDING);
        driver.setAvailability(DriverAvailability.OFFLINE);

        // Upload files
        if (request.getSim() != null && !request.getSim().isEmpty()) {
            String simUrl = minioService.uploadFile(request.getSim(), "drivers/sim");
            driver.setSimUrl(simUrl);
        }

        if (request.getKtp() != null && !request.getKtp().isEmpty()) {
            String ktpUrl = minioService.uploadFile(request.getKtp(), "drivers/ktp");
            driver.setKtpUrl(ktpUrl);
        }

        if (request.getPhoto() != null && !request.getPhoto().isEmpty()) {
            String photoUrl = minioService.uploadFile(request.getPhoto(), "drivers/photo");
            driver.setPhotoUrl(photoUrl);
        }

        return driverRepository.save(driver);
    }

    @Transactional
    public void updateFcmToken(Long driverId, String fcmToken) {
        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new RuntimeException("Driver not found"));
        driver.setFcmToken(fcmToken);
        driverRepository.save(driver);
    }

    @Transactional
    public Driver updateDriverStatus(Long driverId, DriverStatus status) {
        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new RuntimeException("Driver not found"));
        driver.setStatus(status);
        return driverRepository.save(driver);
    }

    @Transactional
    public void setDriverAvailability(Long driverId, boolean available) {
        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new RuntimeException("Driver not found"));
        driver.setAvailability(available ? DriverAvailability.ONLINE : DriverAvailability.OFFLINE);
        driverRepository.save(driver);
    }

    public java.util.List<Driver> getPendingDrivers() {
        return driverRepository.findAllByStatus(DriverStatus.PENDING);
    }

    public org.springframework.data.domain.Page<Driver> getPendingDrivers(
            org.springframework.data.domain.Pageable pageable) {
        return driverRepository.findAllByStatus(DriverStatus.PENDING, pageable);
    }
}
