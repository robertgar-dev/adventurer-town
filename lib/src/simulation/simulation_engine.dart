import '../domain/domain.dart';
import 'deterministic_random.dart';

class SimulationTickResult {
  const SimulationTickResult({
    required this.state,
    required this.emittedEvents,
  });

  final SimulationState state;
  final List<EventFeedEntry> emittedEvents;
}

class SimulationEngine {
  const SimulationEngine();

  SimulationTickResult tick(
    SimulationState state, {
    DateTime? resolvedAtUtc,
  }) {
    final processingTick = state.currentTick + 1;
    final now = (resolvedAtUtc ?? DateTime.now()).toUtc();
    var resources = state.resources;
    final buildings = <BuildingType, Building>{
      for (final entry in state.buildings.entries)
        entry.key: entry.value.resetTickOccupancy(),
    };
    final adventurers = Map<String, Adventurer>.from(state.adventurers);
    final demands = Map<String, Demand>.from(state.activeDemands);
    final emittedEvents = <EventFeedEntry>[];
    final eventFeed = <EventFeedEntry>[...state.eventFeed];
    final tickOccupancy = <BuildingType, int>{
      for (final type in BuildingType.values) type: 0,
    };

    final generated = _generateDemands(state, processingTick);
    for (final entry in generated.entries) {
      final adventurer = entry.key;
      final demand = entry.value;
      adventurers[adventurer.id] = adventurer.copyWith(
        currentDemandId: demand.id,
        state: AdventurerState.seekingService,
      );
      demands[demand.id] = demand;
      final generatedEvent = _event(
        id: 'event_${processingTick}_${demand.id}_generated',
        eventType: EventType.demandGenerated,
        tick: processingTick,
        now: now,
        templateId: 'demand_generated',
        adventurer: adventurer,
        demand: demand,
        goldDelta: 0,
        reputationDelta: 0,
      );
      emittedEvents.add(generatedEvent);
      eventFeed.insert(0, generatedEvent);
    }

    final demandIds = demands.keys.toList()..sort();
    for (final demandId in demandIds) {
      final demand = demands[demandId];
      if (demand == null || demand.status != DemandStatus.pending) {
        demands.remove(demandId);
        continue;
      }

      var building = buildings[demand.targetBuildingType] ??
          Building.forType(demand.targetBuildingType);
      building = building.recordDemandReceived();

      final usedCapacity = tickOccupancy[demand.targetBuildingType] ?? 0;
      final hasCapacity =
          building.isConstructed && usedCapacity < building.capacityPerTick;
      final adventurer = adventurers[demand.adventurerId];

      if (hasCapacity) {
        final completedDemand = demand.markServed(processingTick);
        final goldEarned = _goldFor(completedDemand, building, adventurer);
        final reputationEarned = completedDemand.wasOfflineResolved
            ? 0
            : _reputationFor(completedDemand, adventurer);
        resources =
            resources.addGold(goldEarned).addReputation(reputationEarned);

        final nextOccupancy = usedCapacity + 1;
        final event = _event(
          id: 'event_${processingTick}_${demand.id}_served',
          eventType: EventType.demandServed,
          tick: processingTick,
          now: now,
          templateId: 'demand_served',
          adventurer: adventurer,
          demand: completedDemand,
          goldDelta: goldEarned,
          reputationDelta: reputationEarned,
        );
        building = building.recordDemandServed(
          goldEarned: goldEarned,
          occupancy: nextOccupancy,
          eventId: event.id,
        );
        tickOccupancy[demand.targetBuildingType] = nextOccupancy;
        adventurers[demand.adventurerId] = (adventurer ??
                Adventurer.create(
                  id: demand.adventurerId,
                  displayName: 'Adventurer',
                  tier: AdventurerTier.novice,
                  preferredDemandTypes: [demand.demandType],
                  arrivalTick: processingTick,
                ))
            .copyWith(
          state: AdventurerState.departing,
          currentDemandId: null,
          departureTick: processingTick,
          lastServiceBuildingType: demand.targetBuildingType,
          lastOutcomeEventId: event.id,
        );
        emittedEvents.add(event);
        eventFeed.insert(0, event);
      } else {
        final missedDemand = demand.markMissed(processingTick);
        final event = _event(
          id: 'event_${processingTick}_${demand.id}_missed',
          eventType: EventType.demandMissed,
          tick: processingTick,
          now: now,
          templateId: 'demand_missed_capacity',
          adventurer: adventurer,
          demand: missedDemand,
          goldDelta: 0,
          reputationDelta: 0,
        );
        building = building.recordDemandLost(eventId: event.id);
        adventurers[demand.adventurerId] = (adventurer ??
                Adventurer.create(
                  id: demand.adventurerId,
                  displayName: 'Adventurer',
                  tier: AdventurerTier.novice,
                  preferredDemandTypes: [demand.demandType],
                  arrivalTick: processingTick,
                ))
            .copyWith(
          state: AdventurerState.departing,
          currentDemandId: null,
          departureTick: processingTick,
          lastOutcomeEventId: event.id,
        );
        emittedEvents.add(event);
        eventFeed.insert(0, event);
      }

      buildings[demand.targetBuildingType] = building;
      demands.remove(demandId);
    }

    final nextState = state.copyWith(
      currentTick: processingTick,
      lastResolvedTickAtUtc: now,
      resources: resources,
      buildings: buildings,
      adventurers: adventurers,
      activeDemands: demands,
      eventFeed: eventFeed,
      currentTimeOfDay: timeOfDayForTick(processingTick),
    );

    return SimulationTickResult(
      state: nextState,
      emittedEvents: List.unmodifiable(emittedEvents),
    );
  }

  SimulationTickResult runTicks(
    SimulationState initialState, {
    required int count,
    DateTime? firstResolvedAtUtc,
  }) {
    var state = initialState;
    final emittedEvents = <EventFeedEntry>[];
    final start =
        (firstResolvedAtUtc ?? initialState.lastResolvedTickAtUtc).toUtc();

    for (var i = 0; i < count; i += 1) {
      final result = tick(
        state,
        resolvedAtUtc: start.add(
          Duration(seconds: SimulationState.fixedTickIntervalSeconds * i),
        ),
      );
      state = result.state;
      emittedEvents.addAll(result.emittedEvents);
    }

    return SimulationTickResult(
      state: state,
      emittedEvents: List.unmodifiable(emittedEvents),
    );
  }

  Map<Adventurer, Demand> _generateDemands(
    SimulationState state,
    int processingTick,
  ) {
    final constructedBuildings = {
      for (final entry in state.buildings.entries)
        entry.key: entry.value.isConstructed,
    };
    final eligibleDemandTypes =
        EconomyConstants.eligibleDemandTypesForBuildings(
      constructedBuildings,
    );
    final demandPool =
        eligibleDemandTypes.isEmpty ? DemandType.values : eligibleDemandTypes;
    final tierWeights = EconomyConstants.spawnWeightsFor(state.unlockedTiers);
    final rng = DeterministicRandom(
      _seedForTick(state.randomSeed, processingTick),
    );
    final generated = <Adventurer, Demand>{};
    final trafficSlots = _trafficSlotsFor(tierWeights);

    for (var slot = 0; slot < trafficSlots; slot += 1) {
      final tier = _selectWeightedTier(tierWeights, rng);
      final demandCount = EconomyConstants.demandsPerGeneration[tier]!;
      for (var demandIndex = 0; demandIndex < demandCount; demandIndex += 1) {
        final demandType = _selectWeightedDemand(demandPool, rng);
        final adventurerId =
            'adv_${state.randomSeed}_${processingTick}_${slot}_$demandIndex';
        final demandId =
            'demand_${state.randomSeed}_${processingTick}_${slot}_$demandIndex';
        final adventurer = Adventurer.create(
          id: adventurerId,
          displayName: _nameFor(state.randomSeed, processingTick, slot),
          tier: tier,
          preferredDemandTypes: demandPool,
          arrivalTick: processingTick,
          wealthBand: (state.randomSeed + processingTick + slot) % 3,
        );
        final demand = Demand.create(
          id: demandId,
          adventurerId: adventurerId,
          demandType: demandType,
          createdTick: processingTick,
          goldValue: EconomyConstants.demandGoldReward[demandType]!,
          reputationValue: EconomyConstants.demandReputationReward[demandType]!,
        );
        generated[adventurer] = demand;
      }
    }

    return generated;
  }

  static int _goldFor(
    Demand demand,
    Building building,
    Adventurer? adventurer,
  ) {
    final tierMultiplier = EconomyConstants
        .adventurerRewardMultiplier[adventurer?.tier ?? AdventurerTier.novice]!;
    final buildingMultiplier = EconomyConstants.buildingValueMultiplier(
      building.buildingType,
      building.valueLevel,
    );
    return (demand.goldValue * buildingMultiplier * tierMultiplier).floor();
  }

  static int _reputationFor(Demand demand, Adventurer? adventurer) {
    final tierMultiplier = EconomyConstants
        .adventurerRewardMultiplier[adventurer?.tier ?? AdventurerTier.novice]!;
    return (demand.reputationValue * tierMultiplier).floor();
  }

  static int _seedForTick(int seed, int tick) {
    return seed ^ (tick * 0x45d9f3b);
  }

  static int _trafficSlotsFor(Map<AdventurerTier, int> tierWeights) {
    var maxFrequency = 1;
    for (final entry in tierWeights.entries) {
      if (entry.value <= 0) {
        continue;
      }
      final frequency = EconomyConstants.tierDemandFrequencyTicks[entry.key]!;
      if (frequency > maxFrequency) {
        maxFrequency = frequency;
      }
    }
    return maxFrequency;
  }

  static AdventurerTier _selectWeightedTier(
    Map<AdventurerTier, int> weights,
    DeterministicRandom rng,
  ) {
    final total = weights.values.fold<int>(0, (sum, weight) => sum + weight);
    var roll = rng.nextOneBasedRoll(total);
    for (final tier in AdventurerTier.values) {
      final weight = weights[tier] ?? 0;
      if (weight <= 0) {
        continue;
      }
      if (roll <= weight) {
        return tier;
      }
      roll -= weight;
    }
    return AdventurerTier.novice;
  }

  static DemandType _selectWeightedDemand(
    List<DemandType> demandPool,
    DeterministicRandom rng,
  ) {
    final total = demandPool.fold<int>(
      0,
      (sum, type) => sum + EconomyConstants.demandGenerationWeight[type]!,
    );
    var roll = rng.nextOneBasedRoll(total);
    for (final type in demandPool) {
      final weight = EconomyConstants.demandGenerationWeight[type]!;
      if (roll <= weight) {
        return type;
      }
      roll -= weight;
    }
    return demandPool.first;
  }

  static EventFeedEntry _event({
    required String id,
    required EventType eventType,
    required int tick,
    required DateTime now,
    required String templateId,
    required Adventurer? adventurer,
    required Demand demand,
    required int goldDelta,
    required int reputationDelta,
  }) {
    return EventFeedEntry(
      id: id,
      eventType: eventType,
      createdTick: tick,
      createdAtUtc: now,
      templateId: templateId,
      adventurerId: adventurer?.id ?? demand.adventurerId,
      adventurerTier: adventurer?.tier,
      buildingType: demand.targetBuildingType,
      demandType: demand.demandType,
      upgradeAxis: null,
      goldDelta: goldDelta,
      reputationDelta: reputationDelta,
      wasOffline: demand.wasOfflineResolved,
      priority: eventType == EventType.demandMissed ? 2 : 1,
      variables: {
        'demand_type': demand.demandType.code,
        'building_type': demand.targetBuildingType.code,
        if (adventurer != null) 'adventurer_tier': adventurer.tier.code,
      },
    );
  }

  static String _nameFor(int seed, int tick, int index) {
    const names = [
      'Ari',
      'Bryn',
      'Cato',
      'Dara',
      'Elian',
      'Fia',
      'Galen',
      'Hana',
    ];
    return names[(seed + tick + index) % names.length];
  }
}
