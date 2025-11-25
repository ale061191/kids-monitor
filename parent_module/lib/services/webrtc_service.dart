import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../config/app_config.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _remoteStream;
  bool _isConnected = false;

  // Initialize WebRTC
  Future<void> initialize() async {
    try {
      _peerConnection = await createPeerConnection(
        AppConfig.iceServers,
        {
          'optional': [
            {'DtlsSrtpKeyAgreement': true},
          ],
        },
      );

      _peerConnection!.onIceCandidate = _onIceCandidate;
      _peerConnection!.onIceConnectionState = _onIceConnectionState;
      _peerConnection!.onAddStream = _onAddStream;
      _peerConnection!.onRemoveStream = _onRemoveStream;
    } catch (e) {
      throw Exception('Failed to initialize WebRTC: $e');
    }
  }

  // Event handlers
  void _onIceCandidate(RTCIceCandidate candidate) {
    // Send to signaling server
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    _isConnected = state == RTCIceConnectionState.RTCIceConnectionStateConnected;
  }

  void _onAddStream(MediaStream stream) {
    _remoteStream = stream;
  }

  void _onRemoveStream(MediaStream stream) {
    _remoteStream = null;
  }

  // Create offer
  Future<RTCSessionDescription> createOffer() async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  // Set remote description
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    await _peerConnection!.setRemoteDescription(description);
  }

  // Add ICE candidate
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    await _peerConnection!.addCandidate(candidate);
  }

  // Get remote stream
  MediaStream? get remoteStream => _remoteStream;

  // Check if connected
  bool get isConnected => _isConnected;

  // Dispose
  Future<void> dispose() async {
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
    _remoteStream = null;
    _isConnected = false;
  }
}

