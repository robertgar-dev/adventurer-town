import 'package:adventurer_town/src/domain/building_art.dart';
import 'package:adventurer_town/src/domain/reaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('grade ladder maps to reaction (served / pleased / elated)', () {
    expect(reactionForServiceGrade(BuildingGrade.humble), Reaction.served);
    expect(reactionForServiceGrade(BuildingGrade.established), Reaction.pleased);
    expect(reactionForServiceGrade(BuildingGrade.grand), Reaction.elated);
  });

  test('the grade -> reaction mapping is TOTAL (every grade maps)', () {
    // Guards against a silent null/unhandled reaction if a grade is ever added.
    for (final grade in BuildingGrade.values) {
      expect(reactionForServiceGrade(grade), isA<Reaction>());
    }
    final mapped = BuildingGrade.values.map(reactionForServiceGrade).toSet();
    expect(mapped.length, BuildingGrade.values.length,
        reason: 'each grade maps to a distinct reaction');
  });
}
