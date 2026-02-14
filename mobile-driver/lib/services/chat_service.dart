import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../session/session_manager.dart';

/// ChatService handles WebSocket STOMP connection for real-time chat
/// and REST calls for fetching chat history (Driver side).
class ChatService {
  StompClient? _stompClient;
  final SessionManager _sessionManager = SessionManager();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Callback when a new chat message is received.
  Function(Map<String, dynamic> messageData)? onMessageReceived;

  /// Connect to WebSocket and subscribe to chat topic for the given order.
  Future<void> connectAndSubscribe(int orderId) async {
    if (_stompClient != null && _isConnected) {
      _subscribeToChat(orderId);
      return;
    }

    final baseUri = Uri.parse(ApiConfig.baseUrl);

    print('[ChatService-Driver] Connecting to WS for chat on order $orderId');

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: 'http://${baseUri.host}:${baseUri.port}/ws-ojek',
        onConnect: (StompFrame frame) {
          _isConnected = true;
          print('[ChatService-Driver] Connected! Subscribing to chat/$orderId');
          _subscribeToChat(orderId);
        },
        onDisconnect: (StompFrame frame) {
          _isConnected = false;
          print('[ChatService-Driver] Disconnected');
        },
        onStompError: (StompFrame frame) {
          print('[ChatService-Driver] STOMP Error: ${frame.body}');
        },
        onWebSocketError: (dynamic error) {
          _isConnected = false;
          print('[ChatService-Driver] WebSocket Error: $error');
        },
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  void _subscribeToChat(int orderId) {
    _stompClient?.subscribe(
      destination: '/topic/chat/$orderId',
      callback: (StompFrame frame) {
        print('[ChatService-Driver] Message received: ${frame.body}');
        if (frame.body != null && onMessageReceived != null) {
          try {
            final data = jsonDecode(frame.body!) as Map<String, dynamic>;
            onMessageReceived!(data);
          } catch (e) {
            print('[ChatService-Driver] Error parsing message: $e');
          }
        }
      },
    );
  }

  /// Send a chat message via STOMP.
  void sendMessage({
    required int orderId,
    required String senderType,
    required int senderId,
    required String senderName,
    required String message,
  }) {
    if (_stompClient == null || !_isConnected) {
      print('[ChatService-Driver] Cannot send - not connected');
      return;
    }

    final body = jsonEncode({
      'orderId': orderId,
      'senderType': senderType,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
    });

    _stompClient!.send(destination: '/app/chat.send/$orderId', body: body);

    print('[ChatService-Driver] Message sent to order $orderId');
  }

  /// Fetch chat history via REST API.
  Future<List<Map<String, dynamic>>> getChatHistory(int orderId) async {
    try {
      final token = await _sessionManager.getToken();
      final dio = Dio();
      final baseUri = Uri.parse(ApiConfig.baseUrl);
      final response = await dio.get(
        '${baseUri.origin}/api/chat/$orderId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('[ChatService-Driver] Error fetching chat history: $e');
      return [];
    }
  }

  /// Disconnect from WebSocket.
  void disconnect() {
    if (_stompClient != null) {
      print('[ChatService-Driver] Disconnecting...');
      _stompClient!.deactivate();
      _stompClient = null;
      _isConnected = false;
    }
  }

  void dispose() {
    disconnect();
    onMessageReceived = null;
  }
}
