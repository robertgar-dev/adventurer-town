import 'package:flutter/material.dart';

import '../../app/town_view_models.dart';
import '../../domain/enums.dart';

class EventFeedPanel extends StatelessWidget {
  const EventFeedPanel({
    required this.title,
    required this.entries,
    required this.emptyMessage,
    this.maxVisibleEntries = 5,
    super.key,
  });

  final String title;
  final List<EventFeedItemViewModel> entries;
  final String emptyMessage;
  final int maxVisibleEntries;

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
                _EventFeedRow(entry: entry),
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
  });

  final EventFeedItemViewModel entry;

  @override
  Widget build(BuildContext context) {
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
              Text(entry.description),
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

  IconData _iconFor(EventFeedItemViewModel entry) {
    switch (entry.eventType) {
      case EventType.demandServed:
        return Icons.check_circle_outline;
      case EventType.demandMissed:
        return Icons.error_outline;
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
