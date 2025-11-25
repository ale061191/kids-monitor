import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MediaGalleryScreen extends StatefulWidget {
  final String deviceId;

  const MediaGalleryScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _snapshots = [];
  List<Map<String, dynamic>> _recordings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMedia();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMedia() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load actual media from service
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      // Mock data
      _snapshots = [];
      _recordings = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Fotos'),
            Tab(text: 'Grabaciones'),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPhotosTab(),
                    _buildRecordingsTab(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPhotosTab() {
    if (_snapshots.isEmpty) {
      return _buildEmptyState(
        icon: Icons.photo_library,
        message: 'No hay fotos',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _snapshots.length,
      itemBuilder: (context, index) {
        final snapshot = _snapshots[index];
        return _buildPhotoCard(snapshot);
      },
    );
  }

  Widget _buildRecordingsTab() {
    if (_recordings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.audiotrack,
        message: 'No hay grabaciones',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recordings.length,
      itemBuilder: (context, index) {
        final recording = _recordings[index];
        return _buildRecordingCard(recording);
      },
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> snapshot) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPhotoDetail(snapshot),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: snapshot['url'] ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '10:30',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingCard(Map<String, dynamic> recording) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.audiotrack, color: Colors.red),
        ),
        title: Text('Grabación ${recording['id'] ?? ''}'),
        subtitle: Text('Duración: ${recording['duration'] ?? '0:00'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _playRecording(recording),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadRecording(recording),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Los archivos aparecerán aquí',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showPhotoDetail(Map<String, dynamic> snapshot) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Foto'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // TODO: Download photo
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // TODO: Delete photo
                  },
                ),
              ],
            ),
            CachedNetworkImage(
              imageUrl: snapshot['url'] ?? '',
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ],
        ),
      ),
    );
  }

  void _playRecording(Map<String, dynamic> recording) {
    // TODO: Implement audio player
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reproduciendo grabación...')),
    );
  }

  void _downloadRecording(Map<String, dynamic> recording) {
    // TODO: Implement download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descargando...')),
    );
  }
}


