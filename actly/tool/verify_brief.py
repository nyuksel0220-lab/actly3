#!/usr/bin/env python3
"""Fast source-level contract check. Flutter analyze/test remain authoritative."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
TEXT = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted((ROOT / "lib").rglob("*.dart"))
)

required = {
    "onboarding principle 1": "Don't try to get more motivated",
    "onboarding principle 2": "Actly finds the real obstacle",
    "onboarding principle 3": "A small plan isn't failure",
    "signature diagram": "class IfThenDiagram",
    "four reminder actions": "Start now",
    "backup route action": "Use backup plan",
    "snooze action": "Remind me later",
    "skip action": "Skip today",
    "simulation tag": "EntrySource.simulation",
    "JSON export": "Export my data",
    "simulation deletion": "Clear only my test/demo data",
    "full reset": "Delete everything and reset the app",
    "weekly feedback": "Was this week's suggestion actually useful?",
    "local storage recovery": "Retry local storage",
}

errors = []
for label, token in required.items():
    if token not in TEXT:
        errors.append(f"missing {label}: {token!r}")

schema = (ROOT / "lib/data/db/app_database.dart").read_text(encoding="utf-8")
for table in [
    "goals",
    "diagnoses",
    "plans",
    "backup_plans",
    "daily_entries",
    "weekly_feedback",
]:
    if f"CREATE TABLE {table}" not in schema:
        errors.append(f"missing SQLite table: {table}")

ui_text = "\n".join(
    path.read_text(encoding="utf-8")
    for area in ["features", "widgets"]
    for path in sorted((ROOT / "lib" / area).rglob("*.dart"))
)
for forbidden in ["paywall", "upgrade to", "free trial", "per month", "premium plan"]:
    if forbidden in ui_text.lower():
        errors.append(f"monetization copy found in v1 UI: {forbidden!r}")

if errors:
    print("Actly brief verification failed:")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("Actly source-level brief verification passed.")
