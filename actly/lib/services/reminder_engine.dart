import 'package:actly/core/utils/date_utils.dart';
import 'package:actly/data/models/enums.dart';
import 'package:actly/data/models/models.dart';

class ReminderDecision {
  const ReminderDecision({
    required this.shouldShow,
    this.scheduledAt,
  });

  final bool shouldShow;
  final DateTime? scheduledAt;
}

class ReminderEngine {
  const ReminderEngine();

  ReminderDecision evaluate({
    required ActivePlanBundle bundle,
    required DailyEntryModel? entry,
    required DateTime now,
  }) {
    if (entry?.actionTaken != null &&
        entry!.actionTaken != ActionTaken.noneYet) {
      return const ReminderDecision(shouldShow: false);
    }

    final snoozedUntil = entry?.snoozedUntil;
    if (snoozedUntil != null) {
      return ReminderDecision(
        shouldShow: !now.isBefore(snoozedUntil),
        scheduledAt: snoozedUntil,
      );
    }

    final triggerTime = entry?.triggerTimeSnapshot ?? bundle.plan.approximateTime;
    final scheduled = timeOnDate(now, triggerTime);
    return ReminderDecision(
      shouldShow: !now.isBefore(scheduled),
      scheduledAt: scheduled,
    );
  }
}
