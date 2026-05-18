import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'socket_service.dart';
import 'auth_service.dart';
import '../config/env.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final SocketService socketService;
  final String peerSocketId;
  final List<RTCIceCandidate> _pendingCandidates = [];

  WebRTCService({required this.socketService, required this.peerSocketId});

  Future<Map<String, dynamic>> _fetchIceConfig() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${Env.serverUrl}/turn-credentials'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    // fallback to STUN only
    return {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };
  }

  Future<void> init({required bool isOffer}) async {
    final iceConfig = await _fetchIceConfig();
    _localStream = await mediaDevices.getUserMedia({'audio': true, 'video': false});
    _peerConnection = await createPeerConnection(iceConfig);

    for (final track in _localStream!.getTracks()) {
      _peerConnection!.addTrack(track, _localStream!);
    }

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        socketService.sendIceCandidate(peerSocketId, candidate.toMap());
      }
    };

    _peerConnection!.onIceConnectionState = (state) {
      debugPrint('[WebRTC] ICE: $state');
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
    await _flushPendingCandidates();
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    socketService.sendAnswer(peerSocketId, answer.toMap());
  }

  Future<void> handleAnswer(dynamic sdp) async {
    await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']));
    await _flushPendingCandidates();
  }

  Future<void> addIceCandidate(dynamic candidate) async {
    final c = RTCIceCandidate(
        candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']);
    final remoteDesc = await _peerConnection!.getRemoteDescription();
    if (remoteDesc == null) {
      _pendingCandidates.add(c);
    } else {
      await _peerConnection!.addCandidate(c);
    }
  }

  Future<void> _flushPendingCandidates() async {
    for (final c in _pendingCandidates) {
      await _peerConnection!.addCandidate(c);
    }
    _pendingCandidates.clear();
  }

  void toggleMute(bool mute) {
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !mute);
  }

  Future<void> dispose() async {
    _pendingCandidates.clear();
    await _localStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
  }
}
