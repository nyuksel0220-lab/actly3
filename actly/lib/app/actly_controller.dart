import 'dart:async';
import 'dart:convert';

import 'package:actly/core/utils/date_utils.dart';
import 'package:actly/core/utils/id.dart';
import 'package:actly/data/models/enums.dart';
import 'package:actly/data/models/models.dart';
import 'package:actly/data/repositories/app_repository.dart';
import 'package:actly/services/pattern_analysis_service.dart';
import 'package:actly/services/reminder_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanDraft {
  const PlanDraft({
    required this.category,
    required this.originalAction,
    required this.minimumAction,
    required this.clearWhenWhere,
    required this.timeEnergy,
    required this.actuallyWant,
    required this.confidence,
    required this.shrunkChosen,
    required this.triggerId,
    required this.triggerLabel,
    required this.approximateTime,
    required this.obstacle,
    required this.fallbackAction,
  });

  final GoalCategory category;
  final String originalAction;
  final String minimumAction;
  final DiagnosisAnswer clearWhenWhere;
  final DiagnosisAnswer timeEnergy;
  final DiagnosisAnswer actuallyWant;
  final int confidence;
  final bool shrunkChosen;
  final String triggerId;
  final String triggerLabel;
  final String approximateTime;
  final ObstacleType obstacle;
  final String fallbackAction;
}

class ActlyController extends ChangeNotifier {
  ActlyController({
    AppRepository? repository,
    PatternAnalysisService? patternService,
    ReminderEngine? reminderEngine,
  })  : _repository = repository ?? AppRepository(),
        _patternService = patternService ?? const PatternAnalysisService(),
        _reminderEngine = reminderEngine ?? const ReminderEngine();

  static const _onboardingKey = 'onboarding_complete';
  static const _subscriptionKey = 'subscription_status';

  final AppRepository _repository;
  final PatternAnalysisService _patternService;
  final ReminderEngine _reminderEngine;

  bool initialized = false;
  Object? fatalError;
  bool onboardingComplete = false;
  String subscriptionStatus = 'free';
  ActivePlanBundle? bundle;
  DailyEntryModel? todayReal;
  DailyEntryModel? todaySimulation;
  EntrySource? reminderSource;
  bool reminderVisible = false;
  String? systemNote;
  WeeklyReport report = const WeeklyReport(
    result: ReportResult(
      planned: 0,
      completed: 0,
      rescued: 0,
      skipped: 0,
      effectiveCompletionRate: 0,
    ),
    insights: <String>[],
    suggestion: WeeklySuggestion(
      text: 'Record three real observations before Actly describes a pattern.',
      action: RecommendationAction.none,
    ),
    hasEnoughData: false,
  );
  WeeklyFeedbackModel? currentWeekFeedback;
  DataCounts counts = const DataCounts(real: 0, simulation: 0);

  Timer? _timer;

  DailyEntryModel? get activeReminderEntry => switch (reminderSource) {
        EntrySource.real => todayReal,
        EntrySource.simulation => todaySimulation,
        null => null,
      };

  DailyEntryModel? get activeActionEntry {
    final real = todayReal;
    if (real != null &&
        (real.actionTaken == ActionTaken.full ||
            real.actionTaken == ActionTaken.backup) &&
        real.completedAt == null) {
      return real;
    }
    final simulation = todaySimulation;
    if (simulation != null &&
        (simulation.actionTaken == ActionTaken.full ||
            simulation.actionTaken == ActionTaken.backup) &&
        simulation.completedAt == null) {
      return simulation;
    }
    return null;
  }

  Future<void> initialize() async {
    _timer?.cancel();
    fatalError = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      onboardingComplete = prefs.getBool(_onboardingKey) ?? false;
      subscriptionStatus = prefs.getString(_subscriptionKey) ?? 'free';
      await prefs.setString(_subscriptionKey, subscriptionStatus);

      bundle = await _repository.loadActiveBundle();
      await _refreshData(checkReminder: false);
      initialized = true;
      notifyListeners();
      await checkReminder();

      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        checkReminder();
      });
    } catch (error) {
      fatalError = error;
      initialized = true;
      notifyListeners();
    }
  }

  Future<void> retryInitialization() async {
    initialized = false;
    notifyListeners();
    await initialize();
  }

  Future<void> rebuildLocalStorage() async {
    initialized = false;
    fatalError = null;
    notifyListeners();
    try {
      await _repository.rebuildDatabase();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
      await prefs.setString(_subscriptionKey, 'free');
      onboardingComplete = false;
      subscriptionStatus = 'free';
      bundle = null;
      todayReal = null;
      todaySimulation = null;
      reminderVisible = false;
      reminderSource = null;
      await initialize();
    } catch (error) {
      fatalError = error;
      initialized = true;
      notifyListeners();
    }
  }

  Future<void> onAppResumed() async {
    await _refreshData(checkReminder: true);
  }

  Future<void> completeOnboarding() async {
    onboardingComplete = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> savePlan(PlanDraft draft) async {
    final now = DateTime.now();
    final goalId = newId('goal');
    final planId = newId('plan');
    final newBundle = ActivePlanBundle(
      goal: GoalModel(
        id: goalId,
        category: draft.category,
        originalAction: draft.originalAction.trim(),
        minimumAction: draft.minimumAction.trim(),
        createdAt: now,
        isActive: true,
      ),
      diagnosis: DiagnosisModel(
        id: newId('diagnosis'),
        goalId: goalId,
        clearWhenWhere: draft.clearWhenWhere,
        timeEnergy: draft.timeEnergy,
        actuallyWant: draft.actuallyWant,
      ),
      plan: PlanModel(
        id: planId,
        goalId: goalId,
        triggerId: draft.triggerId,
        triggerLabel: draft.triggerLabel,
        approximateTime: draft.approximateTime,
        confidence: draft.confidence,
        shrunkChosen: draft.shrunkChosen,
        createdAt: now,
        isActive: true,
      ),
      backup: BackupPlanModel(
        id: newId('backup'),
        planId: planId,
        obstacle: draft.obstacle,
        fallbackAction: draft.fallbackAction.trim(),
      ),
    );
    await _repository.saveNewBundle(newBundle);
    bundle = newBundle;
    todayReal = null;
    todaySimulation = null;
    reminderVisible = false;
    reminderSource = null;
    await _refreshData(checkReminder: true);
  }

  Future<void> updateBackup({
    required ObstacleType obstacle,
    required String fallbackAction,
  }) async {
    final current = bundle;
    if (current == null) return;
    final updated = BackupPlanModel(
      id: current.backup.id,
      planId: current.backup.planId,
      obstacle: obstacle,
      fallbackAction: fallbackAction.trim(),
    );
    await _repository.updateBackupPlan(updated);
    bundle = ActivePlanBundle(
      goal: current.goal,
      diagnosis: current.diagnosis,
      plan: current.plan,
      backup: updated,
    );
    notifyListeners();
  }

  Future<void> updateTrigger({
    required String triggerId,
    required String triggerLabel,
    required String approximateTime,
  }) async {
    final current = bundle;
    if (current == null) return;
    final old = current.plan;
    final updated = PlanModel(
      id: old.id,
      goalId: old.goalId,
      triggerId: triggerId,
      triggerLabel: triggerLabel,
      approximateTime: approximateTime,
      confidence: old.confidence,
      shrunkChosen: old.shrunkChosen,
      createdAt: old.createdAt,
      isActive: old.isActive,
    );
    await _repository.updatePlan(updated);
    bundle = ActivePlanBundle(
      goal: current.goal,
      diagnosis: current.diagnosis,
      plan: updated,
      backup: current.backup,
    );
    notifyListeners();
    await checkReminder();
  }

  Future<void> chooseSmallerPlan(bool useSmaller) async {
    final current = bundle;
    if (current == null) return;
    final old = current.plan;
    final updated = PlanModel(
      id: old.id,
      goalId: old.goalId,
      triggerId: old.triggerId,
      triggerLabel: old.triggerLabel,
      approximateTime: old.approximateTime,
      confidence: old.confidence,
      shrunkChosen: useSmaller,
      createdAt: old.createdAt,
      isActive: old.isActive,
    );
    await _repository.updatePlan(updated);
    bundle = ActivePlanBundle(
      goal: current.goal,
      diagnosis: current.diagnosis,
      plan: updated,
      backup: current.backup,
    );
    notifyListeners();
  }

  Future<void> checkReminder({DateTime? now}) async {
    final current = bundle;
    if (current == null || !initialized) return;
    final instant = now ?? DateTime.now();
    todayReal ??=
        await _repository.getEntryForDate(instant, EntrySource.real);
    final decision = _reminderEngine.evaluate(
      bundle: current,
      entry: todayReal,
      now: instant,
    );

    if (!decision.shouldShow) {
      if (reminderSource == EntrySource.real) {
        reminderVisible = false;
        reminderSource = null;
        notifyListeners();
      }
      return;
    }

    var entry = todayReal ?? _newEntry(EntrySource.real, instant);
    if (entry.notificationShownAt == null) {
      entry = entry.copyWith(notificationShownAt: instant);
      await _repository.upsertDailyEntry(entry);
      todayReal = entry;
      await _refreshReportAndCounts();
    }
    reminderSource = EntrySource.real;
    reminderVisible = true;
    notifyListeners();
  }

  Future<void> showTestReminder() async {
    final current = bundle;
    if (current == null) return;
    final now = DateTime.now();
    var entry = _newEntry(EntrySource.simulation, now);
    entry = entry.copyWith(notificationShownAt: now);
    await _repository.upsertDailyEntry(entry);
    todaySimulation = entry;
    reminderSource = EntrySource.simulation;
    reminderVisible = true;
    systemNote = 'Simulation mode. This record is excluded from real reports.';
    await _refreshReportAndCounts();
    notifyListeners();
  }

  Future<void> startAction(ActionTaken action) async {
    if (action != ActionTaken.full && action != ActionTaken.backup) return;
    final source = reminderSource;
    if (source == null) return;
    final now = DateTime.now();
    var entry = source == EntrySource.real ? todayReal : todaySimulation;
    entry ??= _newEntry(source, now);
    entry = entry.copyWith(
      actionTaken: action,
      startedAt: now,
      clearSnoozedUntil: true,
    );
    await _repository.upsertDailyEntry(entry);
    _setEntry(entry);
    reminderVisible = false;
    reminderSource = null;
    systemNote = action == ActionTaken.backup
        ? 'Backup route started. A rescue counts as completion.'
        : 'Plan started.';
    await _refreshReportAndCounts();
    notifyListeners();
  }

  Future<void> completeStartedAction(DailyEntryModel entry) async {
    final completed = entry.copyWith(
      completedAt: DateTime.now(),
      valueUsedForStreaks: 1,
    );
    await _repository.upsertDailyEntry(completed);
    _setEntry(completed);
    systemNote = completed.actionTaken == ActionTaken.backup
        ? 'Backup plan worked. The day was rescued.'
        : 'Plan worked. Same setup tomorrow?';
    await _refreshReportAndCounts();
    notifyListeners();
  }

  Future<bool> snooze(Duration duration) async {
    final source = reminderSource;
    if (source == null) return false;
    final now = DateTime.now();
    var entry = source == EntrySource.real ? todayReal : todaySimulation;
    entry ??= _newEntry(source, now);
    if (entry.snoozeCount >= 2) return false;

    entry = entry.copyWith(
      snoozeCount: entry.snoozeCount + 1,
      snoozedUntil: now.add(duration),
    );
    await _repository.upsertDailyEntry(entry);
    _setEntry(entry);
    reminderVisible = false;
    reminderSource = null;
    systemNote =
        'Reminder moved to ${formatClock(entry.snoozedUntil!)}. Snooze ${entry.snoozeCount} of 2.';
    await _refreshReportAndCounts();
    notifyListeners();
    return true;
  }

  Future<void> skipToday(SkipReason reason) async {
    final source = reminderSource;
    if (source == null) return;
    final now = DateTime.now();
    var entry = source == EntrySource.real ? todayReal : todaySimulation;
    entry ??= _newEntry(source, now);
    entry = entry.copyWith(
      actionTaken: ActionTaken.skip,
      skipReason: reason,
      completedAt: now,
      valueUsedForStreaks: 0,
      clearSnoozedUntil: true,
    );
    await _repository.upsertDailyEntry(entry);
    _setEntry(entry);
    reminderVisible = false;
    reminderSource = null;
    systemNote = reason.response;
    await _refreshReportAndCounts();
    notifyListeners();
  }

  Future<void> saveWeeklyFeedback(FeedbackRating rating) async {
    final feedback = WeeklyFeedbackModel(
      id: newId('feedback'),
      isoWeek: isoWeekKey(DateTime.now()),
      rating: rating,
      createdAt: DateTime.now(),
    );
    await _repository.saveWeeklyFeedback(feedback);
    currentWeekFeedback = feedback;
    notifyListeners();
  }

  Future<String> exportData() async {
    final databaseJson = await _repository.exportAllData();
    final payload = jsonDecode(databaseJson) as Map<String, dynamic>;
    payload['settings'] = <String, Object?>{
      'onboardingComplete': onboardingComplete,
      'subscriptionStatus': subscriptionStatus,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> clearSimulationData() async {
    await _repository.clearSimulationData();
    todaySimulation = null;
    if (reminderSource == EntrySource.simulation) {
      reminderVisible = false;
      reminderSource = null;
    }
    systemNote = 'Simulation records cleared.';
    await _refreshReportAndCounts();
    notifyListeners();
  }

  Future<void> resetEverything() async {
    await _repository.resetEverything();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.setString(_subscriptionKey, 'free');
    onboardingComplete = false;
    subscriptionStatus = 'free';
    bundle = null;
    todayReal = null;
    todaySimulation = null;
    reminderVisible = false;
    reminderSource = null;
    systemNote = null;
    currentWeekFeedback = null;
    report = const WeeklyReport(
      result: ReportResult(
        planned: 0,
        completed: 0,
        rescued: 0,
        skipped: 0,
        effectiveCompletionRate: 0,
      ),
      insights: <String>[],
      suggestion: WeeklySuggestion(
        text: 'Record three real observations before Actly describes a pattern.',
        action: RecommendationAction.none,
      ),
      hasEnoughData: false,
    );
    counts = const DataCounts(real: 0, simulation: 0);
    notifyListeners();
  }

  void clearSystemNote() {
    systemNote = null;
    notifyListeners();
  }

  DailyEntryModel _newEntry(EntrySource source, DateTime now) {
    final current = bundle!;
    return DailyEntryModel(
      id: newId('entry'),
      date: startOfDay(now),
      actionTaken: ActionTaken.noneYet,
      valueUsedForStreaks: 0,
      snoozeCount: 0,
      source: source,
      goalActionSnapshot: current.goal.originalAction,
      minimumActionSnapshot: current.goal.minimumAction,
      triggerIdSnapshot: current.plan.triggerId,
      triggerLabelSnapshot: current.plan.triggerLabel,
      triggerTimeSnapshot: current.plan.approximateTime,
      confidenceSnapshot: current.plan.confidence,
      shrunkChosenSnapshot: current.plan.shrunkChosen,
    );
  }

  void _setEntry(DailyEntryModel entry) {
    if (entry.source == EntrySource.real) {
      todayReal = entry;
    } else {
      todaySimulation = entry;
    }
  }

  Future<void> _refreshData({required bool checkReminder}) async {
    bundle = await _repository.loadActiveBundle();
    final now = DateTime.now();
    todayReal = await _repository.getEntryForDate(now, EntrySource.real);
    if (bundle != null && todayReal == null) {
      todayReal = _newEntry(EntrySource.real, now);
      await _repository.upsertDailyEntry(todayReal!);
    }
    todaySimulation =
        await _repository.getEntryForDate(now, EntrySource.simulation);
    await _refreshReportAndCounts();
    if (checkReminder) await this.checkReminder(now: now);
    notifyListeners();
  }

  Future<void> _refreshReportAndCounts() async {
    final allReal = await _repository.getEntries(source: EntrySource.real);
    report = _patternService.buildWeeklyReport(
      allRealEntries: allReal,
      now: DateTime.now(),
    );
    counts = await _repository.getDataCounts();
    currentWeekFeedback =
        await _repository.getWeeklyFeedback(isoWeekKey(DateTime.now()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
