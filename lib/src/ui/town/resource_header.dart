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
        child: Row(
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
