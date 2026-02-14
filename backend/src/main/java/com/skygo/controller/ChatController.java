package com.skygo.controller;

import com.skygo.model.ChatMessage;
import com.skygo.model.dto.ChatMessageDTO;
import com.skygo.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    /**
     * STOMP endpoint: client sends to /app/chat.send/{orderId}
     * Message is saved to DB then broadcast to /topic/chat/{orderId}
     */
    @MessageMapping("/chat.send/{orderId}")
    @SendTo("/topic/chat/{orderId}")
    public ChatMessage sendMessage(
            @DestinationVariable Long orderId,
            ChatMessageDTO dto) {
        dto.setOrderId(orderId);
        return chatService.saveMessage(dto);
    }

    /**
     * REST endpoint to fetch chat history for an order.
     */
    @GetMapping("/api/chat/{orderId}")
    public ResponseEntity<List<ChatMessage>> getChatHistory(@PathVariable Long orderId) {
        return ResponseEntity.ok(chatService.getChatHistory(orderId));
    }
}
