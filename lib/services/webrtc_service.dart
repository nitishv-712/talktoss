import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'socket_service.dart';
import '../config/env.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final SocketService socketService;
  final String peerSocketId;

  WebRTCService({required this.socketService, required this.peerSocketId});

  Map<String, dynamic> get _iceConfig => {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {
        'urls': Env.turnUrl,
        'username': Env.turnUsername,
        'credential': Env.turnCredential,
      },
    ]
  };

  Future<void> init({required bool isOffer}) async {
    _localStream = await mediaDevices.getUserMedia({'audio': true, 'video': false});
    _peerConnection = await createPeerConnection(_iceConfig);

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onIceCandidate = (candidate) {
      socketService.sendIceCandidate(peerSocketId, candidate.toMap());
    };

    if (isOffer) {
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      socketService.sendOffer(peerSocketId, offer.toMap());
    }
  }

  Future<void> handleOffer(dynamic sdp) async {
    await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']));
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    socketService.sendAnswer(peerSocketId, answer.toMap());
  }

  Future<void> handleAnswer(dynamic sdp) async {
    await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']));
  }

  Future<void> addIceCandidate(dynamic candidate) async {
    await _peerConnection!.addCandidate(RTCIceCandidate(
        candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']));
  }

  void toggleMute(bool mute) {
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !mute);
  }

  Future<void> dispose() async {
    await _localStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
  }
}
