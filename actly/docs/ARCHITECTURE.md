# Actly Architecture

## Runtime shape

Actly v1 is a fully offline Flutter application with no account, backend, analytics SDK, advertising SDK, remote configuration, or cloud sync.

```text
UI screens
  -> ActlyController (application state and orchestration)
    -> ReminderEngine (deterministic due-time decisions)
    -> PatternAnalysisService (deterministic weekly analysis)
    -> AppRepository
      -> SQLite / sqflite (structured product records)
      -> shared_preferences (small application flags)
```

## Persistence

SQLite tables:

- `goals`
- `diagnoses`
- `plans`
- `backup_plans`
- `daily_entries`
- `weekly_feedback`

Every daily entry stores a snapshot of the active goal action, minimum action, trigger, approximate time, confidence, and selected action size. Historical reports therefore remain stable when a later plan is edited.

Every daily entry is tagged `real` or `simulation`. Weekly analysis queries real entries only. The data-control screen exposes both counts, can delete simulation entries independently, exports the full local dataset as JSON, and can reset the application behind explicit confirmation.

## Reminder engine

V1 has no operating-system notification dependency. The controller checks the plan:

- after local initialization,
- whenever the app returns to foreground,
- every 30 seconds while the app is open.

The reminder decision uses the daily snapshot time when an entry already exists, so a mid-day plan edit does not rewrite the historical plan for that day. Snooze is capped at two attempts.

## Pattern-analysis rules

The service is deterministic and explainable:

- Current unresolved entries do not count as observations.
- No pattern is shown before three real observations.
- Trigger comparison needs two trigger groups with at least three observations each and a success-rate difference of at least ten percentage points.
- Skip-reason analysis needs at least three skipped days.
- Confidence comparison needs at least three observations in both `<7` and `>=7` buckets.
- Backup rescue rate is completed backup days divided by backup-attempt or skipped difficult days.
- The report exposes at most three insights and one concrete recommendation.

## State ownership

`ActlyController` is deliberately the single v1 orchestration boundary. It owns the active bundle, current daily records, reminder visibility, report, feedback, and data counts. This keeps the initial product inspectable. A later multi-goal or sync release can split this into feature stores without changing the database contracts.

## Recovery

Database initialization errors route to an explicit recovery screen. The user can retry without data loss or deliberately delete and rebuild local storage after a second confirmation.
