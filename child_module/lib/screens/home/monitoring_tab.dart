import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/monitoring_provider.dart';
import '../../models/command_model.dart';

class MonitoringTab extends StatelessWidget {
  const MonitoringTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MonitoringProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Status Cards
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      context,
                      'Cámara',
                      provider.isCameraActive,
                      Icons.videocam,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusCard(
                      context,
                      'Audio',
                      provider.isAudioActive,
                      Icons.mic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusCard(
                      context,
                      'Ubicación',
                      provider.isLocationTracking,
                      Icons.location_on,
                    ),
                  ),
                ],
              ),
            ),

            // Recent Commands
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Actividad reciente',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (provider.recentCommands.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        provider.clearRecentCommands();
                      },
                      child: const Text('Limpiar'),
                    ),
                ],
              ),
            ),

            // Commands List
            Expanded(
              child: provider.recentCommands.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay actividad reciente',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.recentCommands.length,
                      itemBuilder: (context, index) {
                        final command = provider.recentCommands[index];
                        return _buildCommandItem(context, command);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String label,
    bool isActive,
    IconData icon,
  ) {
    return Card(
      color: isActive
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandItem(BuildContext context, CommandModel command) {
    final icon = _getCommandIcon(command.commandType);
    final color = _getCommandColor(command.status);
    final statusText = _getStatusText(command.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(_getCommandTitle(command.commandType)),
        subtitle: Text(
          '${statusText} • ${_formatTime(command.createdAt)}',
        ),
        trailing: _buildStatusBadge(context, command.status),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, CommandStatus status) {
    final color = _getCommandColor(status);
    final text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  IconData _getCommandIcon(CommandType type) {
    switch (type) {
      case CommandType.startVideo:
      case CommandType.stopVideo:
        return Icons.videocam;
      case CommandType.switchCamera:
        return Icons.switch_camera;
      case CommandType.startAudio:
      case CommandType.stopAudio:
        return Icons.mic;
      case CommandType.takeSnapshot:
        return Icons.camera_alt;
      case CommandType.startRecording:
      case CommandType.stopRecording:
        return Icons.fiber_manual_record;
      case CommandType.getLocation:
        return Icons.location_on;
      case CommandType.getDeviceInfo:
        return Icons.info;
    }
  }

  Color _getCommandColor(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return Colors.orange;
      case CommandStatus.sent:
        return Colors.blue;
      case CommandStatus.executed:
        return Colors.green;
      case CommandStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusText(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return 'Pendiente';
      case CommandStatus.sent:
        return 'Enviado';
      case CommandStatus.executed:
        return 'Ejecutado';
      case CommandStatus.failed:
        return 'Fallido';
    }
  }

  String _getCommandTitle(CommandType type) {
    switch (type) {
      case CommandType.startVideo:
        return 'Iniciar video';
      case CommandType.stopVideo:
        return 'Detener video';
      case CommandType.switchCamera:
        return 'Cambiar cámara';
      case CommandType.startAudio:
        return 'Iniciar audio';
      case CommandType.stopAudio:
        return 'Detener audio';
      case CommandType.takeSnapshot:
        return 'Tomar foto';
      case CommandType.startRecording:
        return 'Iniciar grabación';
      case CommandType.stopRecording:
        return 'Detener grabación';
      case CommandType.getLocation:
        return 'Obtener ubicación';
      case CommandType.getDeviceInfo:
        return 'Información del dispositivo';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return DateFormat('dd/MM HH:mm').format(dateTime);
    }
  }
}

