import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:yaml/yaml.dart';

/// Parsed default policy matrix from [policy/matrix.yaml] (canonical sort for CI).
final class ParsedPolicyMatrix {
  ParsedPolicyMatrix({required this.capabilities, required this.rows});

  final Map<String, String> capabilities;
  final List<MatrixRow> rows;
}

final class MatrixRow {
  MatrixRow({
    required this.familyRoleWire,
    required this.capability,
    required this.granted,
    required this.requiresParentApproval,
    required this.requirePhotoProof,
    required this.requireParentVerification,
  });

  final String familyRoleWire;
  final String capability;
  final bool granted;
  final bool requiresParentApproval;
  final bool requirePhotoProof;
  final bool requireParentVerification;

  Map<String, dynamic> toJsonSortable() => {
    'family_role': familyRoleWire,
    'capability': capability,
    'granted': granted,
    'requires_parent_approval': requiresParentApproval,
    'require_photo_proof': requirePhotoProof,
    'require_parent_verification': requireParentVerification,
  };
}

const _roleOrder = [
  'owner',
  'partner',
  'child',
  'teenager',
  'grandparent',
  'guest',
  'babysitter',
];

/// Canonical JSON representation (sorted keys / rows) for drift detection.
String policyMatrixCanonicalJson(String yamlSource) =>
    jsonEncode(_canonicalList(parsePolicyMatrixYaml(yamlSource)));

List<Map<String, dynamic>> _canonicalList(ParsedPolicyMatrix m) => m.rows
    .sorted((a, b) {
      final cRole = _compareRoles(a.familyRoleWire, b.familyRoleWire);
      if (cRole != 0) return cRole;
      return a.capability.compareTo(b.capability);
    })
    .map((r) => _sortedMap(r.toJsonSortable()))
    .toList();

Map<String, dynamic> _sortedMap(Map<String, dynamic> row) {
  final entries = row.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  return Map.fromEntries(entries);
}

/// Exposed for `tool/generate_policy_matrix.dart`.
int compareFamilyRoleWire(String a, String b) => _compareRoles(a, b);

int _compareRoles(String a, String b) {
  final ia = _roleOrder.indexOf(a);
  final ib = _roleOrder.indexOf(b);
  final va = ia < 0 ? _roleOrder.length : ia;
  final vb = ib < 0 ? _roleOrder.length : ib;
  final cmp = va.compareTo(vb);
  if (cmp != 0) return cmp;
  return a.compareTo(b);
}

ParsedPolicyMatrix parsePolicyMatrixYaml(String yamlSource) {
  final root = loadYaml(yamlSource);
  if (root is! YamlMap) {
    throw ArgumentError.value(root, 'root', 'matrix.yaml root must be a map');
  }
  final capBlock = root['capabilities'];
  if (capBlock is! YamlMap) {
    throw ArgumentError('capabilities block missing');
  }
  final capabilities = <String, String>{};
  for (final e in capBlock.entries) {
    final id = '${e.key}';
    final v = e.value;
    String label;
    if (v is String) {
      label = v;
    } else if (v is YamlMap) {
      label = '${v['description'] ?? id}';
    } else {
      label = id;
    }
    capabilities[id] = label;
  }
  final matrix = root['matrix'];
  if (matrix is! YamlMap) {
    throw ArgumentError('matrix block missing');
  }
  final rows = <MatrixRow>[];
  for (final roleEntry in matrix.entries) {
    final roleWire = '${roleEntry.key}';
    final cells = roleEntry.value;
    if (cells is! YamlMap) {
      throw ArgumentError('matrix.$roleWire must be a map');
    }
    for (final cell in cells.entries) {
      final cap = '${cell.key}';
      if (!capabilities.containsKey(cap)) {
        throw ArgumentError(
          'Unknown capability $cap under role $roleWire — add it to capabilities:',
        );
      }
      final v = cell.value;
      if (v is! YamlMap) {
        throw ArgumentError('matrix.$roleWire.$cap must be a map');
      }
      final granted = _boolProp(v['granted'], defaultVal: false);
      final reqAp = _boolProp(v['requires_parent_approval'], defaultVal: false);
      final photo = _boolProp(v['require_photo_proof'], defaultVal: false);
      final verify = _boolProp(
        v['require_parent_verification'],
        defaultVal: false,
      );
      rows.add(
        MatrixRow(
          familyRoleWire: roleWire,
          capability: cap,
          granted: granted,
          requiresParentApproval: reqAp,
          requirePhotoProof: photo,
          requireParentVerification: verify,
        ),
      );
    }
  }
  return ParsedPolicyMatrix(capabilities: capabilities, rows: rows);
}

bool _boolProp(Object? yamlValue, {required bool defaultVal}) {
  if (yamlValue == null) return defaultVal;
  if (yamlValue is bool) return yamlValue;
  throw ArgumentError(
    'expected bool, got $yamlValue (${yamlValue.runtimeType})',
  );
}
