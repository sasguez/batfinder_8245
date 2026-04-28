import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class PanicAlertService {
  static final PanicAlertService _instance = PanicAlertService._internal();
  factory PanicAlertService() => _instance;
  PanicAlertService._internal();

  String? _activeEventId;
  StreamSubscription<Position>? _locationStream;

  bool get isActive => _activeEventId != null;
  String? get activeEventId => _activeEventId;

  Future<String?> activatePanic({required String triggerSource}) async {
    final user = SupabaseService.client.auth.currentUser;
    if (kDebugMode) print('🔍 PanicAlertService: user=${user?.id}, isActive=$isActive');
    if (user == null) {
      if (kDebugMode) print('❌ PanicAlertService: no hay sesión activa');
      throw Exception('No hay sesión activa. Inicia sesión primero.');
    }
    if (isActive) return _activeEventId;

    HapticFeedback.heavyImpact();

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 5));
      if (kDebugMode) print('📍 GPS: ${position.latitude}, ${position.longitude}');
    } catch (_) {
      try {
        position = await Geolocator.getLastKnownPosition();
        if (kDebugMode) print('📍 GPS (last known): ${position?.latitude}, ${position?.longitude}');
      } catch (_) {}
    }

    if (kDebugMode) print('⏳ Insertando panic_event...');
    final res = await SupabaseService.client
        .from('panic_events')
        .insert({
          'user_id':        user.id,
          'status':         'active',
          'trigger_source': triggerSource,
        })
        .select('id')
        .single();

    _activeEventId = res['id'] as String;
    if (kDebugMode) print('✅ panic_event creado: $_activeEventId');

    SupabaseService.client.functions.invoke('panic-orchestrator', body: {
      'event_id':  _activeEventId,
      'user_id':   user.id,
      'latitude':  position?.latitude  ?? 0.0,
      'longitude': position?.longitude ?? 0.0,
    }).then((r) {
      if (kDebugMode) print('📡 orchestrator response: ${r.data}');
    }).catchError((e) {
      if (kDebugMode) print('❌ orchestrator error: $e');
    });

    _startLocationStream();
    return _activeEventId;
  }

  void _startLocationStream() {
    _locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy:       LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      if (_activeEventId == null) return;
      SupabaseService.client.functions.invoke('update-panic-location', body: {
        'event_id':  _activeEventId,
        'latitude':  pos.latitude,
        'longitude': pos.longitude,
        'accuracy':  pos.accuracy,
        'speed':     pos.speed,
        'heading':   pos.heading,
      }).ignore();
    });
  }

  RealtimeChannel subscribeToLocation(
    String eventId,
    void Function(Map<String, dynamic>) onUpdate,
  ) {
    return SupabaseService.client
        .channel('panic_loc_$eventId')
        .onPostgresChanges(
          event:  PostgresChangeEvent.insert,
          schema: 'public',
          table:  'panic_locations',
          filter: PostgresChangeFilter(
            type:   PostgresChangeFilterType.eq,
            column: 'event_id',
            value:  eventId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }

  Future<void> resolvePanic({String resolution = 'resolved'}) async {
    final eventId = _activeEventId;
    if (eventId == null) return;

    final user = SupabaseService.client.auth.currentUser;

    await _locationStream?.cancel();
    _locationStream  = null;
    _activeEventId   = null;

    try {
      await SupabaseService.client.functions.invoke('resolve-panic', body: {
        'event_id':   eventId,
        'user_id':    user?.id,
        'resolution': resolution,
      });
    } catch (e) {
      if (kDebugMode) print('❌ PanicAlertService.resolvePanic: $e');
    }
  }

  void dispose() {
    _locationStream?.cancel();
    _locationStream = null;
  }
}
