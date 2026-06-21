import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_providers.dart';
import '../../app/simulation_controller.dart';
import '../../app/town_view_models.dart';
import '../../domain/domain.dart';
import '../spatial/spatial_building_detail_screen.dart';
import '../town/event_feed_panel.dart';
import '../town/onboarding_card.dart';

class BuildingDetailScreen extends ConsumerWidget {
  const BuildingDetailScreen({
    required this.buildingId,
    required this.building,
    super.key,
  });

  final String buildingId;
  final Building building;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallbackBuilding = building.copyWith(id: buildingId);
    final detail = ref.watch(buildingDetailProvider(building.buildingType)) ??
        buildingDetailViewModelFor(
          building: fallbackBuilding,
          resources: Resources.initial(),
        );
    final recentActivity =
        ref.watch(buildingRecentActivityProvider(detail.buildingType));
    final showCapacityValueHint = ref.watch(
      simulationControllerProvider.select(
        (state) => state.simulationState?.settings.buildingDetailHintSeen ==
            false,
      ),
    );
    // WP-M12-04 (Stage 1): the first upgrade has not happened yet. Drives the
    // stewardship "stakes" framing and the stronger first-time affirmation.
    // Reads the existing persisted flag — no schema change.
    final firstUpgradePending = ref.watch(
      simulationControllerProvider.select(
        (state) =>
            state.simulationState?.settings.firstUpgradePurchased == false,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.name),
        actions: [
          IconButton(
            key: const Key('open-cutaway'),
            icon: const Icon(Icons.view_in_ar_outlined),
            tooltip: 'Open cutaway',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    SpatialBuildingDetailScreen(building: building),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (showCapacityValueHint) ...[
              OnboardingCard(
                hint: OnboardingHint.buildingDetail,
                onDismiss: () => ref
                    .read(simulationControllerProvider.notifier)
                    .markOnboardingHintSeen(OnboardingHint.buildingDetail),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              detail.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              detail.purposeDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            _PressureCallout(
              summary: detail.pressureSummary,
              highlighted:
                  detail.isUnderPressure || detail.isPrimaryBottleneck,
              isPrimaryBottleneck: detail.isPrimaryBottleneck,
            ),
            const SizedBox(height: 12),
            _DetailSection(
              title: 'Building Summary',
              children: [
                _DetailRow(label: 'Building ID', value: detail.buildingId),
                _DetailRow(
                  label: 'Demand Type',
                  value: detail.demandName,
                ),
                _DetailRow(
                  label: 'Capacity Level',
                  value: detail.capacityLevel.toString(),
                ),
                _DetailRow(
                  label: 'Value Level',
                  value: detail.valueLevel.toString(),
                ),
                _DetailRow(
                  label: 'Current Utilization',
                  value:
                      '${detail.utilizationLabel} (${detail.utilizationPercent}%)',
                ),
                _DetailRow(
                  label: 'Recent Lost Demand',
                  value: detail.recentLostDemand.toString(),
                ),
                _DetailRow(
                  label: 'Constructed State',
                  value:
                      detail.isConstructed ? 'Constructed' : 'Not constructed',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailSection(
              title: 'Recent Performance',
              children: [
                _DetailRow(
                  label: 'Capacity per tick',
                  value: '${detail.capacityPerTick} / tick',
                ),
                _DetailRow(
                  label: 'Recent received / served / lost',
                  value: '${detail.recentDemandReceived} / '
                      '${detail.recentDemandServed} / '
                      '${detail.recentLostDemand}',
                ),
                _DetailRow(
                  label: 'Recent Gold earned',
                  value: '${detail.recentGoldEarned} Gold',
                ),
                _DetailRow(
                  label: 'Lifetime served / lost',
                  value: '${detail.lifetimeDemandServed} / '
                      '${detail.lifetimeDemandLost}',
                ),
                _DetailRow(
                  label: 'Lifetime Gold earned',
                  value: '${detail.lifetimeGoldEarned} Gold',
                ),
              ],
            ),
            const SizedBox(height: 12),
            EventFeedPanel(
              title: 'Recent Activity',
              entries: recentActivity,
              emptyMessage: 'No recent activity.',
              showResourceDeltas: true,
            ),
            const SizedBox(height: 12),
            _DetailSection(
              title: 'Upgrade Section',
              children: [
                // WP-M12-04: light stewardship framing before the first upgrade.
                if (firstUpgradePending) ...[
                  const _FirstUpgradeStakesNote(),
                  const SizedBox(height: 12),
                ],
                _UpgradePanel(
                  action: detail.capacityUpgrade,
                  onPressed: detail.capacityUpgrade.canPurchase
                      ? () async {
                          await _upgradeAndAffirm(
                            context,
                            ref,
                            buildingType: detail.buildingType,
                            axis: UpgradeAxis.capacity,
                            wasFirstUpgrade: firstUpgradePending,
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 12),
                _UpgradePanel(
                  action: detail.valueUpgrade,
                  onPressed: detail.valueUpgrade.canPurchase
                      ? () async {
                          await _upgradeAndAffirm(
                            context,
                            ref,
                            buildingType: detail.buildingType,
                            axis: UpgradeAxis.value,
                            wasFirstUpgrade: firstUpgradePending,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PressureCallout extends StatelessWidget {
  const _PressureCallout({
    required this.summary,
    required this.highlighted,
    required this.isPrimaryBottleneck,
  });

  final String summary;
  final bool highlighted;
  final bool isPrimaryBottleneck;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = highlighted ? colorScheme.error : colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              highlighted
                  ? Icons.warning_amber_outlined
                  : Icons.check_circle_outline,
              size: 18,
              color: accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPrimaryBottleneck ? 'Primary Bottleneck' : 'Service Pressure',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(summary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradePanel extends StatelessWidget {
  const _UpgradePanel({
    required this.action,
    required this.onPressed,
  });

  final UpgradeActionViewModel action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final axis = action.axis.code;
    return DecoratedBox(
      key: Key('upgrade-panel-$axis'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              action.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(action.currentLevelLabel),
            Text(action.costLabel),
            Text(action.effectLabel),
            Text(action.statusLabel),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: Key('upgrade-button-$axis'),
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_upward),
              label: Text(action.buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// WP-M12-04 (Stage 1): performs the existing upgrade and, on success, shows a
/// brief affirmation. The upgrade itself is unchanged — this only adds a
/// presentation acknowledgement; it does not touch cost, gates, effects, or the
/// atomic purchase logic in [SimulationController.upgradeBuilding].
Future<void> _upgradeAndAffirm(
  BuildContext context,
  WidgetRef ref, {
  required BuildingType buildingType,
  required UpgradeAxis axis,
  required bool wasFirstUpgrade,
}) async {
  // Capture the messenger before the await so context is not used afterwards.
  final messenger = ScaffoldMessenger.of(context);
  final ok = await ref
      .read(simulationControllerProvider.notifier)
      .upgradeBuilding(buildingType, axis);
  if (!ok) {
    return;
  }
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        key: const Key('upgrade-affirmation'),
        content: Text(
          wasFirstUpgrade ? _firstUpgradeAffirmation : _upgradeAffirmation,
        ),
      ),
    );
}

const String _firstUpgradeAffirmation =
    'Your first improvement — the town is more capable now. This is stewardship: '
    'you decide what the town is ready for.';

const String _upgradeAffirmation =
    'Upgrade complete — the town can do a little more for those who pass through.';

/// WP-M12-04 (Stage 1): a calm, one-time stewardship framing shown before the
/// first upgrade. Copy only; it reads as a decision the steward makes, never as
/// a purchase prompt, a wager, or a power boost.
class _FirstUpgradeStakesNote extends StatelessWidget {
  const _FirstUpgradeStakesNote();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      key: const Key('first-upgrade-stakes-note'),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 18,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your first improvement is yours to choose. Capacity helps more '
                'adventurers; Value earns more from each one served. Either way, '
                'you are deciding what this town is ready for.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
