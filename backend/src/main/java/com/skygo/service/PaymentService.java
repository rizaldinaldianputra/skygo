package com.skygo.service;

import com.skygo.model.*;
import com.skygo.model.dto.PaymentRequest;
import com.skygo.model.dto.PaymentResponse;
import com.skygo.repository.OrderRepository;
import com.skygo.repository.PaymentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PaymentService {

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private OrderRepository orderRepository;

    public PaymentResponse createPayment(PaymentRequest request) {
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (paymentRepository.findByOrder(order).isPresent()) {
            // Handle existing payment if needed
        }

        Payment payment = new Payment();
        payment.setOrder(order);
        payment.setAmount(order.getEstimatedPrice());
        payment.setPaymentMethod(PaymentMethodType.CASH); // Force CASH or use request.getPaymentMethod() if validates
                                                          // to
        // CASH
        payment.setStatus(PaymentStatus.PENDING);

        // Since we only support CASH now
        paymentRepository.save(payment);
        return PaymentResponse.builder()
                .paymentMethod("CASH")
                .status("PENDING")
                .build();
    }
}
