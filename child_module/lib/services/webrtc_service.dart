import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../config/app_config.dart';
import 'service_locator.dart';
import 'supabase_service.dart';
import 'camera_service.dart';

class WebRTCService {
  final SupabaseService _supabaseService = getIt<SupabaseService>();
  final CameraService _cameraService = getIt<CameraService>();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isConnected = false;
  String? _currentSessionId;

  // Initialize WebRTC
  Future<void> initialize() async {
    try {
      // Create peer connection
      _peerConnection = await createPeerConnection(
        AppConfig.iceServers,
        {
          'optional': [
            {'DtlsSrtpKeyAgreement': true},
          ],
        },
      );

      // Setup event handlers
      _peerConnection!.onIceCandidate = _onIceCandidate;
      _peerConnection!.onIceConnectionState = _onIceConnectionState;
      _peerConnection!.onSignalingState = _onSignalingState;
      _peerConnection!.onAddStream = _onAddStream;
      _peerConnection!.onRemoveStream = _onRemoveStream;
    } catch (e) {
      throw Exception('Failed to initialize WebRTC: $e');
    }
  }

  // Start video streaming
  Future<void> startVideoStream({
    bool audio = false,
    String? sessionId,
  }) async {
    try {
      if (_peerConnection == null) {
        await initialize();
      }

      _currentSessionId = sessionId;

      // Get user media
      final mediaConstraints = {
        'audio': audio ? AppConfig.audioConstraints : false,
        'video': AppConfig.videoConstraints,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      // Add stream to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
    } catch (e) {
      throw Exception('Failed to start video stream: $e');
    }
  }

  // Start audio streaming
  Future<void> startAudioStream({String? sessionId}) async {
    try {
      if (_peerConnection == null) {
        await initialize();
      }

      _currentSessionId = sessionId;

      // Get audio only
      final mediaConstraints = {
        'audio': AppConfig.audioConstraints,
        'video': false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      // Add stream to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
    } catch (e) {
      throw Exception('Failed to start audio stream: $e');
    }
  }

  // Create offer
  Future<RTCSessionDescription> createOffer() async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    try {
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });

      await _peerConnection!.setLocalDescription(offer);
      return offer;
    } catch (e) {
      throw Exception('Failed to create offer: $e');
    }
  }

  // Create answer
  Future<RTCSessionDescription> createAnswer() async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    try {
      final answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });

      await _peerConnection!.setLocalDescription(answer);
      return answer;
    } catch (e) {
      throw Exception('Failed to create answer: $e');
    }
  }

  // Set remote description
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    try {
      await _peerConnection!.setRemoteDescription(description);
    } catch (e) {
      throw Exception('Failed to set remote description: $e');
    }
  }

  // Add ICE candidate
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    try {
      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      throw Exception('Failed to add ICE candidate: $e');
    }
  }

  // Event handlers
  void _onIceCandidate(RTCIceCandidate candidate) {
    // Send ICE candidate to signaling server (Supabase)
    if (_currentSessionId != null) {
      _sendIceCandidate(candidate);
    }
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    print('ICE connection state: $state');
    _isConnected = state == RTCIceConnectionState.RTCIceConnectionStateConnected;
  }

  void _onSignalingState(RTCSignalingState state) {
    print('Signaling state: $state');
  }

  void _onAddStream(MediaStream stream) {
    print('Remote stream added');
  }

  void _onRemoveStream(MediaStream stream) {
    print('Remote stream removed');
  }

  // Send ICE candidate to signaling server
  Future<void> _sendIceCandidate(RTCIceCandidate candidate) async {
    try {
      if (_currentSessionId == null) return;

      // Get current session
      final sessions = await _supabaseService.select(
        'webrtc_sessions',
        filter: 'id=eq.$_currentSessionId',
        limit: 1,
      );

      if (sessions.isEmpty) return;

      final session = sessions.first;
      final iceCandidates = session['ice_candidates'] as List? ?? [];
      
      iceCandidates.add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });

      await _supabaseService.update(
        'webrtc_sessions',
        _currentSessionId!,
        {'ice_candidates': iceCandidates},
      );
    } catch (e) {
      print('Failed to send ICE candidate: $e');
    }
  }

  // Stop streaming
  Future<void> stopStreaming() async {
    try {
      // Stop all tracks
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });

      // Dispose local stream
      await _localStream?.dispose();
      _localStream = null;

      // Close peer connection
      await _peerConnection?.close();
      _peerConnection = null;

      _isConnected = false;
      _currentSessionId = null;
    } catch (e) {
      throw Exception('Failed to stop streaming: $e');
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    if (_localStream == null) {
      throw Exception('No active stream');
    }

    try {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    } catch (e) {
      throw Exception('Failed to switch camera: $e');
    }
  }

  // Mute/unmute audio
  Future<void> setAudioEnabled(bool enabled) async {
    if (_localStream == null) {
      throw Exception('No active stream');
    }

    try {
      final audioTracks = _localStream!.getAudioTracks();
      for (var track in audioTracks) {
        track.enabled = enabled;
      }
    } catch (e) {
      throw Exception('Failed to set audio enabled: $e');
    }
  }

  // Enable/disable video
  Future<void> setVideoEnabled(bool enabled) async {
    if (_localStream == null) {
      throw Exception('No active stream');
    }

    try {
      final videoTracks = _localStream!.getVideoTracks();
      for (var track in videoTracks) {
        track.enabled = enabled;
      }
    } catch (e) {
      throw Exception('Failed to set video enabled: $e');
    }
  }

  // Get local stream
  MediaStream? get localStream => _localStream;

  // Check if connected
  bool get isConnected => _isConnected;

  // Get connection state
  Future<RTCIceConnectionState?> getConnectionState() async {
    return await _peerConnection?.iceConnectionState;
  }

  // Dispose
  Future<void> dispose() async {
    await stopStreaming();
  }
}

