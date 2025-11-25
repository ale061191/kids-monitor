import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class AlertCard extends StatelessWidget {
  final String id;
  final String type;
  final String severity;
  final String title;
  final String message;
  final bool resolved;
  final DateTime createdAt;
  final VoidCallback? onResolve;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.resolved,
    required this.createdAt,
    this.onResolve,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();
    final icon = _getTypeIcon();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: resolved ? Colors.grey.shade300 : severityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: resolved
                      ? Colors.grey.shade200
                      : severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: resolved ? Colors.grey : severityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: resolved
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                        ),
                        if (!resolved && onResolve != null)
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            iconSize: 20,
                            color: Colors.green,
                            onPressed: onResolve,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getSeverityText(),
                            style: TextStyle(
                              color: severityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeago.format(createdAt, locale: 'es'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor() {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case 'geofence_enter':
      case 'geofence_exit':
        return Icons.location_on;
      case 'device_offline':
      case 'device_online':
        return Icons.phone_android;
      case 'permission_denied':
        return Icons.block;
      case 'stream_started':
      case 'stream_ended':
        return Icons.videocam;
      case 'low_battery':
        return Icons.battery_alert;
      default:
        return Icons.notifications;
    }
  }

  String _getSeverityText() {
    switch (severity) {
      case 'critical':
        return 'CRÍTICO';
      case 'warning':
        return 'ADVERTENCIA';
      case 'info':
      default:
        return 'INFO';
    }
  }
}


