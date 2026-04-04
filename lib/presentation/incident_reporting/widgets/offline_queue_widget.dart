import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../services/offline_queue_service.dart';

class OfflineQueueWidget extends StatefulWidget {
  const OfflineQueueWidget({super.key});

  @override
  State<OfflineQueueWidget> createState() => _OfflineQueueWidgetState();
}

class _OfflineQueueWidgetState extends State<OfflineQueueWidget> {
  final _offlineQueue = OfflineQueueService();
  List<QueuedIncident> _queuedIncidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueue();
    _listenToQueueUpdates();
  }

  Future<void> _loadQueue() async {
    final incidents = await _offlineQueue.getAllQueuedIncidents();
    if (mounted) {
      setState(() {
        _queuedIncidents = incidents;
        _isLoading = false;
      });
    }
  }

  void _listenToQueueUpdates() {
    _offlineQueue.queueStatusStream.listen((_) {
      _loadQueue();
    });
  }

  Future<void> _retryIncident(String localId) async {
    await _offlineQueue.retryFailedIncident(localId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reintentando envío...')));
    }
  }

  Future<void> _deleteIncident(String localId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text(
          '¿Estás seguro de eliminar este reporte de la cola?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _offlineQueue.deleteQueuedIncident(localId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte eliminado de la cola')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_queuedIncidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: theme.colorScheme.primary,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text('No hay reportes en cola', style: theme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            Text(
              'Todos los reportes han sido sincronizados',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: _queuedIncidents.length,
      separatorBuilder: (_, __) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final incident = _queuedIncidents[index];
        return _QueueItemCard(
          incident: incident,
          onRetry: () => _retryIncident(incident.localId),
          onDelete: () => _deleteIncident(incident.localId),
        );
      },
    );
  }
}

class _QueueItemCard extends StatelessWidget {
  final QueuedIncident incident;
  final VoidCallback onRetry;
  final VoidCallback onDelete;

  const _QueueItemCard({
    required this.incident,
    required this.onRetry,
    required this.onDelete,
  });

  Color _getStatusColor(QueueStatus status, ColorScheme colorScheme) {
    switch (status) {
      case QueueStatus.pending:
        return colorScheme.primaryContainer;
      case QueueStatus.syncing:
        return colorScheme.tertiaryContainer;
      case QueueStatus.synced:
        return Color(0xFF4CAF50);
      case QueueStatus.failed:
        return colorScheme.errorContainer;
    }
  }

  String _getStatusText(QueueStatus status) {
    switch (status) {
      case QueueStatus.pending:
        return 'Pendiente';
      case QueueStatus.syncing:
        return 'Enviando...';
      case QueueStatus.synced:
        return 'Sincronizado';
      case QueueStatus.failed:
        return 'Error';
    }
  }

  String _getStatusIcon(QueueStatus status) {
    switch (status) {
      case QueueStatus.pending:
        return 'schedule';
      case QueueStatus.syncing:
        return 'sync';
      case QueueStatus.synced:
        return 'check_circle';
      case QueueStatus.failed:
        return 'error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor(incident.status, theme.colorScheme),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: _getStatusIcon(incident.status),
                    color: incident.status == QueueStatus.synced
                        ? Colors.white
                        : theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.incidentData['title'] ?? 'Sin título',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _getStatusText(incident.status),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              incident.incidentData['description'] ?? '',
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${incident.createdAt.day}/${incident.createdAt.month}/${incident.createdAt.year} ${incident.createdAt.hour}:${incident.createdAt.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (incident.status == QueueStatus.failed) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'error',
                      color: theme.colorScheme.onErrorContainer,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        incident.errorMessage ?? 'Error desconocido',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const CustomIconWidget(
                        iconName: 'refresh',
                        size: 18,
                      ),
                      label: const Text('Reintentar'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  IconButton(
                    onPressed: onDelete,
                    icon: CustomIconWidget(
                      iconName: 'delete',
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
            if (incident.retryCount > 0 &&
                incident.status == QueueStatus.pending) ...[
              SizedBox(height: 1.h),
              Text(
                'Intentos: ${incident.retryCount}/3',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
