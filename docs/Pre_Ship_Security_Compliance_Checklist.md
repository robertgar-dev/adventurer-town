# Pre-Ship Security & Compliance Checklist

A pre-ship security + compliance pass that runs **locally with trusted tooling
only**. Run it before any store submission.

> **Do NOT use external web "ship-score" scanners.** Never upload this repo to a
> third-party site. A ship score is **triage, not a green light** — static
> checks miss logic, auth, and access-control bugs (IDOR, inverted auth,
> server-side gaps). Run the checks below on your own machine.

---

## This repo's scoped reality

Establish what is actually wired up before hunting for exposure:

- **Local-only.** All user data lives on-device in Isar
  (`IsarSimulationRepository`, see `lib/src/app/app_providers.dart`). No remote
  data store, no network egress in app code.
- **Analytics is off.** The active provider is
  `SafeAnalyticsService(NoopAnalyticsService())` and the app never calls
  `Firebase.initializeApp()` (see `lib/main.dart` and
  `docs/M5_Launch_Notes.md`). Firebase is analytics-only and currently a no-op.
- **No backend service uses rules.** There is no Firestore / Storage / Realtime
  Database / Auth, and no `firestore.rules` / `storage.rules` /
  `database.rules.json`. **There is no Firestore-rules problem to hunt** — do
  not invent one.

If any of the above changes (e.g. analytics is enabled, or a backend is added),
re-scope this checklist accordingly.

---

## Local checks (run before ship)

### Secrets — source and git history
- Prefer `gitleaks detect` or `trufflehog git file://.` if installed.
- Else grep source **and** history for key/token patterns
  (`api[_-]?key`, `secret`, `password`, `private key`, `service_account`,
  `client_secret`, `BEGIN ... PRIVATE KEY`).
- Real secrets = service-account JSON, server/admin keys, third-party API keys.
  A Firebase client identifier in `firebase_options.dart` /
  `google-services.json` is a **public client ID, not a secret** — do not flag
  it. (Neither file exists today; Firebase is unconfigured.)

### Dependencies
- Run `flutter pub outdated`; review anything with known advisories before ship.

### .gitignore hygiene (only if Firebase is ever configured)
- Confirm `.gitignore` covers `google-services.json`, `GoogleService-Info.plist`
  / other `*.plist` carrying config, and keystores (`*.keystore`, `*.jks`,
  `key.properties`). These do not exist yet — add the ignores when/if they do.

---

## M11/M12 pre-submission compliance gate

Today's build collects nothing and exposes nothing. The compliance risk lands
the moment analytics is enabled or M11/M12 adds IAP/ads. Before submitting:

- [ ] **Privacy policy** published and linked.
- [ ] **Analytics auto-collection** reviewed and disclosed. Enabling
      `FirebaseAnalyticsService` causes Firebase to auto-collect device /
      app-instance identifiers by default — disclose this and consider disabling
      advertising-ID collection.
- [ ] **COPPA decision** made. An idle town-builder attracts minors; decide the
      target-age posture and, if mixed-audience, gate analytics/ads for under-13.
- [ ] **Play Data Safety form** re-derived to match what is actually collected.
- [ ] **Apple privacy labels** re-derived to match what is actually collected.
