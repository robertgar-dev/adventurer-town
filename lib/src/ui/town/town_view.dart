import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_providers.dart';
import '../../app/town_view_models.dart';
import '../building_detail/building_detail_screen.dart';
import 'building_card.dart';
import 'event_feed_panel.dart';
import 'offline_summary_banner.dart';
import 'resource_header.dart';

class TownView extends ConsumerWidget {
  const TownView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(simulationControllerProvider);
    final resources = ref.watch(townResourcesProvider);
    final buildings = ref.watch(townBuildingCardsProvider);
    final eventFeed = ref.watch(townEventFeedProvider);

    if (controllerState.isLoading && resources == null) {
      return const _TownScaffold(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (resources == null) {
      return _TownScaffold(
        child: _FallbackPanel(
          message: controllerState.errorMessage ?? 'Town state unavailable.',
        ),
      );
    }

    if (buildings.isEmpty) {
      return const _TownScaffold(
        child: _FallbackPanel(message: 'No buildings available.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adventurer Town'),
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('town-view-list'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (controllerState.offlineSummary case final summary?) ...[
              OfflineSummaryBanner(
                elapsedSeconds: summary.elapsedSeconds,
                goldEarned: summary.goldEarned,
                demandServed: summary.demandServed,
                demandMissed: summary.demandMissed,
                onDismiss: () => ref
                    .read(simulationControllerProvider.notifier)
                    .dismissOfflineSummary(),
              ),
              const SizedBox(height: 16),
            ],
            ResourceHeader(resources: resources),
            if (controllerState.errorMessage != null) ...[
              const SizedBox(height: 12),
              _FallbackPanel(message: controllerState.errorMessage!),
            ],
            const SizedBox(height: 16),
            EventFeedPanel(
              title: 'Event Feed',
              entries: eventFeed,
              emptyMessage: 'No recent events.',
            ),
            const SizedBox(height: 16),
            for (final building in buildings) ...[
              BuildingCard(
                building: building,
                onTap: () => _handleBuildingTap(context, building),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  void _handleBuildingTap(
    BuildContext context,
    BuildingCardViewModel building,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BuildingDetailScreen(
          buildingId: building.buildingId,
          building: building.building,
        ),
      ),
    );
  }
}

class _TownScaffold extends StatelessWidget {
  const _TownScaffold({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adventurer Town'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class _FallbackPanel extends StatelessWidget {
  const _FallbackPanel({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
