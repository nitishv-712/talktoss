import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/env.dart';

class SocketService {
  io.Socket? _socket;

  io.Socket get socket => _socket!;

  bool get isConnected => _socket != null && (_socket!.connected);

  void connect(String token) {
    _socket = io.io(Env.serverUrl, io.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .build());
    _socket!.connect();
  }

  void sendOffer(String targetSocketId, dynamic sdp) =>
      socket.emit('offer', {'targetSocketId': targetSocketId, 'sdp': sdp});

  void sendAnswer(String targetSocketId, dynamic sdp) =>
      socket.emit('answer', {'targetSocketId': targetSocketId, 'sdp': sdp});

  void sendIceCandidate(String targetSocketId, dynamic candidate) =>
      socket.emit('ice_candidate', {'targetSocketId': targetSocketId, 'candidate': candidate});

  void endCall(String targetSocketId) =>
      socket.emit('call_end', {'targetSocketId': targetSocketId});

  void on(String event, Function(dynamic) handler) => _socket?.on(event, handler);

  void off(String event) => _socket?.off(event);

  void disconnect() => _socket?.disconnect();
}
