import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';
import '../domain/domain.dart';
import '../persistence/persistence.dart';
import '../simulation/offline_progression.dart';
import '../simulation/simulation_engine.dart';

/// The one-time onboarding hints M9 can surface. Display-state only.
enum OnboardingHint {
  welcome,
  resources,
  eventFeed,
  buildingDetail,
  offline,
}

class SimulationControllerState {
  const SimulationControllerState({
    required this.simulationState,
    required this.isLoading,
    required this.errorMessage,
    required this.isTicking,
    this.offlineSummary,
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

  /// WP-M7-06: set once after offline resolution so the UI can show a minimal
  /// return summary; cleared when the player dismisses it.
  final OfflineResolution? offlineSummary;

  SimulationControllerState copyWith({
    SimulationState? simulationState,
    bool? isLoading,
    String? errorMessage,
    bool? isTicking,
    OfflineResolution? offlineSummary,
    bool clearOfflineSummary = false,
  }) {
    return SimulationControllerState(
      simulationState: simulationState ?? this.simulationState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isTicking: isTicking ?? this.isTicking,
      offlineSummary:
          clearOfflineSummary ? null : (offlineSummary ?? this.offlineSummary),
    );
  }
}

class SimulationController extends StateNotifier<SimulationControllerState> {
  SimulationController({
    required SimulationRepository repository,
    required SimulationEngine engine,
    required AnalyticsService analyticsService,
    OfflineProgressionResolver? offlineResolver,
    Duration activeTickInterval = const Duration(
      seconds: SimulationState.fixedTickIntervalSeconds,
    ),
  })  : _repository = repository,
        _engine = engine,
        _analyticsService = analyticsService,
        _offlineResolver =
            offlineResolver ?? OfflineProgressionResolver(engine: engine),
        _activeTickInterval = activeTickInterval,
        super(SimulationControllerState.initial());

  final SimulationRepository _repository;
  final SimulationEngine _engine;
  final AnalyticsService _analyticsService;
  final OfflineProgressionResolver _offlineResolver;
  final Duration _activeTickInterval;

  Timer? _timer;
  bool _tickInFlight = false;
  bool _eventFeedSeenLogged = false;

  /// M10: fire-and-forget analytics emit. Never awaited, never throws into
  /// gameplay (errors are swallowed), so analytics can never block or break
  /// the simulation, persistence, UI, onboarding, or upgrades.
  void _emit(String name, [Map<String, Object?> properties = const {}]) {
    unawaited(
      _analyticsService
          .logEvent(name, parameters: properties)
          .catchError((Object _) {}),
    );
  }

  Future<void> loadOrCreate() async {
    if (!mounted) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final loaded = await _repository.loadState();

      // WP-M7-03: resolve any offline progression once, immediately after load,
      // and persist the resolved state before live ticking begins. This runs
      // before startActiveLoop(), so there is never concurrent active ticking.
      final resolution = _offlineResolver.resolve(
        loaded,
        nowUtc: DateTime.now().toUtc(),
      );
      var current = loaded;
      OfflineResolution? summary;
      if (resolution.didResolve) {
        current = resolution.state;
        await _repository.saveState(current);
        summary = resolution;
      }

      // M10: first local session on this save is emitted once and persisted.
      final wasFirstSession = !current.settings.firstSessionStarted;
      if (wasFirstSession) {
        current = current.copyWith(
          settings: current.settings.copyWith(firstSessionStarted: true),
        );
        await _repository.saveState(current);
      }

      if (!mounted) {
        return;
      }
      state = state.copyWith(
        simulationState: current,
        isLoading: false,
        errorMessage: null,
        offlineSummary: summary,
      );

      // M10 analytics: emitted after the accepted load outcome, never awaited.
      _emit(AnalyticsEvents.appStart, {
        AnalyticsProperties.currentTick: current.currentTick,
        AnalyticsProperties.gold: current.resources.gold,
        AnalyticsProperties.reputation: current.resources.reputation,
        AnalyticsProperties.isFirstSession: wasFirstSession ? 1 : 0,
      });
      if (wasFirstSession) {
        _emit(AnalyticsEvents.firstSessionStarted, {
          AnalyticsProperties.currentTick: current.currentTick,
        });
      }
      if (summary != null) {
        _emit(AnalyticsEvents.offlineReturnSeen, {
          AnalyticsProperties.offlineElapsedSeconds: summary.elapsedSeconds,
          AnalyticsProperties.demandServed: summary.demandServed,
          AnalyticsProperties.demandMissed: summary.demandMissed,
          AnalyticsProperties.gold: current.resources.gold,
          AnalyticsProperties.reputation: current.resources.reputation,
          AnalyticsProperties.currentTick: current.currentTick,
          AnalyticsProperties.wasOffline: 1,
        });
      }
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
      // M10: the first upgrade is emitted once; flag persisted alongside save.
      final wasFirstUpgrade = !current.settings.firstUpgradePurchased;
      final nextState = current.copyWith(
        resources: current.resources.spendGold(cost),
        buildings: buildings,
        eventFeed: [event, ...current.eventFeed],
        settings: wasFirstUpgrade
            ? current.settings.copyWith(firstUpgradePurchased: true)
            : null,
      );

      await _repository.saveState(nextState);
      if (!mounted) {
        return true;
      }

      state = state.copyWith(
        simulationState: nextState,
        errorMessage: null,
      );

      // M10 analytics: emitted after the accepted purchase outcome.
      final upgradeProps = <String, Object?>{
        AnalyticsProperties.buildingType: buildingType.code,
        AnalyticsProperties.upgradeAxis: axis.code,
        AnalyticsProperties.currentTick: nextState.currentTick,
        AnalyticsProperties.gold: nextState.resources.gold,
        AnalyticsProperties.reputation: nextState.resources.reputation,
      };
      _emit(
        axis == UpgradeAxis.capacity
            ? AnalyticsEvents.capacityUpgradePurchased
            : AnalyticsEvents.valueUpgradePurchased,
        upgradeProps,
      );
      if (wasFirstUpgrade) {
        _emit(AnalyticsEvents.firstUpgradePurchased, upgradeProps);
      }
      return true;
    } catch (error) {
      if (mounted) {
        state = state.copyWith(errorMessage: error.toString());
      }
      return false;
    }
  }

  void dismissOfflineSummary() {
    if (!mounted) {
      return;
    }
    state = state.copyWith(clearOfflineSummary: true);
  }

  /// M9: records that a one-time onboarding hint has been seen, persisting the
  /// flag in [GameSettings]. Idempotent — a no-op if already seen. This only
  /// touches non-economy display state; simulation fields are untouched.
  Future<void> markOnboardingHintSeen(OnboardingHint hint) async {
    final current = state.simulationState;
    if (current == null) {
      return;
    }
    final settings = current.settings;
    if (_onboardingHintSeen(settings, hint)) {
      return;
    }

    final markedSettings = switch (hint) {
      OnboardingHint.welcome => settings.copyWith(welcomeSeen: true),
      OnboardingHint.resources => settings.copyWith(resourcesHintSeen: true),
      OnboardingHint.eventFeed => settings.copyWith(eventFeedHintSeen: true),
      OnboardingHint.buildingDetail =>
        settings.copyWith(buildingDetailHintSeen: true),
      OnboardingHint.offline => settings.copyWith(offlineHintSeen: true),
    };

    // M10: the minimum onboarding learning loop is the four teaching hints
    // (welcome, Gold/Reputation, Event Feed, Capacity vs Value). The offline
    // hint is excluded because a first session may never go offline.
    final teachingComplete = markedSettings.welcomeSeen &&
        markedSettings.resourcesHintSeen &&
        markedSettings.eventFeedHintSeen &&
        markedSettings.buildingDetailHintSeen;
    final completedNow =
        teachingComplete && !markedSettings.onboardingCompleted;
    final nextSettings = completedNow
        ? markedSettings.copyWith(onboardingCompleted: true)
        : markedSettings;

    final nextState = current.copyWith(settings: nextSettings);
    if (mounted) {
      state = state.copyWith(simulationState: nextState);
    }
    await _repository.saveState(nextState);

    // M10 analytics.
    _emit(AnalyticsEvents.onboardingHintDismissed, {
      AnalyticsProperties.hintId: hint.name,
    });
    if (completedNow) {
      _emit(AnalyticsEvents.onboardingCompleted, {
        AnalyticsProperties.currentTick: nextState.currentTick,
      });
    }
  }

  /// M10: UI signal that the player opened a Building Detail screen. Emitted
  /// per open (a discrete user action), never in a render loop.
  void logBuildingDetailOpened(BuildingType buildingType) {
    if (!mounted) {
      return;
    }
    final current = state.simulationState;
    _emit(AnalyticsEvents.buildingDetailOpened, {
      AnalyticsProperties.buildingType: buildingType.code,
      AnalyticsProperties.currentTick: current?.currentTick ?? 0,
      AnalyticsProperties.gold: current?.resources.gold ?? 0,
      AnalyticsProperties.reputation: current?.resources.reputation ?? 0,
    });
  }

  /// M10: UI signal that the Event Feed is meaningfully visible (it has
  /// entries). Emitted at most once per session to stay event-light.
  void notifyEventFeedSeen() {
    if (!mounted || _eventFeedSeenLogged) {
      return;
    }
    final current = state.simulationState;
    if (current == null || current.eventFeed.isEmpty) {
      return;
    }
    _eventFeedSeenLogged = true;
    _emit(AnalyticsEvents.eventFeedSeen, {
      AnalyticsProperties.currentTick: current.currentTick,
    });
  }

  static bool _onboardingHintSeen(GameSettings settings, OnboardingHint hint) {
    switch (hint) {
      case OnboardingHint.welcome:
        return settings.welcomeSeen;
      case OnboardingHint.resources:
        return settings.resourcesHintSeen;
      case OnboardingHint.eventFeed:
        return settings.eventFeedHintSeen;
      case OnboardingHint.buildingDetail:
        return settings.buildingDetailHintSeen;
      case OnboardingHint.offline:
        return settings.offlineHintSeen;
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
