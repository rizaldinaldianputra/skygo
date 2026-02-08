package com.skygo.kafka;

import com.skygo.model.Order;
import com.skygo.service.MatchingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class KafkaConsumerService {

    @Autowired
    private MatchingService matchingService;

    @KafkaListener(topics = "order.created", groupId = "skygo-group")
    public void consumeOrderCreated(Order order) {
        System.out.println("Received Order Created Event: " + order.getId());
        matchingService.findDrivers(order);
    }

    @KafkaListener(topics = "order.accepted", groupId = "skygo-group")
    public void consumeOrderAccepted(Order order) {
        System.out.println("Received Order Accepted Event: " + order.getId());
        // Handle post-acceptance logic if any (e.g. analytics, further notifications)
    }
}
