import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/permission_provider.dart';

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const PermissionsScreen({
    super.key,
    required this.onContinue,
  });

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionProvider>().checkPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.security,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Permisos necesarios',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Para funcionar correctamente, la aplicación necesita los siguientes permisos:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildPermissionItem(
                  context,
                  provider,
                  Permission.camera,
                  Icons.videocam,
                  'Cámara',
                  'Para videovigilancia remota',
                ),
                _buildPermissionItem(
                  context,
                  provider,
                  Permission.microphone,
                  Icons.mic,
                  'Micrófono',
                  'Para audio ambiente remoto',
                ),
                _buildPermissionItem(
                  context,
                  provider,
                  Permission.location,
                  Icons.location_on,
                  'Ubicación',
                  'Para seguimiento GPS',
                ),
                _buildPermissionItem(
                  context,
                  provider,
                  Permission.locationAlways,
                  Icons.my_location,
                  'Ubicación siempre',
                  'Para seguimiento continuo',
                ),
                _buildPermissionItem(
                  context,
                  provider,
                  Permission.notification,
                  Icons.notifications,
                  'Notificaciones',
                  'Para alertas del sistema',
                ),
                _buildPermissionItem(
                  context,
                  provider,
                  Permission.storage,
                  Icons.storage,
                  'Almacenamiento',
                  'Para guardar capturas',
                ),
                _buildPermissionItem(
                  context,
                  provider,
                  Permission.systemAlertWindow,
                  Icons.open_in_new,
                  'Ventana superpuesta',
                  'Para funcionar en segundo plano',
                ),
              ],
              const SizedBox(height: 32),
              if (provider.hasAnyPermanentlyDenied)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Algunos permisos fueron denegados permanentemente. Debes habilitarlos manualmente en la configuración.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.red.shade900,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            provider.openAppSettings();
                          },
                          child: const Text('Abrir configuración'),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        provider.requestAllPermissions();
                      },
                      child: const Text('Solicitar todos'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: provider.hasAllPermissions
                          ? widget.onContinue
                          : null,
                      child: const Text('Continuar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionItem(
    BuildContext context,
    PermissionProvider provider,
    Permission permission,
    IconData icon,
    String title,
    String description,
  ) {
    final status = provider.permissions[permission];
    final isGranted = status?.isGranted ?? false;
    final isDenied = status?.isDenied ?? false;
    final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    if (isGranted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isPermanentlyDenied) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
    } else if (isDenied) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted
              ? Colors.green.shade200
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(height: 4),
              if (!isGranted)
                TextButton(
                  onPressed: () {
                    provider.requestPermission(permission);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Solicitar', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

