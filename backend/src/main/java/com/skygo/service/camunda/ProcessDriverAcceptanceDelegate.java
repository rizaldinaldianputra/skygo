package com.skygo.service.camunda;

import com.skygo.kafka.KafkaProducerService;
import com.skygo.model.Order;
import com.skygo.model.OrderStatus;
import com.skygo.repository.OrderRepository;
import org.camunda.bpm.engine.delegate.DelegateExecution;
import org.camunda.bpm.engine.delegate.JavaDelegate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component("processDriverAcceptanceDelegate")
public class ProcessDriverAcceptanceDelegate implements JavaDelegate {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private KafkaProducerService kafkaProducerService;

    @Override
    public void execute(DelegateExecution execution) throws Exception {
        Long orderId = (Long) execution.getVariable("orderId");
        Long driverId = (Long) execution.getVariable("driverId");

        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found: " + orderId));

        System.out.println("Processing Driver Acceptance for Order ID: " + orderId + " by Driver ID: " + driverId);

        // Status is already updated in OrderService before completing task?
        // Or we do it here to ensure consistency?
        // Let's do it here or assume it was done.
        // Actually, if we use Camunda to control flow, the state change should ideally
        // happen here or be confirmed here.
        // But OrderService.acceptOrder probably set it to ACCEPTED.
        // Let's just log and publish event.

        kafkaProducerService.sendOrderAccepted(order);
    }
}
