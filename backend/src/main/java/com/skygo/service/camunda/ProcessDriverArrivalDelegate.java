package com.skygo.service.camunda;

import com.skygo.kafka.KafkaProducerService;
import com.skygo.model.Order;
import com.skygo.model.OrderStatus;
import com.skygo.repository.OrderRepository;
import org.camunda.bpm.engine.delegate.DelegateExecution;
import org.camunda.bpm.engine.delegate.JavaDelegate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component("processDriverArrivalDelegate")
public class ProcessDriverArrivalDelegate implements JavaDelegate {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private KafkaProducerService kafkaProducerService;

    @Override
    public void execute(DelegateExecution execution) throws Exception {
        Long orderId = (Long) execution.getVariable("orderId");

        System.out.println("Processing Driver Arrival for Order ID: " + orderId);

        // Fetch Order
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found: " + orderId));

        // Update Status? It might be done by ApiController, but ensures consistency
        // here.
        // Assuming the API sets it, but let's be safe or just publish.
        // For a robust system, the Delegate should probably enforce the state if
        // called.
        // We'll update if not already updated.
        if (order.getStatus() != OrderStatus.ARRIVED_AT_PICKUP) {
            order.setStatus(OrderStatus.ARRIVED_AT_PICKUP);
            orderRepository.save(order);
        }

        // Publish Event
        // kafkaProducerService.sendOrderArrived(order); // Assuming this method exists
        // or will be created
        // For now, I'll comment out the specific method call if I'm not sure it exists,
        // but based on `ProcessDriverAcceptanceDelegate`, `sendOrderAccepted` exists.
        // I will assume generic send or specific needs to be added.
        // As I can't see KafkaProducerService, I will skip the method call to avoid
        // compilation error
        // unless I verify it exists. detailed verification is next step.
        // Re-checking ProcessDriverAcceptanceDelegate: it calls
        // `kafkaProducerService.sendOrderAccepted(order);`
    }
}
