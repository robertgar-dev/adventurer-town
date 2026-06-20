import 'package:flutter/material.dart';

import '../../app/town_view_models.dart';

/// WP-M12-03 (Stage 1): a small, presentation-only panel that surfaces the
/// town's notable moments (current standing, every service open, the building
/// that carried the day). Every row is derived at render time from existing
/// state — no simulation event, no [EventType], nothing emitted by the engine.
/// Rendered above the Event Feed; it never displaces or trims the feed itself.
class NotableMomentsPanel extends StatelessWidget {
  const NotableMomentsPanel({
    required this.moments,
    this.maxVisible = 3,
    super.key,
  });

  final List<NotableMomentViewModel> moments;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final visible = moments.take(maxVisible).toList();
    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      key: const Key('notable-moments-panel'),
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
              'Notable moments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            for (final moment in visible) ...[
              _NotableMomentRow(moment: moment),
              if (moment != visible.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotableMomentRow extends StatelessWidget {
  const _NotableMomentRow({
    required this.moment,
  });

  final NotableMomentViewModel moment;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: Key('notable-moment-${moment.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon + text (never color-only) so meaning survives without color.
        Icon(
          Icons.auto_awesome_outlined,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(moment.description)),
      ],
    );
  }
}
