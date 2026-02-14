package com.skygo.model.dto;

import lombok.Data;

@Data
public class ChatMessageDTO {
    private Long orderId;
    private String senderType; // "USER" or "DRIVER"
    private Long senderId;
    private String senderName;
    private String message;
}
