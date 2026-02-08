package com.skygo.service.camunda;

import com.skygo.kafka.KafkaProducerService;
import com.skygo.model.Order;
import com.skygo.model.OrderStatus;
import com.skygo.repository.OrderRepository;
import org.camunda.bpm.engine.delegate.DelegateExecution;
import org.camunda.bpm.engine.delegate.JavaDelegate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component("publishOrderCreatedDelegate")
public class PublishOrderCreatedDelegate implements JavaDelegate {

    @Autowired
    private KafkaProducerService kafkaProducerService;

    @Autowired
    private OrderRepository orderRepository;

    @Override
    public void execute(DelegateExecution execution) throws Exception {
        Long orderId = (Long) execution.getVariable("orderId");
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found: " + orderId));

        System.out.println("Publishing Order Created Event for Order ID: " + orderId);
        kafkaProducerService.sendOrderCreated(order);
    }
}
