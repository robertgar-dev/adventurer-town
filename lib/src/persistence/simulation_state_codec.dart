import 'dart:convert';

import '../domain/domain.dart';

/// Shared, pure decoding for persisted [SimulationState] payloads.
///
/// All repositories store the state as a JSON object (JSON-in-store), so the
/// decode and validation rules live here once rather than being duplicated per
/// backend. A `null` result is the agreed signal that the payload is
/// unreadable — malformed JSON, not a JSON object, or carrying an unsupported
/// schema version — and the caller should recover a safe default state.
class SimulationStateCodec {
  const SimulationStateCodec._();

  /// Decodes a raw JSON string into a [SimulationState], or `null` when the
  /// payload cannot be safely interpreted.
  static SimulationState? decode(String rawJson) {
    Object? decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException {
      return null;
    }
    return decodeValue(decoded);
  }

  /// Restores a [SimulationState] from an already-decoded JSON value, or `null`
  /// when the value is not a JSON object or its schema version is unsupported.
  static SimulationState? decodeValue(Object? decoded) {
    final map = _asStringKeyedMap(decoded);
    if (map == null) {
      return null;
    }
    if (!SimulationState.isSupportedSchemaVersion(map['schemaVersion'])) {
      return null;
    }
    return SimulationState.fromJson(map);
  }

  static Map<String, Object?>? _asStringKeyedMap(Object? decoded) {
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
