import 'dart:async';

import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart';

import '../common/result.dart';
import '../services/offline_write_queue.dart';
import '../sync/drift_offline_write_queue.dart';
import 'calendar_event.dart';

/// Calendar persistence + streaming reads (phase 3.2).
abstract class CalendarRepository {
  Stream<List<CalendarEvent>> watchFamily(String familyId);

  /// Events overlapping [start, end] in the given family.
  Stream<List<CalendarEvent>> watchRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
  });

  Future<void> upsert(CalendarEvent event);

  Future<void> delete({required String familyId, required String eventId});
}

/// In-memory repository for tests / standalone shell-less calendar app.
@immutable
final class MemoryCalendarRepository implements CalendarRepository {
  final Map<String, CalendarEvent> _byId = {};
  final StreamController<List<CalendarEvent>> _ctrl =
      StreamController<List<CalendarEvent>>.broadcast();

  Iterable<CalendarEvent> _family(String familyId) =>
      _byId.values.where((e) => e.familyId == familyId);

  void _emit() {
    _ctrl.add(List.unmodifiable(_byId.values.toList()));
  }

  @override
  Stream<List<CalendarEvent>> watchFamily(String familyId) async* {
    yield _family(familyId).toList();
    await for (final list in _ctrl.stream) {
      yield list.where((e) => e.familyId == familyId).toList();
    }
  }

  @override
  Stream<List<CalendarEvent>> watchRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
  }) async* {
    List<CalendarEvent> filter(Iterable<CalendarEvent> src) => src
        .where(
          (e) =>
              e.familyId == familyId &&
              e.startAt.toUtc().isBefore(end.toUtc()) &&
              e.endAt.toUtc().isAfter(start.toUtc()),
        )
        .toList();

    yield filter(_family(familyId));
    await for (final list in _ctrl.stream) {
      yield filter(list);
    }
  }

  @override
  Future<void> upsert(CalendarEvent event) async {
    _byId[event.id] = event;
    _emit();
  }

  @override
  Future<void> delete({required String familyId, required String eventId}) async {
    final e = _byId[eventId];
    if (e != null && e.familyId == familyId) {
      _byId.remove(eventId);
      _emit();
    }
  }

  /// Seed demo UX / widget tests.
  void seed(Iterable<CalendarEvent> events) {
    for (final e in events) {
      _byId[e.id] = e;
    }
    _emit();
  }
}

/// PostgREST-backed repository with optional offline enqueue.
final class SupabaseCalendarRepository implements CalendarRepository {
  SupabaseCalendarRepository(
    this._client, {
    OfflineWriteQueue? offlineQueue,
    Future<bool> Function()? probeOnline,
    required String tenantId,
    required String actorId,
  }) : _offlineQueue = offlineQueue,
       _probeOnline = probeOnline,
       _tenantId = tenantId,
       _actorId = actorId;

  final SupabaseClient _client;
  final OfflineWriteQueue? _offlineQueue;
  final Future<bool> Function()? _probeOnline;
  final String _tenantId;
  final String _actorId;

  final StreamController<void> _invalidate = StreamController.broadcast();

  Future<bool> _online() async {
    final probe = _probeOnline;
    if (probe == null) return true;
    return probe();
  }

  @override
  Stream<List<CalendarEvent>> watchFamily(String familyId) async* {
    yield await _selectFamily(familyId);
    await for (final _ in _invalidate.stream) {
      yield await _selectFamily(familyId);
    }
  }

  @override
  Stream<List<CalendarEvent>> watchRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
  }) async* {
    yield await _selectRange(familyId, start, end);
    await for (final _ in _invalidate.stream) {
      yield await _selectRange(familyId, start, end);
    }
  }

  Future<List<CalendarEvent>> _selectFamily(String familyId) async {
    final rows = await _client
        .from('calendar_events')
        .select()
        .eq('family_id', familyId)
        .order('start_at');
    return _parseRows(rows);
  }

  Future<List<CalendarEvent>> _selectRange(
    String familyId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('calendar_events')
        .select()
        .eq('family_id', familyId)
        .lt('start_at', end.toUtc().toIso8601String())
        .gt('end_at', start.toUtc().toIso8601String())
        .order('start_at');
    return _parseRows(rows);
  }

  List<CalendarEvent> _parseRows(dynamic rows) {
    final list = rows as List<dynamic>;
    return list
        .map((e) => CalendarEvent.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> upsert(CalendarEvent event) async {
    final row = Map<String, dynamic>.from(event.toJson())
      ..removeWhere((_, v) => v == null);
    final online = await _online();
    final queue = _offlineQueue;
    if (!online && queue != null) {
      final r = await queue.enqueue(
        OfflineWritePayloadBuilder.build(
          tenantId: _tenantId,
          actorId: _actorId,
          targetTable: 'calendar_events',
          operation: 'upsert',
          idempotencyKey: 'cal:${event.familyId}:${event.id}:${event.updatedAt.millisecondsSinceEpoch}',
          payload: row,
        ),
      );
      if (r case Success<void>()) _invalidate.add(null);
      return;
    }
    await _client.from('calendar_events').upsert(row);
    _invalidate.add(null);
  }

  @override
  Future<void> delete({required String familyId, required String eventId}) async {
    final online = await _online();
    final queue = _offlineQueue;
    if (!online && queue != null) {
      final r = await queue.enqueue(
        OfflineWritePayloadBuilder.build(
          tenantId: _tenantId,
          actorId: _actorId,
          targetTable: 'calendar_events',
          operation: 'delete',
          idempotencyKey: 'cal-del:$familyId:$eventId:${DateTime.now().toUtc().millisecondsSinceEpoch}',
          payload: {'id': eventId},
        ),
      );
      if (r case Success<void>()) _invalidate.add(null);
      return;
    }
    await _client.from('calendar_events').delete().eq('id', eventId);
    _invalidate.add(null);
  }
}
