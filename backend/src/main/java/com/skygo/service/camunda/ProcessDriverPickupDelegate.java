package com.skygo.service.camunda;

import com.skygo.model.Order;
import com.skygo.model.OrderStatus;
import com.skygo.repository.OrderRepository;
import org.camunda.bpm.engine.delegate.DelegateExecution;
import org.camunda.bpm.engine.delegate.JavaDelegate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component("processDriverPickupDelegate")
public class ProcessDriverPickupDelegate implements JavaDelegate {

    @Autowired
    private OrderRepository orderRepository;

    @Override
    public void execute(DelegateExecution execution) throws Exception {
        Long orderId = (Long) execution.getVariable("orderId");

        System.out.println("Processing Driver Pickup (Start Trip) for Order ID: " + orderId);

        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found: " + orderId));

        if (order.getStatus() != OrderStatus.ON_TRIP) {
            order.setStatus(OrderStatus.ON_TRIP);
            orderRepository.save(order);
        }

        // kafkaProducerService.sendOrderPickedUp(order);
    }
}
