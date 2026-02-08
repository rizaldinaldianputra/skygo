package com.skygo.kafka;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class KafkaProducerService {

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    public void sendOrderCreated(Object order) {
        kafkaTemplate.send("order.created", order);
    }

    public void sendOrderAccepted(Object order) {
        kafkaTemplate.send("order.accepted", order);
    }
}
