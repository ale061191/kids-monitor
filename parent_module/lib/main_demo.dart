import 'package:flutter/material.dart';

void main() {
  runApp(const ParentModuleDemo());
}

class ParentModuleDemo extends StatelessWidget {
  const ParentModuleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeKids Control - Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const DashboardDemo(),
    );
  }
}

class DashboardDemo extends StatefulWidget {
  const DashboardDemo({super.key});

  @override
  State<DashboardDemo> createState() => _DashboardDemoState();
}

class _DashboardDemoState extends State<DashboardDemo> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DevicesScreen(),
    const LocationScreen(),
    const MediaScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeKids Control Parental'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sin notificaciones nuevas')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.devices),
            label: 'Dispositivos',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on),
            label: 'Ubicación',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library),
            label: 'Galería',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                _showAddDeviceDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Vincular Dispositivo'),
            )
          : null,
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular Nuevo Dispositivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el código de vinculación del dispositivo hijo:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Código',
                hintText: 'ABC123XYZ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dispositivo vinculado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Vincular'),
          ),
        ],
      ),
    );
  }
}

// Pantalla de Dispositivos
class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Mis Dispositivos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '2 dispositivos vinculados',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        _buildDeviceCard(
          context,
          name: 'Teléfono de María',
          status: 'En línea',
          isOnline: true,
          lastSeen: 'Ahora',
          battery: 85,
          location: 'Casa',
        ),
        const SizedBox(height: 16),
        _buildDeviceCard(
          context,
          name: 'Tablet de Juan',
          status: 'Fuera de línea',
          isOnline: false,
          lastSeen: 'Hace 2 horas',
          battery: 45,
          location: 'Escuela',
        ),
      ],
    );
  }

  Widget _buildDeviceCard(
    BuildContext context, {
    required String name,
    required String status,
    required bool isOnline,
    required String lastSeen,
    required int battery,
    required String location,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailScreen(deviceName: name),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.phone_android,
                      size: 32,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 12,
                              color: isOnline ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                color: isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip(Icons.access_time, lastSeen),
                  _buildInfoChip(Icons.battery_std, '$battery%'),
                  _buildInfoChip(Icons.location_on, location),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

// Pantalla de Detalle del Dispositivo
class DeviceDetailScreen extends StatelessWidget {
  final String deviceName;

  const DeviceDetailScreen({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Controles de Monitoreo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildControlButton(
                context,
                icon: Icons.camera_front,
                label: 'Cámara Frontal',
                color: Colors.blue,
              ),
              _buildControlButton(
                context,
                icon: Icons.camera_rear,
                label: 'Cámara Trasera',
                color: Colors.indigo,
              ),
              _buildControlButton(
                context,
                icon: Icons.mic,
                label: 'Escuchar Audio',
                color: Colors.orange,
              ),
              _buildControlButton(
                context,
                icon: Icons.camera_alt,
                label: 'Tomar Foto',
                color: Colors.purple,
              ),
              _buildControlButton(
                context,
                icon: Icons.fiber_manual_record,
                label: 'Grabar Audio',
                color: Colors.red,
              ),
              _buildControlButton(
                context,
                icon: Icons.location_searching,
                label: 'Ubicación Actual',
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Información del Dispositivo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Activando: $label'),
              backgroundColor: color,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Estado', 'En línea', Colors.green),
            const Divider(),
            _buildInfoRow('Batería', '85%', Colors.blue),
            const Divider(),
            _buildInfoRow('Última ubicación', 'Casa', Colors.orange),
            const Divider(),
            _buildInfoRow('Última actividad', 'Hace 2 minutos', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 8),
              Text(value, style: TextStyle(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

// Pantalla de Ubicación
class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 100, color: Colors.blue[300]),
            const SizedBox(height: 24),
            const Text(
              'Mapa de Ubicaciones',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Aquí se mostraría un mapa interactivo con las ubicaciones de los dispositivos vinculados y las geocercas configuradas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de Galería
class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Galería de Medios',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Text(
          'Fotos Recientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Card(
              child: Center(
                child: Icon(Icons.photo, size: 48, color: Colors.grey[400]),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Grabaciones de Audio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildAudioItem('Grabación 1', '2:35', '24/11/2025 10:30'),
        _buildAudioItem('Grabación 2', '1:45', '24/11/2025 09:15'),
        _buildAudioItem('Grabación 3', '3:20', '23/11/2025 18:45'),
      ],
    );
  }

  Widget _buildAudioItem(String title, String duration, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.audiotrack, color: Colors.orange),
        title: Text(title),
        subtitle: Text(date),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(duration),
            const SizedBox(width: 8),
            const Icon(Icons.play_arrow),
          ],
        ),
      ),
    );
  }
}

// Pantalla de Configuración
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Configuración',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildSettingSection('Cuenta', [
          _buildSettingItem(Icons.person, 'Perfil', 'Editar información personal'),
          _buildSettingItem(Icons.security, 'Seguridad', 'Cambiar contraseña'),
        ]),
        const SizedBox(height: 16),
        _buildSettingSection('Notificaciones', [
          _buildSettingItem(Icons.notifications, 'Alertas', 'Configurar notificaciones'),
          _buildSettingItem(Icons.volume_up, 'Sonidos', 'Tonos de alerta'),
        ]),
        const SizedBox(height: 16),
        _buildSettingSection('Privacidad', [
          _buildSettingItem(Icons.privacy_tip, 'Política de Privacidad', 'Ver términos'),
          _buildSettingItem(Icons.help, 'Ayuda', 'Centro de soporte'),
        ]),
      ],
    );
  }

  Widget _buildSettingSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

