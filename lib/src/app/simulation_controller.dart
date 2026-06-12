import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../domain/domain.dart';
import '../persistence/persistence.dart';
import '../simulation/simulation_engine.dart';

class SimulationControllerState {
  const SimulationControllerState({
    required this.simulationState,
    required this.isLoading,
    required this.errorMessage,
    required this.isTicking,
  });

  factory SimulationControllerState.initial() {
    return const SimulationControllerState(
      simulationState: null,
      isLoading: false,
      errorMessage: null,
      isTicking: false,
    );
  }

  final SimulationState? simulationState;
  final bool isLoading;
  final String? errorMessage;
  final bool isTicking;

  SimulationControllerState copyWith({
    SimulationState? simulationState,
    bool? isLoading,
    String? errorMessage,
    bool? isTicking,
  }) {
    return SimulationControllerState(
      simulationState: simulationState ?? this.simulationState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isTicking: isTicking ?? this.isTicking,
    );
  }
}

class SimulationController extends StateNotifier<SimulationControllerState> {
  SimulationController({
    required SimulationRepository repository,
    required SimulationEngine engine,
    required AnalyticsService analyticsService,
    Duration activeTickInterval = const Duration(
      seconds: SimulationState.fixedTickIntervalSeconds,
    ),
  })  : _repository = repository,
        _engine = engine,
        _analyticsService = analyticsService,
        _activeTickInterval = activeTickInterval,
        super(SimulationControllerState.initial());

  final SimulationRepository _repository;
  final SimulationEngine _engine;
  final AnalyticsService _analyticsService;
  final Duration _activeTickInterval;

  Timer? _timer;
  bool _tickInFlight = false;

  Future<void> loadOrCreate() async {
    if (!mounted) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final loaded = await _repository.loadState();
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        simulationState: loaded,
        isLoading: false,
        errorMessage: null,
      );
      await _analyticsService.logEvent('foundation_state_loaded');
    } catch (error) {
      final fallback = SimulationState.newGame();
      await _repository.saveState(fallback);
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        simulationState: fallback,
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> tickOnce({DateTime? resolvedAtUtc}) async {
    if (_tickInFlight || !mounted) {
      return;
    }

    _tickInFlight = true;
    try {
      final current = state.simulationState ?? await _repository.loadState();
      final result = _engine.tick(current, resolvedAtUtc: resolvedAtUtc);
      await _repository.saveState(result.state);
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        simulationState: result.state,
        errorMessage: null,
      );
    } catch (error) {
      if (mounted) {
        state = state.copyWith(errorMessage: error.toString());
      }
    } finally {
      _tickInFlight = false;
    }
  }

  Future<bool> upgradeBuilding(
    BuildingType buildingType,
    UpgradeAxis axis,
  ) async {
    if (!mounted) {
      return false;
    }

    try {
      final current = state.simulationState ?? await _repository.loadState();
      final building = current.buildings[buildingType];
      if (building == null) {
        state = state.copyWith(errorMessage: 'Building not found.');
        return false;
      }

      final quote = UpgradeRules.quote(
        building: building,
        resources: current.resources,
        axis: axis,
      );
      final cost = quote.cost;
      final nextLevel = quote.nextLevel;
      if (!quote.canPurchase || cost == null || nextLevel == null) {
        state = state.copyWith(errorMessage: _upgradeBlockedMessage(quote));
        return false;
      }

      final buildings = Map<BuildingType, Building>.from(current.buildings);
      buildings[buildingType] = _withUpgradedLevel(
        building,
        axis: axis,
        nextLevel: nextLevel,
      );
      final event = _upgradeEvent(
        state: current,
        building: buildings[buildingType]!,
        axis: axis,
        cost: cost,
        nextLevel: nextLevel,
      );
      final nextState = current.copyWith(
        resources: current.resources.spendGold(cost),
        buildings: buildings,
        eventFeed: [event, ...current.eventFeed],
      );

      await _repository.saveState(nextState);
      if (!mounted) {
        return true;
      }

      state = state.copyWith(
        simulationState: nextState,
        errorMessage: null,
      );
      return true;
    } catch (error) {
      if (mounted) {
        state = state.copyWith(errorMessage: error.toString());
      }
      return false;
    }
  }

  void startActiveLoop() {
    if (_timer != null) {
      return;
    }

    _timer = Timer.periodic(_activeTickInterval, (_) {
      unawaited(tickOnce());
    });
    state = state.copyWith(isTicking: true);
  }

  void stopActiveLoop() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isTicking: false);
  }

  Building _withUpgradedLevel(
    Building building, {
    required UpgradeAxis axis,
    required int nextLevel,
  }) {
    switch (axis) {
      case UpgradeAxis.capacity:
        return building.copyWith(capacityLevel: nextLevel);
      case UpgradeAxis.value:
        return building.copyWith(valueLevel: nextLevel);
    }
  }

  EventFeedEntry _upgradeEvent({
    required SimulationState state,
    required Building building,
    required UpgradeAxis axis,
    required int cost,
    required int nextLevel,
  }) {
    return EventFeedEntry(
      id: 'event_${state.currentTick}_${building.buildingType.code}_${axis.code}_upgrade_$nextLevel',
      eventType: EventType.buildingUpgraded,
      createdTick: state.currentTick,
      createdAtUtc: DateTime.now().toUtc(),
      templateId: 'building_upgraded',
      adventurerId: null,
      adventurerTier: null,
      buildingType: building.buildingType,
      demandType: building.servedDemandType,
      upgradeAxis: axis,
      goldDelta: -cost,
      reputationDelta: 0,
      wasOffline: false,
      priority: 2,
      variables: {
        'building_type': building.buildingType.code,
        'demand_type': building.servedDemandType.code,
        'upgrade_axis': axis.code,
        'level': nextLevel.toString(),
        'cost': cost.toString(),
      },
    );
  }

  String _upgradeBlockedMessage(UpgradeQuote quote) {
    if (quote.isMaxLevel) {
      return 'Max Level';
    }
    if (!quote.isConstructed) {
      return 'Building is not constructed.';
    }
    if (!quote.hasEnoughReputation) {
      return 'Requires ${quote.requiredReputation} Reputation.';
    }
    if (!quote.hasEnoughGold && quote.cost != null) {
      return 'Need ${quote.cost} Gold.';
    }
    return 'Upgrade unavailable.';
  }

  @override
  void dispose() {
    stopActiveLoop();
    super.dispose();
  }
}
