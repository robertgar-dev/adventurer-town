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
    this.onboardingNote,
    this.storyLines = const [],
    super.key,
  });

  final int elapsedSeconds;
  final int goldEarned;
  final int demandServed;
  final int demandMissed;
  final VoidCallback onDismiss;

  /// WP-M12-02 (Stage 1): an optional, presentation-only narration of the away
  /// window (e.g. the busiest building, the most-missed demand), derived from
  /// existing offline-flagged feed entries. Shown above the honest scalars,
  /// which always remain. Gold-only; never implies Reputation, a backlog,
  /// recoverable demand, or payment.
  final List<String> storyLines;

  /// M9: an optional one-time framing line shown on the first offline return
  /// (e.g. "Reputation grows only while you're watching").
  final String? onboardingNote;

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
                  // WP-M12-02: narrated beat first (the story of the away
                  // window), then the honest scalars below — both always shown.
                  if (storyLines.isNotEmpty) ...[
                    for (final (index, line) in storyLines.indexed)
                      Padding(
                        key: Key('offline-summary-story-line-$index'),
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(line),
                      ),
                    const SizedBox(height: 6),
                  ],
                  Text('Away ${_formatElapsed(elapsedSeconds)}'),
                  Text('+$goldEarned Gold'),
                  Text('$demandServed served, $demandMissed missed'),
                  if (onboardingNote case final note?) ...[
                    const SizedBox(height: 6),
                    Text(
                      note,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                    ),
                  ],
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
