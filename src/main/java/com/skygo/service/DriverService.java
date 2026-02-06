package com.skygo.service;

import com.skygo.model.Driver;
import com.skygo.model.DriverAvailability;
import com.skygo.repository.DriverRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class DriverService {

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private TrackingService trackingService;

    public void setDriverAvailability(Long driverId, boolean isOnline) {
        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new RuntimeException("Driver not found"));

        if (isOnline) {
            driver.setAvailability(DriverAvailability.ONLINE);
        } else {
            driver.setAvailability(DriverAvailability.OFFLINE);
            trackingService.removeDriverFromGeo(driverId);
        }
        driverRepository.save(driver);
    }
}
