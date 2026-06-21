import 'enums.dart';

/// The three rendered quality grades per building (empty furnished shells).
enum BuildingGrade { humble, established, grand }

/// Resolves building shell art by type + grade. Type/grade in, paths computed —
/// no hardcoded image references in logic (mirrors [CharacterArt]).
class BuildingArt {
  const BuildingArt._();

  /// Shipped, game-ready building shell directory.
  static const String buildingsDir = 'assets/buildings';

  static const Map<BuildingType, String> _slug = {
    BuildingType.inn: 'inn',
    BuildingType.tavern: 'tavern',
    BuildingType.blacksmith: 'blacksmith',
    BuildingType.healer: 'healer',
    BuildingType.market: 'market',
  };

  /// e.g. `assets/buildings/bld_inn_humble.png`.
  static String shellPath(BuildingType type, BuildingGrade grade) =>
      '$buildingsDir/bld_${_slug[type]}_${grade.name}.png';

  /// Data-driven grade from a building's upgrade band. Reputation gates sit at
  /// levels 4 / 7 / 10, so: 1–3 humble, 4–6 established, 7+ grand.
  static BuildingGrade gradeForLevel(int capacityLevel) {
    if (capacityLevel <= 3) {
      return BuildingGrade.humble;
    }
    if (capacityLevel <= 6) {
      return BuildingGrade.established;
    }
    return BuildingGrade.grand;
  }
}
