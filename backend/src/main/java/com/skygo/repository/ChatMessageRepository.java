package com.skygo.repository;

import com.skygo.model.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByOrderIdOrderByTimestampAsc(Long orderId);
}
