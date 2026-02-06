package com.skygo.service;

import com.skygo.model.GlobalConfig;
import com.skygo.repository.GlobalConfigRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GlobalConfigService {

    private final GlobalConfigRepository configRepository;
    private static final String POINTS_PER_ORDER_KEY = "POINTS_PER_ORDER";

    public int getPointsPerOrder() {
        return configRepository.findById(POINTS_PER_ORDER_KEY)
                .map(config -> Integer.parseInt(config.getConfigValue()))
                .orElse(0); // Default to 0 if not set
    }

    public void setPointsPerOrder(int points) {
        GlobalConfig config = new GlobalConfig(POINTS_PER_ORDER_KEY, String.valueOf(points));
        configRepository.save(config);
    }
}
