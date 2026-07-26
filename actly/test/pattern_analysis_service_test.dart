import 'package:actly/data/models/enums.dart';
import 'package:actly/data/models/models.dart';
import 'package:actly/services/pattern_analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = PatternAnalysisService();

  test('does not surface patterns below three real observations', () {
    final report = service.buildWeeklyReport(
      allRealEntries: [
        _entry(day: 1, action: ActionTaken.full, completed: true),
        _entry(day: 2, action: ActionTaken.skip, reason: SkipReason.noTime),
      ],
      now: DateTime(2026, 7, 22),
    );

    expect(report.hasEnoughData, isFalse);
    expect(report.insights, isEmpty);
  });

  test('does not treat an unresolved current-day entry as an observation', () {
    final report = service.buildWeeklyReport(
      allRealEntries: [
        _entry(day: 20, action: ActionTaken.full, completed: true),
        _entry(day: 21, action: ActionTaken.skip, reason: SkipReason.noTime),
        _entry(day: 22, action: ActionTaken.noneYet),
      ],
      now: DateTime(2026, 7, 22, 12),
    );

    expect(report.hasEnoughData, isFalse);
    expect(report.insights, isEmpty);
  });

  test('counts backup completion as rescued and effective', () {
    final report = service.buildWeeklyReport(
      allRealEntries: [
        _entry(day: 20, action: ActionTaken.full, completed: true),
        _entry(day: 21, action: ActionTaken.backup, completed: true),
        _entry(day: 22, action: ActionTaken.skip, reason: SkipReason.noTime),
      ],
      now: DateTime(2026, 7, 22),
    );

    expect(report.result.completed, 1);
    expect(report.result.rescued, 1);
    expect(report.result.skipped, 1);
    expect(report.result.effectiveCompletionRate, closeTo(2 / 3, 0.001));
  });

  test('withholds trigger comparison until two groups have three entries', () {
    final entries = <DailyEntryModel>[
      for (var day = 1; day <= 3; day++)
        _entry(
          day: day,
          action: ActionTaken.full,
          completed: true,
          triggerId: 'a',
          triggerLabel: 'After breakfast',
        ),
      for (var day = 4; day <= 5; day++)
        _entry(
          day: day,
          action: ActionTaken.skip,
          reason: SkipReason.noTime,
          triggerId: 'b',
          triggerLabel: 'After dinner',
        ),
    ];

    final report = service.buildWeeklyReport(
      allRealEntries: entries,
      now: DateTime(2026, 7, 22),
    );

    expect(
      report.insights.any((value) => value.contains('After breakfast')),
      isFalse,
    );
  });

  test('surfaces a meaningful trigger difference after minimum samples', () {
    final entries = <DailyEntryModel>[
      for (var day = 1; day <= 3; day++)
        _entry(
          day: day,
          action: ActionTaken.full,
          completed: true,
          triggerId: 'a',
          triggerLabel: 'After breakfast',
        ),
      for (var day = 4; day <= 6; day++)
        _entry(
          day: day,
          action: ActionTaken.skip,
          reason: SkipReason.noTime,
          triggerId: 'b',
          triggerLabel: 'After dinner',
        ),
    ];

    final report = service.buildWeeklyReport(
      allRealEntries: entries,
      now: DateTime(2026, 7, 22),
    );

    expect(
      report.insights.any((value) => value.contains('After breakfast')),
      isTrue,
    );
  });

  test('does not invent a dominant obstacle when skip reasons are tied', () {
    final report = service.buildWeeklyReport(
      allRealEntries: [
        _entry(day: 18, action: ActionTaken.skip, reason: SkipReason.noTime),
        _entry(day: 19, action: ActionTaken.skip, reason: SkipReason.lowEnergy),
        _entry(day: 20, action: ActionTaken.skip, reason: SkipReason.forgot),
      ],
      now: DateTime(2026, 7, 22),
    );

    expect(
      report.insights.any((value) => value.contains('most repeated obstacle')),
      isFalse,
    );
  });

  test('whole skipped week produces fit suggestion, not judgment', () {
    final entries = [
      _entry(day: 20, action: ActionTaken.skip, reason: SkipReason.noTime),
      _entry(day: 21, action: ActionTaken.skip, reason: SkipReason.lowEnergy),
      _entry(day: 22, action: ActionTaken.skip, reason: SkipReason.planTooBig),
    ];

    final report = service.buildWeeklyReport(
      allRealEntries: entries,
      now: DateTime(2026, 7, 22),
    );

    expect(report.suggestion.text, contains('does not fit your real week'));
    expect(report.suggestion.text.toLowerCase(), isNot(contains('discipline')));
  });
}

DailyEntryModel _entry({
  required int day,
  required ActionTaken action,
  bool completed = false,
  SkipReason? reason,
  String triggerId = 'trigger',
  String triggerLabel = 'When I get home',
  int confidence = 8,
}) {
  return DailyEntryModel(
    id: 'entry_$day-$triggerId',
    date: DateTime(2026, 7, day),
    actionTaken: action,
    valueUsedForStreaks: completed ? 1 : 0,
    snoozeCount: 0,
    skipReason: reason,
    completedAt: completed || action == ActionTaken.skip
        ? DateTime(2026, 7, day, 19)
        : null,
    goalActionSnapshot: 'Walk for 20 minutes',
    minimumActionSnapshot: 'Walk for 5 minutes',
    triggerIdSnapshot: triggerId,
    triggerLabelSnapshot: triggerLabel,
    triggerTimeSnapshot: '18:30',
    confidenceSnapshot: confidence,
    shrunkChosenSnapshot: false,
    source: EntrySource.real,
  );
}
