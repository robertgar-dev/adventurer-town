import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_events.dart';
import '../ui/town/town_view.dart';
import 'app_providers.dart';

class AdventurerTownApp extends ConsumerStatefulWidget {
  const AdventurerTownApp({super.key});

  @override
  ConsumerState<AdventurerTownApp> createState() => _AdventurerTownAppState();
}

class _AdventurerTownAppState extends ConsumerState<AdventurerTownApp>
    with WidgetsBindingObserver {
  // M10: start of the current session segment, used for session_duration.
  DateTime? _sessionStartedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStartedAt = DateTime.now();
    Future.microtask(() async {
      final controller = ref.read(simulationControllerProvider.notifier);
      await controller.loadOrCreate();
      controller.startActiveLoop();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);
    switch (lifecycleState) {
      case AppLifecycleState.resumed:
        _sessionStartedAt = DateTime.now();
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _endSession();
      case AppLifecycleState.inactive:
        // Transient; not a session end.
        break;
    }
  }

  /// M10: emits session_ended with session_duration_seconds, once per segment.
  /// Fire-and-forget; analytics never blocks or breaks the lifecycle.
  void _endSession() {
    final start = _sessionStartedAt;
    if (start == null) {
      return;
    }
    _sessionStartedAt = null;
    final seconds = DateTime.now().difference(start).inSeconds;
    final currentTick =
        ref.read(simulationControllerProvider).simulationState?.currentTick ?? 0;
    final analytics = ref.read(analyticsServiceProvider);
    unawaited(
      analytics.logEvent(
        AnalyticsEvents.sessionEnded,
        parameters: {
          AnalyticsProperties.sessionDurationSeconds: seconds < 0 ? 0 : seconds,
          AnalyticsProperties.currentTick: currentTick,
        },
      ).catchError((Object _) {}),
    );
  }

  @override
  void dispose() {
    // session_ended is emitted from lifecycle callbacks (paused/hidden/
    // detached) while `ref` is still valid; on real app close the framework
    // delivers `detached` before teardown. We must not touch `ref` here.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adventurer Town',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF32685A)),
        useMaterial3: true,
      ),
      home: const TownView(),
    );
  }
}
