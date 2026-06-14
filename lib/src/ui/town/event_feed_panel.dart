import 'package:flutter/material.dart';

import '../../app/town_view_models.dart';
import '../../domain/enums.dart';

class EventFeedPanel extends StatelessWidget {
  const EventFeedPanel({
    required this.title,
    required this.entries,
    required this.emptyMessage,
    this.maxVisibleEntries = 5,
    this.showResourceDeltas = false,
    super.key,
  });

  final String title;
  final List<EventFeedItemViewModel> entries;
  final String emptyMessage;
  final int maxVisibleEntries;

  /// WP-M6-05: when true, each row also shows the Gold/Reputation delta that
  /// the event produced (derived from existing event data).
  final bool showResourceDeltas;

  @override
  Widget build(BuildContext context) {
    final visibleEntries = entries.take(maxVisibleEntries).toList();

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
            const SizedBox(height: 10),
            if (visibleEntries.isEmpty)
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              for (final entry in visibleEntries) ...[
                _EventFeedRow(
                  entry: entry,
                  showResourceDeltas: showResourceDeltas,
                ),
                if (entry != visibleEntries.last) const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _EventFeedRow extends StatelessWidget {
  const _EventFeedRow({
    required this.entry,
    this.showResourceDeltas = false,
  });

  final EventFeedItemViewModel entry;
  final bool showResourceDeltas;

  @override
  Widget build(BuildContext context) {
    final deltaLabel = _deltaLabel(entry);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _iconFor(entry),
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WP-M8-08: mark offline-context rows without enumerating ticks.
              if (entry.isOffline)
                Text(
                  'While away',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              Text(entry.description),
              if (showResourceDeltas && deltaLabel != null)
                Text(
                  deltaLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              Text(
                'Tick ${entry.createdTick}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _deltaLabel(EventFeedItemViewModel entry) {
    final parts = <String>[];
    if (entry.goldDelta != 0) {
      parts.add('${_signed(entry.goldDelta)} Gold');
    }
    // WP-M8-07: Reputation reads as trust / word-of-mouth, never a spendable
    // number. Offline service earns no Reputation, so word only spreads from
    // active, witnessed service.
    if (entry.reputationDelta > 0 && !entry.isOffline) {
      parts.add('word spread');
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String _signed(int value) {
    return value > 0 ? '+$value' : '$value';
  }

  IconData _iconFor(EventFeedItemViewModel entry) {
    switch (entry.eventType) {
      case EventType.demandServed:
        return Icons.check_circle_outline;
      case EventType.demandMissed:
        // WP-M8-05: missed demand is a missed opportunity (an adventurer moved
        // on), not an alarm/error state.
        return Icons.directions_walk;
      case EventType.buildingUpgraded:
        return Icons.arrow_upward;
      case EventType.adventurerArrived:
      case EventType.demandGenerated:
      case EventType.buildingBottleneck:
      case EventType.simulationTick:
        return Icons.info_outline;
    }
  }
}
