# Actly

Actly is an offline-first Flutter application for behavior design. It turns an intention into a concrete **IF → THEN** plan, prepares a valid backup route, records what happened, and derives deterministic weekly patterns without diagnosing, treating, or assessing any medical or mental-health condition.

## Product loop

```text
Choose one goal
  -> 60-second diagnosis
  -> confidence gauge and explicit action-size choice
  -> IF trigger -> THEN action
  -> obstacle-specific backup route
  -> in-app reminder
  -> full / backup / skip record
  -> deterministic weekly report
```

There is no account, backend, advertising, premium UI, trial, or remote dependency in v1.

## Design system

- **Ink Navy** `#071827` — app background
- **Blueprint Blue** `#0D3150` — signature diagram surfaces
- **Signal Cyan** `#38BDF8` — active controls and full-plan success
- **Rescue Amber** `#F2B84B` — backup route and rescue success
- **Paper Blue** `#EAF3F8` — primary text
- **Muted Steel** `#89A3B5` — secondary text
- **Fault Red** `#D45B62` — destructive actions only

The signature component is a reusable technical IF → THEN wiring diagram. Numerical data uses tabular monospace styling. The UI avoids wellness gradients, glass effects, oversized pill controls, and guilt-based streak language. See [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md).

## Run locally

This source package intentionally excludes generated Android and iOS host folders. On a machine with the current stable Flutter SDK:

```bash
./tool/bootstrap.sh
flutter run
```

Equivalent manual commands:

```bash
flutter create --platforms=android,ios --org com.actly.app --project-name actly .
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

The `flutter create` command generates native host projects while retaining this package's `lib/`, `test/`, documentation, and dependency definition.

## Persistence and privacy

- Structured product records: SQLite through `sqflite`
- Small first-launch/future-state flags: `shared_preferences`
- Data export: a real JSON file through the native share/save sheet
- No account, analytics SDK, backend, ads, or cloud synchronization
- Every daily record is tagged `real` or `simulation`
- Weekly analysis excludes simulation records by default
- Simulation-only deletion and full reset are available in the app

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Reminder behavior

V1 uses an in-app reminder engine, not operating-system push notifications. It checks:

- after application initialization,
- when the application returns to foreground,
- every 30 seconds while open.

Snooze is capped at two attempts. The third attempt redirects to the backup route or a recorded skip.

## Verification

```bash
python3 tool/verify_brief.py
flutter analyze
flutter test
```

The source-level verification script checks required product copy, SQLite contracts, simulation separation, data controls, and the absence of monetization copy. Flutter analysis and tests remain the authoritative build checks.

The included tests cover reminder timing/snapshot behavior and conservative pattern-analysis thresholds. CI configuration is provided in [`.github/workflows/flutter_ci.yml`](.github/workflows/flutter_ci.yml).

## Release work

Store signing, native host metadata, production icons, launch screens, privacy/support URLs, store screenshots, and closed-beta device testing still belong to the release pipeline. See [`docs/SHIP_CHECKLIST.md`](docs/SHIP_CHECKLIST.md).
