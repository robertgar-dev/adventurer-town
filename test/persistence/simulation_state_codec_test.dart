import 'dart:convert';

import 'package:adventurer_town/src/domain/domain.dart';
import 'package:adventurer_town/src/persistence/persistence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimulationStateCodec', () {
    test('decodes a well-formed payload with the supported schema version', () {
      final state = SimulationState.newGame(nowUtc: DateTime.utc(2026, 6, 9))
          .copyWith(currentTick: 12);
      final restored = SimulationStateCodec.decode(jsonEncode(state.toJson()));

      expect(restored, isNotNull);
      expect(restored!.schemaVersion, SimulationState.currentSchemaVersion);
      expect(restored.currentTick, 12);
    });

    test('returns null for corrupt JSON', () {
      expect(SimulationStateCodec.decode('{ this is not json'), isNull);
    });

    test('returns null for a non-map JSON payload', () {
      expect(SimulationStateCodec.decode('[1, 2, 3]'), isNull);
      expect(SimulationStateCodec.decode('42'), isNull);
      expect(SimulationStateCodec.decodeValue(<Object?>['a', 'b']), isNull);
    });

    test('returns null when the schema version is missing', () {
      final json = SimulationState.newGame().toJson()..remove('schemaVersion');
      expect(SimulationStateCodec.decodeValue(json), isNull);
    });

    test('returns null for an unsupported (future) schema version', () {
      final json = SimulationState.newGame().toJson()
        ..['schemaVersion'] = SimulationState.currentSchemaVersion + 1;
      expect(SimulationStateCodec.decodeValue(json), isNull);

      final farFuture = SimulationState.newGame().toJson()
        ..['schemaVersion'] = 999;
      expect(SimulationStateCodec.decodeValue(farFuture), isNull);
    });

    test('isSupportedSchemaVersion only accepts known versions', () {
      expect(
        SimulationState.isSupportedSchemaVersion(
          SimulationState.currentSchemaVersion,
        ),
        isTrue,
      );
      expect(SimulationState.isSupportedSchemaVersion(2), isFalse);
      expect(SimulationState.isSupportedSchemaVersion(0), isFalse);
      expect(SimulationState.isSupportedSchemaVersion(-1), isFalse);
      expect(SimulationState.isSupportedSchemaVersion(null), isFalse);
      expect(SimulationState.isSupportedSchemaVersion('1'), isFalse);
    });
  });
}
