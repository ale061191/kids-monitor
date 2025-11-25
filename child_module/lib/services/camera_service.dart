import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _currentCameraIndex = 0;
  bool _isInitialized = false;
  bool _isRecording = false;

  // Initialize cameras
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        throw Exception('No cameras available');
      }
      await _initializeCamera(_currentCameraIndex);
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  // Initialize specific camera
  Future<void> _initializeCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }

    // Dispose previous controller
    await _controller?.dispose();

    _controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    _isInitialized = true;
  }

  // Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      throw Exception('Cannot switch camera');
    }

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _initializeCamera(_currentCameraIndex);
  }

  // Take snapshot
  Future<File> takeSnapshot() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile image = await _controller!.takePicture();
      return File(image.path);
    } catch (e) {
      throw Exception('Failed to take snapshot: $e');
    }
  }

  // Take snapshot and return bytes
  Future<Uint8List> takeSnapshotBytes() async {
    final file = await takeSnapshot();
    return await file.readAsBytes();
  }

  // Start video recording
  Future<void> startRecording() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (_isRecording) {
      throw Exception('Already recording');
    }

    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  // Stop video recording
  Future<File> stopRecording() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (!_isRecording) {
      throw Exception('Not recording');
    }

    try {
      final XFile video = await _controller!.stopVideoRecording();
      _isRecording = false;
      return File(video.path);
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  // Get camera preview widget
  CameraController? get controller => _controller;

  // Get camera info
  Map<String, dynamic> getCameraInfo() {
    if (_cameras == null || _cameras!.isEmpty) {
      return {
        'available': false,
        'count': 0,
      };
    }

    return {
      'available': true,
      'count': _cameras!.length,
      'current_camera': _currentCameraIndex,
      'current_lens_direction': _cameras![_currentCameraIndex].lensDirection.toString(),
      'cameras': _cameras!.map((camera) => {
        'name': camera.name,
        'lens_direction': camera.lensDirection.toString(),
        'sensor_orientation': camera.sensorOrientation,
      }).toList(),
    };
  }

  // Check if camera is available
  bool get isAvailable => _cameras != null && _cameras!.isNotEmpty;

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Check if recording
  bool get isRecording => _isRecording;

  // Get current camera direction
  CameraLensDirection? get currentLensDirection {
    if (_cameras == null || _cameras!.isEmpty) return null;
    return _cameras![_currentCameraIndex].lensDirection;
  }

  // Dispose
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _isRecording = false;
  }

  // Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null) return;
    await _controller!.setFlashMode(mode);
  }

  // Set zoom level
  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null) return;
    await _controller!.setZoomLevel(zoom);
  }

  // Get max zoom level
  Future<double> getMaxZoomLevel() async {
    if (_controller == null) return 1.0;
    return await _controller!.getMaxZoomLevel();
  }

  // Get min zoom level
  Future<double> getMinZoomLevel() async {
    if (_controller == null) return 1.0;
    return await _controller!.getMinZoomLevel();
  }
}

