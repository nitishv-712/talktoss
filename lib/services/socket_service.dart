import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/env.dart';

class SocketService {
  late IO.Socket socket;

  void connect(String token) {
    socket = IO.io(Env.serverUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .build());
    socket.connect();
  }

  void joinQueue(String userId) => socket.emit('join_queue', {'userId': userId});

  void sendOffer(String targetSocketId, dynamic sdp) =>
      socket.emit('offer', {'targetSocketId': targetSocketId, 'sdp': sdp});

  void sendAnswer(String targetSocketId, dynamic sdp) =>
      socket.emit('answer', {'targetSocketId': targetSocketId, 'sdp': sdp});

  void sendIceCandidate(String targetSocketId, dynamic candidate) =>
      socket.emit('ice_candidate', {'targetSocketId': targetSocketId, 'candidate': candidate});

  void endCall(String targetSocketId, String? callId) => 
      socket.emit('call_end', {'targetSocketId': targetSocketId, 'callId': callId});

  void on(String event, Function(dynamic) handler) => socket.on(event, handler);

  void off(String event) => socket.off(event);

  void disconnect() => socket.disconnect();
}
