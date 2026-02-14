import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../config/api_config.dart';
import '../session/session_manager.dart';

/// WebSocket service using STOMP protocol to listen for incoming orders.
/// Connects to backend's /ws-ojek endpoint and subscribes to
/// /topic/driver/{driverId}/orders for real-time order notifications.
class WebSocketService {
  StompClient? _stompClient;
  final SessionManager _sessionManager = SessionManager();

  /// Callback when a new order message is received via WebSocket.
  Function(Map<String, dynamic> orderData)? onOrderReceived;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Connect to WebSocket and subscribe to driver's order topic.
  Future<void> connect() async {
    if (_stompClient != null && _isConnected) {
      print('[WebSocketService] Already connected');
      return;
    }

    final driverId = await _sessionManager.getUserId();
    if (driverId == null) {
      print('[WebSocketService] Cannot connect - no driver ID');
      return;
    }

    // Build WebSocket URL from API base URL
    // ApiConfig.baseUrl = "http://192.168.1.5:8081/api"
    // We need: "ws://192.168.1.5:8081/ws-ojek/websocket"
    final baseUri = Uri.parse(ApiConfig.baseUrl);
    final wsUrl = 'ws://${baseUri.host}:${baseUri.port}/ws-ojek/websocket';

    print('[WebSocketService] Connecting to $wsUrl for driver $driverId');

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: 'http://${baseUri.host}:${baseUri.port}/ws-ojek',
        onConnect: (StompFrame frame) {
          _isConnected = true;
          print(
            '[WebSocketService] Connected! Subscribing to /topic/driver/$driverId/orders',
          );

          _stompClient!.subscribe(
            destination: '/topic/driver/$driverId/orders',
            callback: (StompFrame frame) {
              print('[WebSocketService] Order received: ${frame.body}');
              if (frame.body != null && onOrderReceived != null) {
                try {
                  final data = jsonDecode(frame.body!) as Map<String, dynamic>;
                  onOrderReceived!(data);
                } catch (e) {
                  print('[WebSocketService] Error parsing order data: $e');
                }
              }
            },
          );
        },
        onDisconnect: (StompFrame frame) {
          _isConnected = false;
          print('[WebSocketService] Disconnected');
        },
        onStompError: (StompFrame frame) {
          print('[WebSocketService] STOMP Error: ${frame.body}');
        },
        onWebSocketError: (dynamic error) {
          _isConnected = false;
          print('[WebSocketService] WebSocket Error: $error');
        },
        // Heartbeat every 10 seconds to keep connection alive
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        // Auto-reconnect every 5 seconds
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  /// Disconnect from WebSocket.
  void disconnect() {
    if (_stompClient != null) {
      print('[WebSocketService] Disconnecting...');
      _stompClient!.deactivate();
      _stompClient = null;
      _isConnected = false;
    }
  }

  /// Dispose — clean disconnect.
  void dispose() {
    disconnect();
    onOrderReceived = null;
  }
}
