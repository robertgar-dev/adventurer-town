import 'package:flutter/material.dart';

import '../../app/town_view_models.dart';

class ResourceHeader extends StatelessWidget {
  const ResourceHeader({
    required this.resources,
    super.key,
  });

  final TownResourcesViewModel resources;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ResourceValue(
                    icon: Icons.payments_outlined,
                    label: 'Gold',
                    value: resources.gold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResourceValue(
                    icon: Icons.verified_outlined,
                    label: 'Reputation',
                    value: resources.reputation,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ReputationDestination(
              destination: resources.reputationDestination,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceValue extends StatelessWidget {
  const _ResourceValue({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value.toString(),
                style: textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// WP-M12-01 (Stage 1): a calm, trust-framed caption showing where Reputation
/// is heading. Icon + text (never color-only), theme-styled so it scales with
/// accessibility text settings. Deliberately not a progress/fill bar so it can
/// never read as a spendable wallet or XP meter.
class _ReputationDestination extends StatelessWidget {
  const _ReputationDestination({
    required this.destination,
  });

  final ReputationDestination destination;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      key: const Key('reputation-destination'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          destination.isAtHighestStanding
              ? Icons.workspace_premium_outlined
              : Icons.trending_up,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            destination.trajectoryText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
