import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/town/town_view.dart';
import 'app_providers.dart';

class AdventurerTownApp extends ConsumerStatefulWidget {
  const AdventurerTownApp({super.key});

  @override
  ConsumerState<AdventurerTownApp> createState() => _AdventurerTownAppState();
}

class _AdventurerTownAppState extends ConsumerState<AdventurerTownApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = ref.read(simulationControllerProvider.notifier);
      await controller.loadOrCreate();
      controller.startActiveLoop();
    });
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
