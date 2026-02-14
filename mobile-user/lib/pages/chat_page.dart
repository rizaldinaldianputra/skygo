import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart';
import '../session/session_manager.dart';

/// ChatPage — Real-time chat between user and driver for a specific order.
/// Styled like a modern messaging app (Gojek-style).
class ChatPage extends StatefulWidget {
  final int orderId;
  final String driverName;

  const ChatPage({super.key, required this.orderId, required this.driverName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final SessionManager _sessionManager = SessionManager();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  String? _userId;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    _userId = await _sessionManager.getUserId();
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? 'User';

    // Load chat history first
    final history = await _chatService.getChatHistory(widget.orderId);
    if (mounted) {
      setState(() {
        _messages.addAll(history);
        _isLoading = false;
      });
      _scrollToBottom();
    }

    // Connect WebSocket and listen for new messages
    _chatService.onMessageReceived = (data) {
      if (mounted) {
        setState(() {
          _messages.add(data);
        });
        _scrollToBottom();
      }
    };
    await _chatService.connectAndSubscribe(widget.orderId);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null) return;

    _chatService.sendMessage(
      orderId: widget.orderId,
      senderType: 'USER',
      senderId: int.parse(_userId!),
      senderName: _userName ?? 'User',
      message: text,
    );

    _messageController.clear();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatService.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00880A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.driverName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Driver',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFECE5DD)),
        child: Column(
          children: [
            // Order info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFFF3CD),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF856404),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chat untuk Order #${widget.orderId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF856404),
                    ),
                  ),
                ],
              ),
            ),
            // Chat messages
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada pesan',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Mulai chat dengan driver kamu!',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Ketik pesan...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00880A),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['senderType'] == 'USER';
    final time = _formatTime(msg['timestamp']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg['senderName'] ?? 'Driver',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00880A),
                  ),
                ),
              ),
            Text(msg['message'] ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is String) {
        final dt = DateTime.parse(timestamp);
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      // Spring Boot LocalDateTime serializes as array [year, month, day, hour, minute, second]
      if (timestamp is List && timestamp.length >= 5) {
        return '${timestamp[3].toString().padLeft(2, '0')}:${timestamp[4].toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return '';
  }
}
