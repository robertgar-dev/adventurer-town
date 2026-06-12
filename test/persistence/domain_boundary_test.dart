import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture guard: the simulation domain must stay pure Dart and remain
/// independent of the persistence implementation. Isar access is only allowed
/// inside the persistence layer (lib/src/persistence). This scan fails if an
/// Isar import or annotation leaks into lib/src/domain.
void main() {
  group('Domain layer boundary', () {
    final domainDirectory = Directory('lib/src/domain');

    List<File> domainDartFiles() {
      expect(
        domainDirectory.existsSync(),
        isTrue,
        reason: 'Expected lib/src/domain to exist (run from package root).',
      );
      return domainDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();
    }

    test('contains no Isar imports', () {
      final offenders = <String>[];
      for (final file in domainDartFiles()) {
        final contents = file.readAsStringSync();
        if (contents.contains('package:isar') ||
            contents.contains('isar_community')) {
          offenders.add(file.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'Isar imports must not appear in domain files: $offenders',
      );
    });

    test('contains no Isar annotations or generated parts', () {
      final isarAnnotations = RegExp(
        r'@(collection|Collection|Name|Index|Backlink|Enumerated|ignore'
        r'|Id|embedded)\b',
      );
      final offenders = <String>[];
      for (final file in domainDartFiles()) {
        final contents = file.readAsStringSync();
        // No Isar Id typedef usage, annotations, or generated *.g.dart parts.
        if (isarAnnotations.hasMatch(contents) ||
            contents.contains('CollectionSchema') ||
            contents.contains("part '") && contents.contains('.g.dart')) {
          offenders.add(file.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'Isar annotations must not appear in domain files: $offenders',
      );
    });

    test('every domain file is plain .dart with no generated companion', () {
      final generated = domainDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.g.dart'))
          .toList();

      expect(
        generated,
        isEmpty,
        reason: 'Domain must not contain generated Isar files: $generated',
      );
    });
  });
}
