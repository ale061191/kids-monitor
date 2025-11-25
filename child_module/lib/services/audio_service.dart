import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioService {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isInitialized = false;
  String? _currentRecordingPath;

  // Initialize audio service
  Future<void> initialize() async {
    try {
      _recorder = FlutterSoundRecorder();
      _player = FlutterSoundPlayer();

      await _recorder!.openRecorder();
      await _player!.openPlayer();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize audio service: $e');
    }
  }

  // Start recording
  Future<String> startRecording() async {
    if (!_isInitialized || _recorder == null) {
      throw Exception('Audio service not initialized');
    }

    if (_isRecording) {
      throw Exception('Already recording');
    }

    // Check permission
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      throw Exception('Microphone permission not granted');
    }

    try {
      final directory = await getTemporaryDirectory();
      final fileName = '${const Uuid().v4()}.aac';
      _currentRecordingPath = '${directory.path}/$fileName';

      await _recorder!.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      _isRecording = true;
      return _currentRecordingPath!;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  // Stop recording
  Future<File?> stopRecording() async {
    if (!_isInitialized || _recorder == null) {
      throw Exception('Audio service not initialized');
    }

    if (!_isRecording) {
      throw Exception('Not recording');
    }

    try {
      await _recorder!.stopRecorder();
      _isRecording = false;

      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        _currentRecordingPath = null;
        return file;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  // Pause recording
  Future<void> pauseRecording() async {
    if (!_isInitialized || _recorder == null) {
      throw Exception('Audio service not initialized');
    }

    if (!_isRecording) {
      throw Exception('Not recording');
    }

    try {
      await _recorder!.pauseRecorder();
    } catch (e) {
      throw Exception('Failed to pause recording: $e');
    }
  }

  // Resume recording
  Future<void> resumeRecording() async {
    if (!_isInitialized || _recorder == null) {
      throw Exception('Audio service not initialized');
    }

    try {
      await _recorder!.resumeRecorder();
    } catch (e) {
      throw Exception('Failed to resume recording: $e');
    }
  }

  // Play audio file
  Future<void> playAudio(String filePath) async {
    if (!_isInitialized || _player == null) {
      throw Exception('Audio service not initialized');
    }

    try {
      await _player!.startPlayer(
        fromURI: filePath,
        codec: Codec.aacADTS,
      );
    } catch (e) {
      throw Exception('Failed to play audio: $e');
    }
  }

  // Stop playing
  Future<void> stopPlaying() async {
    if (!_isInitialized || _player == null) {
      throw Exception('Audio service not initialized');
    }

    try {
      await _player!.stopPlayer();
    } catch (e) {
      throw Exception('Failed to stop playing: $e');
    }
  }

  // Get recording duration
  Stream<RecordingDisposition>? get onProgress {
    return _recorder?.onProgress;
  }

  // Check if recording
  bool get isRecording => _isRecording;

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Get current recording path
  String? get currentRecordingPath => _currentRecordingPath;

  // Dispose
  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }

    await _recorder?.closeRecorder();
    await _player?.closePlayer();

    _recorder = null;
    _player = null;
    _isInitialized = false;
  }

  // Get audio info
  Map<String, dynamic> getAudioInfo() {
    return {
      'initialized': _isInitialized,
      'recording': _isRecording,
      'current_recording_path': _currentRecordingPath,
    };
  }
}

