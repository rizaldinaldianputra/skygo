package com.skygo.service;

import com.skygo.model.ChatMessage;
import com.skygo.model.dto.ChatMessageDTO;
import com.skygo.repository.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;

    /**
     * Save a chat message to the database and return the persisted entity.
     */
    public ChatMessage saveMessage(ChatMessageDTO dto) {
        ChatMessage msg = new ChatMessage();
        msg.setOrderId(dto.getOrderId());
        msg.setSenderType(dto.getSenderType());
        msg.setSenderId(dto.getSenderId());
        msg.setSenderName(dto.getSenderName());
        msg.setMessage(dto.getMessage());
        return chatMessageRepository.save(msg);
    }

    /**
     * Get all chat messages for an order, sorted by timestamp ascending.
     */
    public List<ChatMessage> getChatHistory(Long orderId) {
        return chatMessageRepository.findByOrderIdOrderByTimestampAsc(orderId);
    }
}
