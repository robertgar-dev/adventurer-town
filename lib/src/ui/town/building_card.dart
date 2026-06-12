import 'package:flutter/material.dart';

import '../../app/town_view_models.dart';
import '../../domain/domain.dart';

class BuildingCard extends StatelessWidget {
  const BuildingCard({
    required this.building,
    required this.onTap,
    super.key,
  });

  final BuildingCardViewModel building;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stateColor =
        _utilizationColor(colorScheme, building.utilizationState);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      building.name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 22),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.room_service_outlined,
                    label: 'Serves ${building.demandName}',
                  ),
                  _InfoChip(
                    icon: Icons.groups_2_outlined,
                    label: 'Capacity Lv ${building.capacityLevel}',
                  ),
                  _InfoChip(
                    icon: Icons.trending_up,
                    label: 'Value Lv ${building.valueLevel}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatusLine(
                      color: stateColor,
                      label: building.utilizationLabel,
                    ),
                  ),
                  Text(
                    building.isConstructed ? 'Constructed' : 'Not constructed',
                    style: textTheme.bodySmall?.copyWith(
                      color: building.isConstructed
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _LostDemandLine(
                count: building.recentLostDemand,
                highlighted: building.hasRecentLostDemand,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _utilizationColor(
    ColorScheme colorScheme,
    UtilizationState utilizationState,
  ) {
    switch (utilizationState) {
      case UtilizationState.underused:
        return colorScheme.outline;
      case UtilizationState.healthy:
        return colorScheme.primary;
      case UtilizationState.busy:
        return colorScheme.tertiary;
      case UtilizationState.overloaded:
        return colorScheme.error;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _LostDemandLine extends StatelessWidget {
  const _LostDemandLine({
    required this.count,
    required this.highlighted,
  });

  final int count;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          highlighted
              ? Icons.warning_amber_outlined
              : Icons.check_circle_outline,
          size: 18,
          color: highlighted ? colorScheme.error : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          'Lost demand $count',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: highlighted
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
