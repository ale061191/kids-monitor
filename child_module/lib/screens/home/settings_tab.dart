import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';
import '../../services/service_locator.dart';
import '../../services/notification_service.dart';
import '../../services/supabase_service.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final NotificationService _notificationService =
      getIt<NotificationService>();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = _notificationService.areNotificationsEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Configuración',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),

        // Privacy Settings
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notificaciones de monitoreo'),
                subtitle: const Text(
                  'Mostrar notificaciones cuando se active el monitoreo',
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    await _notificationService.toggleNotifications();
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Device Management
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Actualizar información'),
                subtitle: const Text('Actualizar datos del dispositivo'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final provider = context.read<DeviceProvider>();
                  await provider.updateDeviceInfo();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Información actualizada'),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.link_off),
                title: const Text('Desvincular dispositivo'),
                subtitle: const Text('Eliminar vinculación con tutores'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showUnlinkDialog(context);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // About
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Política de privacidad'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Open privacy policy
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Términos de servicio'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Open terms of service
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Acerca de'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Danger Zone
        Card(
          color: Colors.red.shade50,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red.shade700),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red.shade700),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                title: Text(
                  'Eliminar dispositivo',
                  style: TextStyle(color: Colors.red.shade700),
                ),
                subtitle: const Text('Esta acción no se puede deshacer'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showDeleteDialog(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUnlinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desvincular dispositivo'),
        content: const Text(
          '¿Estás seguro de que quieres desvincular este dispositivo? Los tutores ya no podrán monitorearlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Implement unlink
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dispositivo desvinculado'),
                ),
              );
            },
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final supabaseService = getIt<SupabaseService>();
              await supabaseService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/setup',
                  (route) => false,
                );
              }
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar dispositivo'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este dispositivo? Esta acción no se puede deshacer y se eliminarán todos los datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              final provider = context.read<DeviceProvider>();
              await provider.unregisterDevice();
              
              final supabaseService = getIt<SupabaseService>();
              await supabaseService.signOut();
              
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/setup',
                  (route) => false,
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SafeKids Monitor',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.shield, size: 48),
      children: [
        const Text(
          'Aplicación de monitoreo parental para la protección de niños y adolescentes.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Esta aplicación debe usarse únicamente con el consentimiento explícito del usuario monitoreado.',
        ),
      ],
    );
  }
}

