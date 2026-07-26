import 'dart:math' as math;

import 'package:actly/core/utils/date_utils.dart';
import 'package:actly/data/models/enums.dart';
import 'package:actly/data/models/models.dart';

class ReportResult {
  const ReportResult({
    required this.planned,
    required this.completed,
    required this.rescued,
    required this.skipped,
    required this.effectiveCompletionRate,
  });

  final int planned;
  final int completed;
  final int rescued;
  final int skipped;
  final double effectiveCompletionRate;
}

class WeeklySuggestion {
  const WeeklySuggestion({required this.text, required this.action});

  final String text;
  final RecommendationAction action;
}

class WeeklyReport {
  const WeeklyReport({
    required this.result,
    required this.insights,
    required this.suggestion,
    required this.hasEnoughData,
  });

  final ReportResult result;
  final List<String> insights;
  final WeeklySuggestion suggestion;
  final bool hasEnoughData;
}

class PatternAnalysisService {
  const PatternAnalysisService();

  WeeklyReport buildWeeklyReport({
    required List<DailyEntryModel> allRealEntries,
    required DateTime now,
  }) {
    final weekStart = startOfIsoWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekly = allRealEntries
        .where(
          (entry) =>
              !startOfDay(entry.date).isBefore(weekStart) &&
              !startOfDay(entry.date).isAfter(weekEnd),
        )
        .toList(growable: false);

    final completed = weekly
        .where(
          (entry) =>
              entry.actionTaken == ActionTaken.full && entry.completedAt != null,
        )
        .length;
    final rescued = weekly
        .where(
          (entry) =>
              entry.actionTaken == ActionTaken.backup && entry.completedAt != null,
        )
        .length;
    final skipped = weekly
        .where((entry) => entry.actionTaken == ActionTaken.skip)
        .length;
    final planned = weekly.length;
    final effective = planned == 0 ? 0.0 : (completed + rescued) / planned;

    final result = ReportResult(
      planned: planned,
      completed: completed,
      rescued: rescued,
      skipped: skipped,
      effectiveCompletionRate: effective,
    );

    final today = startOfDay(now);
    final observations = allRealEntries.where((entry) {
      final isPastDay = startOfDay(entry.date).isBefore(today);
      final isResolvedToday = entry.actionTaken == ActionTaken.skip ||
          entry.isEffectiveCompletion;
      return isPastDay || isResolvedToday;
    }).toList(growable: false);

    if (observations.length < 3) {
      return WeeklyReport(
        result: result,
        insights: const <String>[],
        suggestion: const WeeklySuggestion(
          text:
              'Keep recording what happens. Three real observations are needed before Actly describes a pattern.',
          action: RecommendationAction.none,
        ),
        hasEnoughData: false,
      );
    }

    final insights = <String>[];
    final bestTrigger = _bestTrigger(observations);
    if (bestTrigger != null) insights.add(bestTrigger.message);

    final obstacle = _mostCommonSkipReason(observations);
    if (obstacle != null && insights.length < 3) {
      insights.add(obstacle.message);
    }

    final rescue = _backupRescueRate(observations);
    if (rescue != null && insights.length < 3) insights.add(rescue);

    final calibration = _confidenceCalibration(observations);
    if (calibration != null && insights.length < 3) {
      insights.add(calibration);
    }

    final allWeekSkipped = weekly.isNotEmpty && skipped == weekly.length;
    final suggestion = _suggestion(
      allWeekSkipped: allWeekSkipped,
      obstacle: obstacle,
      bestTrigger: bestTrigger,
      effectiveRate: effective,
    );

    return WeeklyReport(
      result: result,
      insights: insights.take(3).toList(growable: false),
      suggestion: suggestion,
      hasEnoughData: true,
    );
  }

  _TriggerInsight? _bestTrigger(List<DailyEntryModel> entries) {
    final groups = <String, List<DailyEntryModel>>{};
    for (final entry in entries) {
      groups.putIfAbsent(entry.triggerIdSnapshot, () => []).add(entry);
    }

    final eligible = groups.entries
        .where((group) => group.value.length >= 3)
        .map((group) {
          final success = group.value
              .where((entry) => entry.isEffectiveCompletion)
              .length;
          return _TriggerPerformance(
            label: group.value.first.triggerLabelSnapshot,
            rate: success / group.value.length,
          );
        })
        .toList();

    if (eligible.length < 2) return null;
    eligible.sort((a, b) => b.rate.compareTo(a.rate));
    final best = eligible.first;
    final second = eligible[1];
    if (best.rate - second.rate < 0.10) return null;

    return _TriggerInsight(
      triggerLabel: best.label,
      message:
          '“${best.label}” has worked more reliably than your other tested triggers.',
    );
  }

  _ObstacleInsight? _mostCommonSkipReason(List<DailyEntryModel> entries) {
    final skipped = entries
        .where(
          (entry) =>
              entry.actionTaken == ActionTaken.skip &&
              entry.skipReason != null,
        )
        .toList(growable: false);
    if (skipped.length < 3) return null;

    final counts = <SkipReason, int>{};
    for (final entry in skipped) {
      final reason = entry.skipReason!;
      counts[reason] = (counts[reason] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final tiedForTop = sorted.length > 1 && sorted[1].value == top.value;
    if (top.value < 2 || tiedForTop) return null;
    return _ObstacleInsight(
      reason: top.key,
      message:
          'The most repeated obstacle has been “${top.key.label.toLowerCase()}” (${top.value} times).',
    );
  }

  String? _backupRescueRate(List<DailyEntryModel> entries) {
    final rescued = entries
        .where(
          (entry) =>
              entry.actionTaken == ActionTaken.backup && entry.completedAt != null,
        )
        .length;
    final backupAttempts = entries
        .where((entry) => entry.actionTaken == ActionTaken.backup)
        .length;
    final skipped = entries
        .where((entry) => entry.actionTaken == ActionTaken.skip)
        .length;
    final difficultDays = backupAttempts + skipped;
    if (difficultDays < 3) return null;

    final percentage = ((rescued / difficultDays) * 100).round();
    if (rescued == 0) {
      return 'The backup plan has not rescued a difficult day yet.';
    }
    return 'The backup plan rescued $percentage% of recorded difficult days.';
  }

  String? _confidenceCalibration(List<DailyEntryModel> entries) {
    final high = entries
        .where((entry) => entry.confidenceSnapshot >= 7)
        .toList(growable: false);
    final low = entries
        .where((entry) => entry.confidenceSnapshot < 7)
        .toList(growable: false);
    if (high.length < 3 || low.length < 3) return null;

    final highRate =
        high.where((entry) => entry.isEffectiveCompletion).length / high.length;
    final lowRate =
        low.where((entry) => entry.isEffectiveCompletion).length / low.length;
    final difference = (highRate - lowRate).abs();
    if (difference < 0.10) {
      return 'Your confidence score has not separated easier and harder plans clearly yet.';
    }
    if (highRate > lowRate) {
      return 'Plans rated 7 or higher have matched your real completion more closely.';
    }
    return 'High confidence has not guaranteed completion; timing may matter more than plan size.';
  }

  WeeklySuggestion _suggestion({
    required bool allWeekSkipped,
    required _ObstacleInsight? obstacle,
    required _TriggerInsight? bestTrigger,
    required double effectiveRate,
  }) {
    if (allWeekSkipped) {
      return const WeeklySuggestion(
        text:
            'This trigger or goal probably does not fit your real week. Try a smaller action attached to a different moment.',
        action: RecommendationAction.shrinkPlan,
      );
    }

    if (obstacle?.reason == SkipReason.lowEnergy ||
        obstacle?.reason == SkipReason.planTooBig) {
      return const WeeklySuggestion(
        text:
            'Make the backup action require less energy than the current version.',
        action: RecommendationAction.editBackup,
      );
    }

    if (obstacle?.reason == SkipReason.forgot) {
      return const WeeklySuggestion(
        text:
            'Move the plan to a recurring moment that is harder to miss.',
        action: RecommendationAction.editTrigger,
      );
    }

    if (bestTrigger != null) {
      return WeeklySuggestion(
        text:
            'Keep “${bestTrigger.triggerLabel}” as the default trigger next week.',
        action: RecommendationAction.editTrigger,
      );
    }

    if (effectiveRate < 0.50) {
      return const WeeklySuggestion(
        text:
            'Reduce the first step next week. Keep the direction, lower the activation cost.',
        action: RecommendationAction.shrinkPlan,
      );
    }

    return const WeeklySuggestion(
      text: 'Keep the current plan unchanged for another week.',
      action: RecommendationAction.none,
    );
  }
}

class _TriggerPerformance {
  const _TriggerPerformance({
    required this.label,
    required this.rate,
  });

  final String label;
  final double rate;
}

class _TriggerInsight {
  const _TriggerInsight({
    required this.triggerLabel,
    required this.message,
  });

  final String triggerLabel;
  final String message;
}

class _ObstacleInsight {
  const _ObstacleInsight({
    required this.reason,
    required this.message,
  });

  final SkipReason reason;
  final String message;
}

int percentage(double value) =>
    (math.max(0, math.min(1, value)) * 100).round();
