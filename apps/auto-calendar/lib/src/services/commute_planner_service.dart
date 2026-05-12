import 'package:autolife_core/autolife_core.dart';

typedef CommuteEtaResolver = Future<Duration?> Function({
  required String origin,
  required String destination,
  required DateTime arriveBy,
});

/// Computes gray travel blocks around located events (Maps connector in prod).
final class CommutePlannerService {
  CommutePlannerService({CommuteEtaResolver? resolveEta})
      : _resolveEta = resolveEta ?? _defaultEta;

  final CommuteEtaResolver _resolveEta;

  /// Deterministic ETA used in widget/integration tests when resolver unset.
  Duration get defaultEta => const Duration(minutes: 15);

  static Future<Duration?> _defaultEta({
    required String origin,
    required String destination,
    required DateTime arriveBy,
  }) async =>
      const Duration(minutes: 15);

  Future<CalendarEvent?> buildTravelBlock({
    required CalendarEvent anchor,
    String originLabel = 'Home',
  }) async {
    if (anchor.location == null || anchor.location!.isEmpty) return null;
    final eta = await _resolveEta(
      origin: originLabel,
      destination: anchor.location!,
      arriveBy: anchor.startAt.toUtc(),
    );
    if (eta == null) return null;
    final start = anchor.startAt.toUtc().subtract(eta);
    final now = DateTime.now().toUtc();
    return CalendarEvent(
      id: '${anchor.id}-commute',
      familyId: anchor.familyId,
      title: 'Travel · ${anchor.location}',
      startAt: start,
      endAt: anchor.startAt.toUtc(),
      allDay: false,
      createdBy: anchor.createdBy,
      syncSource: 'commute_synthetic',
      commuteMeta: {
        'anchor_event_id': anchor.id,
        'eta_minutes': eta.inMinutes,
      },
      createdAt: now,
      updatedAt: now,
    );
  }
}
