package com.skygo.model.dto;

import com.skygo.model.PaymentMethod;
import lombok.Data;

@Data
public class PaymentRequest {
    private Long orderId;
    private PaymentMethod paymentMethod;
}
