import 'package:actly/data/models/enums.dart';
import 'package:actly/data/models/models.dart';
import 'package:actly/services/reminder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = ReminderEngine();
  final bundle = _bundle();

  test('does not show before approximate trigger time', () {
    final result = engine.evaluate(
      bundle: bundle,
      entry: null,
      now: DateTime(2026, 7, 22, 18),
    );
    expect(result.shouldShow, isFalse);
  });

  test('shows after trigger time when no action exists', () {
    final result = engine.evaluate(
      bundle: bundle,
      entry: null,
      now: DateTime(2026, 7, 22, 18, 31),
    );
    expect(result.shouldShow, isTrue);
  });

  test('uses the daily snapshot time after the live plan changes', () {
    final entry = _entry().copyWith();
    final snapshotEntry = DailyEntryModel(
      id: entry.id,
      date: entry.date,
      actionTaken: entry.actionTaken,
      valueUsedForStreaks: entry.valueUsedForStreaks,
      snoozeCount: entry.snoozeCount,
      goalActionSnapshot: entry.goalActionSnapshot,
      minimumActionSnapshot: entry.minimumActionSnapshot,
      triggerIdSnapshot: entry.triggerIdSnapshot,
      triggerLabelSnapshot: entry.triggerLabelSnapshot,
      triggerTimeSnapshot: '20:00',
      confidenceSnapshot: entry.confidenceSnapshot,
      shrunkChosenSnapshot: entry.shrunkChosenSnapshot,
      source: entry.source,
    );

    final result = engine.evaluate(
      bundle: bundle,
      entry: snapshotEntry,
      now: DateTime(2026, 7, 22, 19),
    );
    expect(result.shouldShow, isFalse);
  });

  test('honors snoozed-until time', () {
    final entry = _entry().copyWith(
      snoozeCount: 1,
      snoozedUntil: DateTime(2026, 7, 22, 19),
    );
    expect(
      engine
          .evaluate(
            bundle: bundle,
            entry: entry,
            now: DateTime(2026, 7, 22, 18, 45),
          )
          .shouldShow,
      isFalse,
    );
    expect(
      engine
          .evaluate(
            bundle: bundle,
            entry: entry,
            now: DateTime(2026, 7, 22, 19),
          )
          .shouldShow,
      isTrue,
    );
  });

  test('does not remind after action is recorded', () {
    final entry = _entry().copyWith(
      actionTaken: ActionTaken.skip,
      completedAt: DateTime(2026, 7, 22, 18, 40),
    );
    final result = engine.evaluate(
      bundle: bundle,
      entry: entry,
      now: DateTime(2026, 7, 22, 19),
    );
    expect(result.shouldShow, isFalse);
  });
}

ActivePlanBundle _bundle() {
  final goal = GoalModel(
    id: 'goal',
    category: GoalCategory.movement,
    originalAction: 'Walk for 20 minutes',
    minimumAction: 'Walk for 5 minutes',
    createdAt: DateTime(2026, 7, 20),
    isActive: true,
  );
  final plan = PlanModel(
    id: 'plan',
    goalId: goal.id,
    triggerId: 'home',
    triggerLabel: 'When I get home',
    approximateTime: '18:30',
    confidence: 8,
    shrunkChosen: false,
    createdAt: DateTime(2026, 7, 20),
    isActive: true,
  );
  return ActivePlanBundle(
    goal: goal,
    diagnosis: const DiagnosisModel(
      id: 'diagnosis',
      goalId: 'goal',
      clearWhenWhere: DiagnosisAnswer.yes,
      timeEnergy: DiagnosisAnswer.somewhat,
      actuallyWant: DiagnosisAnswer.yes,
    ),
    plan: plan,
    backup: const BackupPlanModel(
      id: 'backup',
      planId: 'plan',
      obstacle: ObstacleType.tired,
      fallbackAction: 'Walk indoors for 5 minutes',
    ),
  );
}

DailyEntryModel _entry() => DailyEntryModel(
      id: 'entry',
      date: DateTime(2026, 7, 22),
      actionTaken: ActionTaken.noneYet,
      valueUsedForStreaks: 0,
      snoozeCount: 0,
      goalActionSnapshot: 'Walk for 20 minutes',
      minimumActionSnapshot: 'Walk for 5 minutes',
      triggerIdSnapshot: 'home',
      triggerLabelSnapshot: 'When I get home',
      triggerTimeSnapshot: '18:30',
      confidenceSnapshot: 8,
      shrunkChosenSnapshot: false,
      source: EntrySource.real,
    );
