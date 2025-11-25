import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/device_link_model.dart';
import '../../providers/monitoring_provider.dart';
import '../../services/command_service.dart';
import '../../widgets/control_button.dart';
import '../../widgets/video_player_widget.dart';
import 'location_screen.dart';
import 'media_gallery_screen.dart';

class DeviceDetailScreen extends StatefulWidget {
  final DeviceLinkModel device;

  const DeviceDetailScreen({
    super.key,
    required this.device,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isVideoActive = false;
  bool _isAudioActive = false;
  bool _isLoadingVideo = false;
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Set active device
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonitoringProvider>().setActiveDevice(widget.device.deviceId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = widget.device.isOnline ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.videocam), text: 'Monitoreo'),
            Tab(icon: Icon(Icons.location_on), text: 'Ubicación'),
            Tab(icon: Icon(Icons.photo_library), text: 'Historial'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status Bar
          _buildStatusBar(isOnline),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMonitoringTab(),
                LocationScreen(deviceId: widget.device.deviceId),
                MediaGalleryScreen(deviceId: widget.device.deviceId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(bool isOnline) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Dispositivo en línea' : 'Dispositivo fuera de línea',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOnline ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
                if (widget.device.lastSeen != null && !isOnline)
                  Text(
                    'Última conexión: ${_formatDateTime(widget.device.lastSeen!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
              ],
            ),
          ),
          if (isOnline)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            const Icon(Icons.error, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildMonitoringTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          VideoPlayerWidget(
            isLoading: _isLoadingVideo,
            // TODO: Pass actual renderer when implemented
          ),
          const SizedBox(height: 24),
          
          // Camera Controls
          Text(
            'Control de cámara',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ControlButton(
                  icon: Icons.videocam,
                  label: 'Cámara frontal',
                  isActive: _isVideoActive,
                  isLoading: _isLoadingVideo,
                  onPressed: () => _toggleVideo('front'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ControlButton(
                  icon: Icons.videocam,
                  label: 'Cámara trasera',
                  isActive: false,
                  onPressed: () => _toggleVideo('back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ControlButton(
                  icon: Icons.camera_alt,
                  label: 'Tomar foto',
                  onPressed: _takeSnapshot,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Audio Controls
          Text(
            'Control de audio',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ControlButton(
                  icon: Icons.mic,
                  label: 'Escuchar ambiente',
                  isActive: _isAudioActive,
                  isLoading: _isLoadingAudio,
                  color: Colors.orange,
                  onPressed: _toggleAudio,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ControlButton(
                  icon: Icons.fiber_manual_record,
                  label: 'Grabar audio',
                  color: Colors.red,
                  onPressed: _startRecording,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Other Controls
          Text(
            'Otras acciones',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ControlButton(
                  icon: Icons.location_on,
                  label: 'Obtener ubicación',
                  color: Colors.blue,
                  onPressed: _getLocation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ControlButton(
                  icon: Icons.info,
                  label: 'Info del dispositivo',
                  color: Colors.purple,
                  onPressed: _getDeviceInfo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVideo(String camera) async {
    if (!_canSendCommand()) return;

    setState(() {
      _isLoadingVideo = true;
    });

    try {
      final monitoringProvider = context.read<MonitoringProvider>();
      
      if (_isVideoActive) {
        // Stop video
        await monitoringProvider.sendCommand(
          commandType: CommandType.stopVideo,
        );
        setState(() {
          _isVideoActive = false;
        });
      } else {
        // Start video
        await monitoringProvider.sendCommand(
          commandType: CommandType.startVideo,
          parameters: {'camera': camera},
        );
        setState(() {
          _isVideoActive = true;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isVideoActive
                ? 'Video iniciado'
                : 'Video detenido'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingVideo = false;
      });
    }
  }

  Future<void> _toggleAudio() async {
    if (!_canSendCommand()) return;

    setState(() {
      _isLoadingAudio = true;
    });

    try {
      final monitoringProvider = context.read<MonitoringProvider>();
      
      if (_isAudioActive) {
        await monitoringProvider.sendCommand(
          commandType: CommandType.stopAudio,
        );
        setState(() {
          _isAudioActive = false;
        });
      } else {
        await monitoringProvider.sendCommand(
          commandType: CommandType.startAudio,
        );
        setState(() {
          _isAudioActive = true;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAudioActive
                ? 'Audio iniciado'
                : 'Audio detenido'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingAudio = false;
      });
    }
  }

  Future<void> _takeSnapshot() async {
    if (!_canSendCommand()) return;

    try {
      final monitoringProvider = context.read<MonitoringProvider>();
      await monitoringProvider.sendCommand(
        commandType: CommandType.takeSnapshot,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto tomada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (!_canSendCommand()) return;

    try {
      final monitoringProvider = context.read<MonitoringProvider>();
      await monitoringProvider.sendCommand(
        commandType: CommandType.startRecording,
        parameters: {'type': 'audio'},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grabación iniciada'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Show dialog to stop recording
        _showRecordingDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRecordingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fiber_manual_record, color: Colors.red),
            SizedBox(width: 8),
            Text('Grabando...'),
          ],
        ),
        content: const Text('La grabación está en progreso'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _stopRecording();
            },
            child: const Text('Detener grabación'),
          ),
        ],
      ),
    );
  }

  Future<void> _stopRecording() async {
    try {
      final monitoringProvider = context.read<MonitoringProvider>();
      await monitoringProvider.sendCommand(
        commandType: CommandType.stopRecording,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grabación guardada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getLocation() async {
    if (!_canSendCommand()) return;

    try {
      final monitoringProvider = context.read<MonitoringProvider>();
      await monitoringProvider.sendCommand(
        commandType: CommandType.getLocation,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación solicitada'),
          ),
        );
        
        // Switch to location tab
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getDeviceInfo() async {
    if (!_canSendCommand()) return;

    try {
      final monitoringProvider = context.read<MonitoringProvider>();
      await monitoringProvider.sendCommand(
        commandType: CommandType.getDeviceInfo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información solicitada'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _canSendCommand() {
    final isOnline = widget.device.isOnline ?? false;
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El dispositivo está fuera de línea'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    return true;
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Cambiar nombre'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_off, color: Colors.red),
              title: const Text('Desvincular', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}


