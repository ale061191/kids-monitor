import 'package:flutter/material.dart';

class ConsentScreen extends StatefulWidget {
  final VoidCallback onAccept;

  const ConsentScreen({
    super.key,
    required this.onAccept,
  });

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _understoodMonitoring = false;

  bool get _canContinue =>
      _agreedToTerms && _agreedToPrivacy && _understoodMonitoring;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Consentimiento informado',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Antes de continuar, es importante que entiendas cómo funciona esta aplicación y des tu consentimiento explícito.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          _buildInfoCard(
            icon: Icons.videocam,
            title: 'Monitoreo de cámara',
            description:
                'Esta aplicación permite que un tutor autorizado acceda remotamente a la cámara de este dispositivo para videovigilancia.',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.mic,
            title: 'Monitoreo de audio',
            description:
                'El tutor podrá activar el micrófono para escuchar el ambiente y grabar audio cuando lo considere necesario.',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.location_on,
            title: 'Seguimiento de ubicación',
            description:
                'Tu ubicación GPS será compartida con el tutor para tu seguridad y podrá ser rastreada en tiempo real.',
          ),
          const SizedBox(height: 32),
          _buildCheckbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
            label: 'He leído y acepto los términos de servicio',
            linkText: 'Ver términos',
            onLinkTap: () {
              // Open terms of service
            },
          ),
          const SizedBox(height: 16),
          _buildCheckbox(
            value: _agreedToPrivacy,
            onChanged: (value) {
              setState(() {
                _agreedToPrivacy = value ?? false;
              });
            },
            label: 'He leído y acepto la política de privacidad',
            linkText: 'Ver política',
            onLinkTap: () {
              // Open privacy policy
            },
          ),
          const SizedBox(height: 16),
          _buildCheckbox(
            value: _understoodMonitoring,
            onChanged: (value) {
              setState(() {
                _understoodMonitoring = value ?? false;
              });
            },
            label:
                'Entiendo que este dispositivo será monitoreado y doy mi consentimiento explícito',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esta aplicación debe usarse únicamente con fines de protección familiar legítimos. El uso indebido puede violar leyes de privacidad.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade900,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canContinue ? widget.onAccept : null,
              child: const Text('Acepto y continuar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    String? linkText,
    VoidCallback? onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (linkText != null && onLinkTap != null) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onLinkTap,
                      child: Text(
                        linkText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

