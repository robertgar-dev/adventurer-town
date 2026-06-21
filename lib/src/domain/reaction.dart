import 'building_art.dart';

/// How an adventurer reads after being served, derived from the grade of the
/// service received. The visible expression (the Package C "beam") is gated
/// behind the FD7 sprite re-render — this is the STATE that visual attaches to
/// when it lands; nothing is rendered for it yet.
enum Reaction { served, pleased, elated }

/// Grade ladder -> reaction. Exhaustive switch on [BuildingGrade]: adding a
/// grade forces a compile error here rather than a silent null reaction.
///
/// Slice 1.5 derives this from the serving building's CURRENT grade as a
/// display-time value. With R3 out and adventurers transient, an occupant only
/// exists in the room DURING current service, so current-grade and
/// service-tick-grade are identical for every case that can occur now. Durable
/// service-tick capture (stamp-at-service vs. re-derive) is deferred to the
/// R3 / persistence decision.
Reaction reactionForServiceGrade(BuildingGrade grade) {
  switch (grade) {
    case BuildingGrade.humble:
      return Reaction.served;
    case BuildingGrade.established:
      return Reaction.pleased;
    case BuildingGrade.grand:
      return Reaction.elated;
  }
}
