import 'package:flutter/material.dart';

/// WP-M7-06: a minimal, dismissible offline return summary. Intentionally
/// simple (a banner, not polished UX). Takes primitive fields so it carries no
/// simulation dependency.
class OfflineSummaryBanner extends StatelessWidget {
  const OfflineSummaryBanner({
    required this.elapsedSeconds,
    required this.goldEarned,
    required this.demandServed,
    required this.demandMissed,
    required this.onDismiss,
    super.key,
  });

  final int elapsedSeconds;
  final int goldEarned;
  final int demandServed;
  final int demandMissed;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      key: const Key('offline-summary-banner'),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.nightlight_round,
              size: 20,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'While you were away',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text('Away ${_formatElapsed(elapsedSeconds)}'),
                  Text('+$goldEarned Gold'),
                  Text('$demandServed served, $demandMissed missed'),
                ],
              ),
            ),
            IconButton(
              key: const Key('offline-summary-dismiss'),
              icon: const Icon(Icons.close),
              tooltip: 'Dismiss',
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }

  String _formatElapsed(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m';
    }
    return '${seconds}s';
  }
}
