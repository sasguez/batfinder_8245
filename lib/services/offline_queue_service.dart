import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import './incident_management_service.dart';
import './supabase_service.dart';

enum QueueStatus { pending, syncing, synced, failed }

class QueuedIncident {
  final String localId;
  final String? serverId;
  final Map<String, dynamic> incidentData;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final QueueStatus status;
  final int retryCount;
  final String? errorMessage;
  final DateTime? lastSyncAttempt;

  QueuedIncident({
    required this.localId,
    this.serverId,
    required this.incidentData,
    required this.mediaUrls,
    required this.createdAt,
    required this.status,
    this.retryCount = 0,
    this.errorMessage,
    this.lastSyncAttempt,
  });

  Map<String, dynamic> toMap() {
    return {
      'local_id': localId,
      'server_id': serverId,
      'incident_data': jsonEncode(incidentData),
      'media_urls': jsonEncode(mediaUrls),
      'created_at': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'retry_count': retryCount,
      'error_message': errorMessage,
      'last_sync_attempt': lastSyncAttempt?.toIso8601String(),
    };
  }

  factory QueuedIncident.fromMap(Map<String, dynamic> map) {
    return QueuedIncident(
      localId: map['local_id'] as String,
      serverId: map['server_id'] as String?,
      incidentData: jsonDecode(map['incident_data'] as String),
      mediaUrls: List<String>.from(jsonDecode(map['media_urls'] as String)),
      createdAt: DateTime.parse(map['created_at'] as String),
      status: QueueStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      retryCount: map['retry_count'] as int? ?? 0,
      errorMessage: map['error_message'] as String?,
      lastSyncAttempt: map['last_sync_attempt'] != null
          ? DateTime.parse(map['last_sync_attempt'] as String)
          : null,
    );
  }

  QueuedIncident copyWith({
    String? serverId,
    QueueStatus? status,
    int? retryCount,
    String? errorMessage,
    DateTime? lastSyncAttempt,
  }) {
    return QueuedIncident(
      localId: localId,
      serverId: serverId ?? this.serverId,
      incidentData: incidentData,
      mediaUrls: mediaUrls,
      createdAt: createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
    );
  }
}

class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  Database? _database;
  final _uuid = const Uuid();
  final _connectivity = Connectivity();
  final _incidentService = IncidentManagementService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  final _queueStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get queueStatusStream =>
      _queueStatusController.stream;

  Future<void> initialize() async {
    _database = await _initDatabase();
    _startConnectivityMonitoring();
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'incident_queue.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE queued_incidents (
            local_id TEXT PRIMARY KEY,
            server_id TEXT,
            incident_data TEXT NOT NULL,
            media_urls TEXT NOT NULL,
            created_at TEXT NOT NULL,
            status TEXT NOT NULL,
            retry_count INTEGER DEFAULT 0,
            error_message TEXT,
            last_sync_attempt TEXT
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_status ON queued_incidents(status)
        ''');
        await db.execute('''
          CREATE INDEX idx_created_at ON queued_incidents(created_at)
        ''');
      },
    );
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) async {
      final hasConnection =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);

      if (hasConnection && !_isSyncing) {
        await syncPendingIncidents();
      }
    });

    _syncTimer = Timer.periodic(Duration(minutes: 5), (_) async {
      final results = await _connectivity.checkConnectivity();
      final hasConnection =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);

      if (hasConnection && !_isSyncing) {
        await syncPendingIncidents();
      }
    });
  }

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  Future<String> queueIncident({
    required String title,
    required String description,
    required String incidentType,
    required String severity,
    required double locationLat,
    required double locationLng,
    String? locationAddress,
    required DateTime occurredAt,
    bool isAnonymous = false,
    List<String>? mediaUrls,
  }) async {
    final localId = _uuid.v4();
    final userId = SupabaseService.client.auth.currentUser?.id;

    final incidentData = {
      'title': title,
      'description': description,
      'incident_type': incidentType,
      'severity': severity,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'location_address': locationAddress,
      'occurred_at': occurredAt.toIso8601String(),
      'is_anonymous': isAnonymous,
      'reporter_id': isAnonymous ? null : userId,
      'status': 'pending',
    };

    final queuedIncident = QueuedIncident(
      localId: localId,
      incidentData: incidentData,
      mediaUrls: mediaUrls ?? [],
      createdAt: DateTime.now(),
      status: QueueStatus.pending,
    );

    await _database?.insert(
      'queued_incidents',
      queuedIncident.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _notifyQueueUpdate();

    if (await isOnline()) {
      await syncPendingIncidents();
    }

    return localId;
  }

  Future<void> syncPendingIncidents() async {
    if (_isSyncing || !(await isOnline())) return;

    _isSyncing = true;
    _notifyQueueUpdate();

    try {
      final pendingIncidents = await _getPendingIncidents();

      for (final incident in pendingIncidents) {
        try {
          await _updateIncidentStatus(incident.localId, QueueStatus.syncing);

          final result = await _incidentService.createIncident(
            title: incident.incidentData['title'],
            description: incident.incidentData['description'],
            incidentType: incident.incidentData['incident_type'],
            severity: incident.incidentData['severity'],
            locationLat: incident.incidentData['location_lat'],
            locationLng: incident.incidentData['location_lng'],
            locationAddress: incident.incidentData['location_address'],
            occurredAt: DateTime.parse(incident.incidentData['occurred_at']),
            isAnonymous: incident.incidentData['is_anonymous'],
            mediaUrls: incident.mediaUrls.isNotEmpty
                ? incident.mediaUrls
                : null,
          );

          await _updateIncidentStatus(
            incident.localId,
            QueueStatus.synced,
            serverId: result['id'] as String,
          );
        } catch (e) {
          final newRetryCount = incident.retryCount + 1;
          final shouldFail = newRetryCount >= 3;

          await _updateIncidentStatus(
            incident.localId,
            shouldFail ? QueueStatus.failed : QueueStatus.pending,
            errorMessage: e.toString(),
            retryCount: newRetryCount,
            lastSyncAttempt: DateTime.now(),
          );
        }
      }
    } finally {
      _isSyncing = false;
      _notifyQueueUpdate();
    }
  }

  Future<List<QueuedIncident>> _getPendingIncidents() async {
    final results = await _database?.query(
      'queued_incidents',
      where: 'status IN (?, ?)',
      whereArgs: ['pending', 'failed'],
      orderBy: 'created_at ASC',
    );

    if (results == null || results.isEmpty) return [];

    return results.map((map) => QueuedIncident.fromMap(map)).toList();
  }

  Future<void> _updateIncidentStatus(
    String localId,
    QueueStatus status, {
    String? serverId,
    String? errorMessage,
    int? retryCount,
    DateTime? lastSyncAttempt,
  }) async {
    final updates = <String, dynamic>{
      'status': status.toString().split('.').last,
    };

    if (serverId != null) updates['server_id'] = serverId;
    if (errorMessage != null) updates['error_message'] = errorMessage;
    if (retryCount != null) updates['retry_count'] = retryCount;
    if (lastSyncAttempt != null) {
      updates['last_sync_attempt'] = lastSyncAttempt.toIso8601String();
    }

    await _database?.update(
      'queued_incidents',
      updates,
      where: 'local_id = ?',
      whereArgs: [localId],
    );

    _notifyQueueUpdate();
  }

  Future<void> retryFailedIncident(String localId) async {
    await _database?.update(
      'queued_incidents',
      {'status': QueueStatus.pending.toString().split('.').last},
      where: 'local_id = ?',
      whereArgs: [localId],
    );

    _notifyQueueUpdate();

    if (await isOnline()) {
      await syncPendingIncidents();
    }
  }

  Future<void> deleteQueuedIncident(String localId) async {
    await _database?.delete(
      'queued_incidents',
      where: 'local_id = ?',
      whereArgs: [localId],
    );

    _notifyQueueUpdate();
  }

  Future<List<QueuedIncident>> getAllQueuedIncidents() async {
    final results = await _database?.query(
      'queued_incidents',
      orderBy: 'created_at DESC',
    );

    if (results == null || results.isEmpty) return [];

    return results.map((map) => QueuedIncident.fromMap(map)).toList();
  }

  Future<Map<String, int>> getQueueStats() async {
    final results = await _database?.rawQuery('''
      SELECT 
        status,
        COUNT(*) as count
      FROM queued_incidents
      GROUP BY status
    ''');

    final stats = <String, int>{};
    if (results != null) {
      for (final row in results) {
        stats[row['status'] as String] = row['count'] as int;
      }
    }

    return stats;
  }

  void _notifyQueueUpdate() {
    getQueueStats().then((stats) {
      _queueStatusController.add({
        'stats': stats,
        'isSyncing': _isSyncing,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> cleanupSyncedIncidents({int olderThanDays = 7}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

    await _database?.delete(
      'queued_incidents',
      where: 'status = ? AND created_at < ?',
      whereArgs: [
        QueueStatus.synced.toString().split('.').last,
        cutoffDate.toIso8601String(),
      ],
    );

    _notifyQueueUpdate();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _queueStatusController.close();
    _database?.close();
  }
}
