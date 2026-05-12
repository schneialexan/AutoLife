import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../common/failure.dart';
import '../common/result.dart';
import '../common/tenant.dart';
import '../models/system_event.dart';
import '../services/event_producer.dart';
import 'capability.dart';
import 'role.dart';

const String approvalPolicyModule = 'policy';

String approvalNormalizeLocationToken(Object? raw) {
  if (raw == null) return '';
  return raw.toString().trim().toLowerCase();
}

@immutable
final class ApprovalAutoRule {
  const ApprovalAutoRule({
    required this.id,
    required this.familyId,
    required this.role,
    required this.capability,
    required this.label,
    required this.enabled,
    required this.match,
  });

  final String id;
  final String familyId;
  final FamilyRole role;
  final Capability capability;
  final String label;
  final bool enabled;
  final Map<String, dynamic> match;

  bool matchesPayload(Map<String, dynamic> payload) {
    final want = match['location_normalized'];
    if (want == null || '$want'.isEmpty) return false;
    final got = approvalNormalizeLocationToken(payload['location']);
    return got == '$want'.toLowerCase();
  }

  factory ApprovalAutoRule.fromRow(Map<String, dynamic> raw) =>
      ApprovalAutoRule(
        id: raw['id'] as String,
        familyId: raw['family_id'] as String,
        role: FamilyRoleWire.parseWire('${raw['role']}'),
        capability: Capability.parse('${raw['capability']}'),
        label: raw['label'] as String? ?? '',
        enabled: raw['enabled'] as bool? ?? false,
        match: raw['match'] is Map
            ? Map<String, dynamic>.from(raw['match'] as Map)
            : const {},
      );
}

typedef ApprovalPersistFn =
    Future<void> Function(Map<String, dynamic> mergedRow);

typedef ApprovalLookupRulesFn =
    Future<List<ApprovalAutoRule>> Function({
      required String familyId,
      required FamilyRole role,
      required Capability capability,
    });

/// State machine backing `approval_requests`; emits Phase 1.5 events.
///
/// Typed errors use [Failure.code] `approval_illegal_transition` for illegal moves.
final class ApprovalEngine {
  ApprovalEngine({
    required EventProducer eventProducer,
    required Tenant defaultTenant,
    required String actorProfileId,
    Uuid? uuid,
    ApprovalLookupRulesFn? lookupRules,
  }) : _producer = eventProducer,
       _tenant = defaultTenant,
       _actor = actorProfileId,
       _uuid = uuid ?? const Uuid(),
       _lookupRules =
           lookupRules ??
           (({
             required String familyId,
             required FamilyRole role,
             required Capability capability,
           }) async => []);

  final EventProducer _producer;
  final Tenant _tenant;
  final String _actor;
  final Uuid _uuid;
  final ApprovalLookupRulesFn _lookupRules;

  List<ApprovalAutoRule>? _ruleOverride;

  void cacheRulesForNextSubmit(List<ApprovalAutoRule>? rules) {
    _ruleOverride = rules;
  }

  static bool allowedTransition(String from, String to) {
    if (from == 'pending') {
      return to == 'approved' ||
          to == 'rejected' ||
          to == 'expired' ||
          to == 'auto_approved';
    }
    return false;
  }

  Map<String, Object?> _lifecyclePatch({
    required String desiredStatus,
    String? resolverProfileId,
    String? appliedAutoRuleId,
    bool resolverClearsAppliedRule = false,
  }) {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final patch = <String, Object?>{
      'status': desiredStatus,
      'updated_at': nowIso,
    };
    switch (desiredStatus) {
      case 'approved':
      case 'rejected':
      case 'expired':
      case 'auto_approved':
        patch['resolved_at'] = nowIso;
      default:
        break;
    }
    if (resolverProfileId != null) {
      patch['resolver_profile_id'] = resolverProfileId;
    }
    if (resolverClearsAppliedRule) {
      patch['applied_auto_rule_id'] = null;
    } else if (appliedAutoRuleId != null) {
      patch['applied_auto_rule_id'] = appliedAutoRuleId;
    }
    return patch;
  }

  Future<void> _emit(
    String type,
    Map<String, dynamic> payload, {
    required String ik,
  }) async {
    final event = SystemEvent(
      tenantId: _tenant.tenantId,
      actorId: _actor,
      module: approvalPolicyModule,
      type: type,
      payload: payload,
      idempotencyKey: ik,
      occurredAt: DateTime.now().toUtc(),
      orderingTag: 'approval:$ik',
      schemaVersion: 1,
    );
    await _producer.publish(event);
  }

  /// Inserts pending row (caller persists), emits `approval.requested`, evaluates auto-rules.
  Future<Result<Map<String, dynamic>>> submitApprovalRequest({
    required ApprovalPersistFn persist,
    required String familyId,
    required Capability capability,
    required FamilyRole requesterRole,
    required Map<String, dynamic> payload,
    DateTime? expiresAt,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final exp = expiresAt ?? now.add(const Duration(hours: 72));
    var row = <String, dynamic>{
      'id': id,
      'family_id': familyId,
      'requester_profile_id': _actor,
      'capability': capability.wireValue,
      'payload': payload,
      'status': 'pending',
      'expires_at': exp.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    Future<void> save(Map<String, dynamic> delta) async {
      row = {...row, ...delta};
      await persist(UnmodifiableMapView(row));
    }

    await save({});
    await _emit('approval.requested', {
      'approval_id': id,
      'family_id': familyId,
      'capability': capability.wireValue,
    }, ik: '$id:requested');

    final rules =
        _ruleOverride ??
        await _lookupRules(
          familyId: familyId,
          role: requesterRole,
          capability: capability,
        );
    _ruleOverride = null;

    ApprovalAutoRule? matched;
    for (final rule in rules) {
      if (!rule.enabled ||
          rule.role != requesterRole ||
          rule.capability != capability ||
          !rule.matchesPayload(payload)) {
        continue;
      }
      matched = rule;
      break;
    }

    if (matched != null) {
      await save(
        _lifecyclePatch(
          desiredStatus: 'auto_approved',
          appliedAutoRuleId: matched.id,
        ),
      );
      await _emit('approval.resolved', {
        'approval_id': id,
        'family_id': familyId,
        'status': 'auto_approved',
        'auto_rule_id': matched.id,
      }, ik: '$id:auto');
    }

    return Result.success(UnmodifiableMapView(row));
  }

  Future<Result<Map<String, dynamic>>> transitionPending({
    required Map<String, dynamic> rowSnapshot,
    required ApprovalPersistFn persist,
    required String desiredStatus,
    required String resolverProfileId,
  }) async {
    final status = '${rowSnapshot['status']}';
    final id = '${rowSnapshot['id']}';

    if (!allowedTransition(status, desiredStatus)) {
      return Result.failure(
        Failure(
          code: 'approval_illegal_transition',
          message: 'Cannot move approval from $status → $desiredStatus',
        ),
      );
    }

    Future<void> save(Map<String, dynamic> delta) async {
      final next = {...rowSnapshot, ...delta};
      rowSnapshot
        ..clear()
        ..addAll(next);
      await persist(UnmodifiableMapView(next));
    }

    await save(
      _lifecyclePatch(
        desiredStatus: desiredStatus,
        resolverProfileId: resolverProfileId,
        resolverClearsAppliedRule: desiredStatus != 'auto_approved',
      ),
    );

    await _emit('approval.resolved', {
      'approval_id': id,
      'family_id': rowSnapshot['family_id'],
      'status': desiredStatus,
    }, ik: '$id:resolved:$desiredStatus');

    return Result.success(UnmodifiableMapView(rowSnapshot));
  }

  Future<Result<Map<String, dynamic>>> expireStaleIfNeeded({
    required Map<String, dynamic> rowSnapshot,
    required ApprovalPersistFn persist,
  }) async {
    final status = '${rowSnapshot['status']}';
    if (status != 'pending') {
      return Result.success(UnmodifiableMapView(rowSnapshot));
    }

    final expIso = rowSnapshot['expires_at'] as String?;
    if (expIso == null) return Result.success(UnmodifiableMapView(rowSnapshot));

    final exp = DateTime.parse(expIso).toUtc();
    if (!DateTime.now().toUtc().isAfter(exp)) {
      return Result.success(UnmodifiableMapView(rowSnapshot));
    }

    return transitionPending(
      rowSnapshot: rowSnapshot,
      persist: persist,
      desiredStatus: 'expired',
      resolverProfileId: _actor,
    );
  }
}
