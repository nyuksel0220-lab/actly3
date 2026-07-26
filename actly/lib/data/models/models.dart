import 'package:actly/data/models/enums.dart';

class GoalModel {
  const GoalModel({
    required this.id,
    required this.category,
    required this.originalAction,
    required this.minimumAction,
    required this.createdAt,
    required this.isActive,
  });

  final String id;
  final GoalCategory category;
  final String originalAction;
  final String minimumAction;
  final DateTime createdAt;
  final bool isActive;

  Map<String, Object?> toMap() => {
        'id': id,
        'category': category.name,
        'original_action': originalAction,
        'minimum_action': minimumAction,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive ? 1 : 0,
      };

  factory GoalModel.fromMap(Map<String, Object?> map) => GoalModel(
        id: map['id']! as String,
        category: GoalCategory.values.byName(map['category']! as String),
        originalAction: map['original_action']! as String,
        minimumAction: map['minimum_action']! as String,
        createdAt: DateTime.parse(map['created_at']! as String),
        isActive: (map['is_active']! as int) == 1,
      );
}

class DiagnosisModel {
  const DiagnosisModel({
    required this.id,
    required this.goalId,
    required this.clearWhenWhere,
    required this.timeEnergy,
    required this.actuallyWant,
  });

  final String id;
  final String goalId;
  final DiagnosisAnswer clearWhenWhere;
  final DiagnosisAnswer timeEnergy;
  final DiagnosisAnswer actuallyWant;

  Map<String, Object?> toMap() => {
        'id': id,
        'goal_id': goalId,
        'clear_when_where': clearWhenWhere.name,
        'time_energy': timeEnergy.name,
        'actually_want': actuallyWant.name,
      };

  factory DiagnosisModel.fromMap(Map<String, Object?> map) => DiagnosisModel(
        id: map['id']! as String,
        goalId: map['goal_id']! as String,
        clearWhenWhere:
            DiagnosisAnswer.values.byName(map['clear_when_where']! as String),
        timeEnergy:
            DiagnosisAnswer.values.byName(map['time_energy']! as String),
        actuallyWant:
            DiagnosisAnswer.values.byName(map['actually_want']! as String),
      );
}

class PlanModel {
  const PlanModel({
    required this.id,
    required this.goalId,
    required this.triggerId,
    required this.triggerLabel,
    required this.approximateTime,
    required this.confidence,
    required this.shrunkChosen,
    required this.createdAt,
    required this.isActive,
  });

  final String id;
  final String goalId;
  final String triggerId;
  final String triggerLabel;
  final String approximateTime;
  final int confidence;
  final bool shrunkChosen;
  final DateTime createdAt;
  final bool isActive;

  Map<String, Object?> toMap() => {
        'id': id,
        'goal_id': goalId,
        'trigger_id': triggerId,
        'trigger_label': triggerLabel,
        'approximate_time': approximateTime,
        'confidence': confidence,
        'shrunk_chosen': shrunkChosen ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive ? 1 : 0,
      };

  factory PlanModel.fromMap(Map<String, Object?> map) => PlanModel(
        id: map['id']! as String,
        goalId: map['goal_id']! as String,
        triggerId: map['trigger_id']! as String,
        triggerLabel: map['trigger_label']! as String,
        approximateTime: map['approximate_time']! as String,
        confidence: map['confidence']! as int,
        shrunkChosen: (map['shrunk_chosen']! as int) == 1,
        createdAt: DateTime.parse(map['created_at']! as String),
        isActive: (map['is_active']! as int) == 1,
      );
}

class BackupPlanModel {
  const BackupPlanModel({
    required this.id,
    required this.planId,
    required this.obstacle,
    required this.fallbackAction,
  });

  final String id;
  final String planId;
  final ObstacleType obstacle;
  final String fallbackAction;

  Map<String, Object?> toMap() => {
        'id': id,
        'plan_id': planId,
        'obstacle_id': obstacle.name,
        'obstacle_label': obstacle.label,
        'fallback_action': fallbackAction,
      };

  factory BackupPlanModel.fromMap(Map<String, Object?> map) => BackupPlanModel(
        id: map['id']! as String,
        planId: map['plan_id']! as String,
        obstacle: ObstacleType.values.byName(map['obstacle_id']! as String),
        fallbackAction: map['fallback_action']! as String,
      );
}

class DailyEntryModel {
  const DailyEntryModel({
    required this.id,
    required this.date,
    required this.actionTaken,
    required this.valueUsedForStreaks,
    required this.snoozeCount,
    required this.source,
    required this.goalActionSnapshot,
    required this.minimumActionSnapshot,
    required this.triggerIdSnapshot,
    required this.triggerLabelSnapshot,
    required this.triggerTimeSnapshot,
    required this.confidenceSnapshot,
    required this.shrunkChosenSnapshot,
    this.snoozedUntil,
    this.skipReason,
    this.notificationShownAt,
    this.startedAt,
    this.completedAt,
  });

  final String id;
  final DateTime date;
  final ActionTaken actionTaken;
  final int valueUsedForStreaks;
  final int snoozeCount;
  final DateTime? snoozedUntil;
  final SkipReason? skipReason;
  final DateTime? notificationShownAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String goalActionSnapshot;
  final String minimumActionSnapshot;
  final String triggerIdSnapshot;
  final String triggerLabelSnapshot;
  final String triggerTimeSnapshot;
  final int confidenceSnapshot;
  final bool shrunkChosenSnapshot;
  final EntrySource source;

  bool get isEffectiveCompletion =>
      completedAt != null &&
      (actionTaken == ActionTaken.full || actionTaken == ActionTaken.backup);

  DailyEntryModel copyWith({
    ActionTaken? actionTaken,
    int? valueUsedForStreaks,
    int? snoozeCount,
    DateTime? snoozedUntil,
    bool clearSnoozedUntil = false,
    SkipReason? skipReason,
    bool clearSkipReason = false,
    DateTime? notificationShownAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return DailyEntryModel(
      id: id,
      date: date,
      actionTaken: actionTaken ?? this.actionTaken,
      valueUsedForStreaks:
          valueUsedForStreaks ?? this.valueUsedForStreaks,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      snoozedUntil:
          clearSnoozedUntil ? null : snoozedUntil ?? this.snoozedUntil,
      skipReason: clearSkipReason ? null : skipReason ?? this.skipReason,
      notificationShownAt:
          notificationShownAt ?? this.notificationShownAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      goalActionSnapshot: goalActionSnapshot,
      minimumActionSnapshot: minimumActionSnapshot,
      triggerIdSnapshot: triggerIdSnapshot,
      triggerLabelSnapshot: triggerLabelSnapshot,
      triggerTimeSnapshot: triggerTimeSnapshot,
      confidenceSnapshot: confidenceSnapshot,
      shrunkChosenSnapshot: shrunkChosenSnapshot,
      source: source,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'entry_date': dateOnly(date),
        'action_taken': actionTaken.name,
        'streak_value': valueUsedForStreaks,
        'snooze_count': snoozeCount,
        'snoozed_until': snoozedUntil?.toIso8601String(),
        'skip_reason': skipReason?.name,
        'notification_shown_at': notificationShownAt?.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'goal_action_snapshot': goalActionSnapshot,
        'minimum_action_snapshot': minimumActionSnapshot,
        'trigger_id_snapshot': triggerIdSnapshot,
        'trigger_label_snapshot': triggerLabelSnapshot,
        'trigger_time_snapshot': triggerTimeSnapshot,
        'confidence_snapshot': confidenceSnapshot,
        'shrunk_chosen_snapshot': shrunkChosenSnapshot ? 1 : 0,
        'source': source.name,
      };

  factory DailyEntryModel.fromMap(Map<String, Object?> map) => DailyEntryModel(
        id: map['id']! as String,
        date: DateTime.parse(map['entry_date']! as String),
        actionTaken:
            ActionTaken.values.byName(map['action_taken']! as String),
        valueUsedForStreaks: map['streak_value']! as int,
        snoozeCount: map['snooze_count']! as int,
        snoozedUntil: parseNullableDate(map['snoozed_until']),
        skipReason: map['skip_reason'] == null
            ? null
            : SkipReason.values.byName(map['skip_reason']! as String),
        notificationShownAt:
            parseNullableDate(map['notification_shown_at']),
        startedAt: parseNullableDate(map['started_at']),
        completedAt: parseNullableDate(map['completed_at']),
        goalActionSnapshot: map['goal_action_snapshot']! as String,
        minimumActionSnapshot: map['minimum_action_snapshot']! as String,
        triggerIdSnapshot: map['trigger_id_snapshot']! as String,
        triggerLabelSnapshot: map['trigger_label_snapshot']! as String,
        triggerTimeSnapshot: map['trigger_time_snapshot']! as String,
        confidenceSnapshot: map['confidence_snapshot']! as int,
        shrunkChosenSnapshot:
            (map['shrunk_chosen_snapshot']! as int) == 1,
        source: EntrySource.values.byName(map['source']! as String),
      );
}

class WeeklyFeedbackModel {
  const WeeklyFeedbackModel({
    required this.id,
    required this.isoWeek,
    required this.rating,
    required this.createdAt,
  });

  final String id;
  final String isoWeek;
  final FeedbackRating rating;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'iso_week': isoWeek,
        'rating': rating.name,
        'created_at': createdAt.toIso8601String(),
      };

  factory WeeklyFeedbackModel.fromMap(Map<String, Object?> map) =>
      WeeklyFeedbackModel(
        id: map['id']! as String,
        isoWeek: map['iso_week']! as String,
        rating: FeedbackRating.values.byName(map['rating']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
      );
}

class ActivePlanBundle {
  const ActivePlanBundle({
    required this.goal,
    required this.diagnosis,
    required this.plan,
    required this.backup,
  });

  final GoalModel goal;
  final DiagnosisModel diagnosis;
  final PlanModel plan;
  final BackupPlanModel backup;

  String get selectedAction =>
      plan.shrunkChosen ? goal.minimumAction : goal.originalAction;
}

DateTime? parseNullableDate(Object? value) {
  if (value == null) return null;
  return DateTime.parse(value as String);
}

String dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
