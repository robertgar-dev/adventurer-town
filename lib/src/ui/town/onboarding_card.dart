import 'package:flutter/material.dart';

import '../../app/simulation_controller.dart';

/// A piece of one-time onboarding copy.
typedef OnboardingCopy = ({String title, String body});

/// M9 onboarding copy bank. Town-chronicler tone, warm and concise; teaches the
/// existing economy (stewardship, Gold, trust-Reputation, the feed, Capacity vs
/// Value, offline) without implying any excluded or unsupported mechanic.
const Map<OnboardingHint, OnboardingCopy> onboardingHintCopy = {
  OnboardingHint.welcome: (
    title: 'Welcome to your town',
    body: 'Adventurers arrive needing rest, food, gear, healing, and supplies. '
        'Your part is to ready the town so it can help them on their way — and '
        "it keeps serving even while you're away.",
  ),
  OnboardingHint.resources: (
    title: 'Gold and Reputation',
    body: 'Gold is earned when buildings serve adventurers, and it pays for '
        'improvements. Reputation is the trust the town earns through service — '
        'never spent, and it opens the way to greater things.',
  ),
  OnboardingHint.eventFeed: (
    title: "The town's memory",
    body: 'Here the town remembers its day — who it served, who moved on, and '
        "what you improved. A missed visitor's moment has passed; it isn't held "
        'for later.',
  ),
  OnboardingHint.buildingDetail: (
    title: 'Capacity and Value',
    body: 'Capacity lets a building help more adventurers, so fewer are turned '
        'away. Value earns more Gold from each one it already serves.',
  ),
  // Offline copy is surfaced as a line on the existing summary banner, kept
  // here so all onboarding strings share one tone-guarded home.
  OnboardingHint.offline: (
    title: 'While you were away',
    body: 'The town kept serving and earning Gold while you were away. '
        "Reputation grows only while you're watching.",
  ),
};

/// A lightweight, dismissible onboarding card. Non-blocking; the simulation
/// keeps running behind it. Reuses the offline-banner dismissible pattern.
class OnboardingCard extends StatelessWidget {
  const OnboardingCard({
    required this.hint,
    required this.onDismiss,
    super.key,
  });

  final OnboardingHint hint;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final copy = onboardingHintCopy[hint]!;
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      key: Key('onboarding-card-${hint.name}'),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(copy.body),
                ],
              ),
            ),
            IconButton(
              key: Key('onboarding-dismiss-${hint.name}'),
              icon: const Icon(Icons.close),
              tooltip: 'Got it',
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
