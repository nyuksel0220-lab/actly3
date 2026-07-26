import 'package:actly/app/app_scope.dart';
import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/core/design/actly_typography.dart';
import 'package:actly/data/models/enums.dart';
import 'package:actly/data/models/models.dart';
import 'package:actly/services/pattern_analysis_service.dart';
import 'package:actly/widgets/if_then_diagram.dart';
import 'package:actly/widgets/radial_gauge.dart';
import 'package:actly/widgets/technical_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onOpenPlan, super.key});

  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final bundle = controller.bundle!;
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    final realEntry = controller.todayReal;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        _Header(bundle: bundle),
        const SizedBox(height: 18),
        IfThenDiagram(
          trigger: bundle.plan.triggerLabel,
          action: bundle.selectedAction,
        ),
        const SizedBox(height: 14),
        _BackupStrip(bundle: bundle),
        if (controller.systemNote != null) ...[
          const SizedBox(height: 14),
          _SystemNote(
            text: controller.systemNote!,
            onDismiss: controller.clearSystemNote,
          ),
        ],
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: reducedMotion
              ? Duration.zero
              : const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: controller.reminderVisible
              ? _ReminderCard(
                  key: ValueKey(
                    'reminder-${controller.reminderSource?.name}',
                  ),
                  source: controller.reminderSource!,
                  bundle: bundle,
                  entry: controller.activeReminderEntry,
                )
              : controller.activeActionEntry != null
                  ? _ActiveActionCard(
                      key: ValueKey(
                        'active-${controller.activeActionEntry!.id}',
                      ),
                      entry: controller.activeActionEntry!,
                      bundle: bundle,
                    )
                  : _DayStatusCard(
                      key: const ValueKey('day-status'),
                      entry: realEntry,
                      bundle: bundle,
                    ),
        ),
        const SizedBox(height: 18),
        _WeekSnapshot(report: controller.report),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: controller.reminderVisible
              ? null
              : controller.showTestReminder,
          icon: const Icon(Icons.science_outlined),
          label: const Text('Preview/test this reminder now'),
        ),
        const SizedBox(height: 8),
        Text(
          'Test interactions are labeled simulation and excluded from real weekly reports.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 18),
        TextButton.icon(
          onPressed: onOpenPlan,
          icon: const Icon(Icons.tune),
          label: const Text('Inspect or edit the plan'),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.bundle});

  final ActivePlanBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY // ACTIVE PLAN',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: ActlyColors.signalCyan,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                bundle.goal.category.label,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Approx. ${bundle.plan.approximateTime}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: ActlyColors.mutedSteel),
              ),
            ],
          ),
        ),
        RadialGauge(
          value: bundle.plan.confidence,
          size: 86,
          animate: false,
        ),
      ],
    );
  }
}

class _BackupStrip extends StatelessWidget {
  const _BackupStrip({required this.bundle});

  final ActivePlanBundle bundle;

  @override
  Widget build(BuildContext context) {
    return TechnicalCard(
      borderColor: ActlyColors.rescueAmber,
      backgroundColor: ActlyColors.rescueAmber.withValues(alpha: 0.07),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.alt_route, color: ActlyColors.rescueAmber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BACKUP ROUTE',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: ActlyColors.rescueAmber,
                      ),
                ),
                const SizedBox(height: 6),
                Text(bundle.backup.fallbackAction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemNote extends StatelessWidget {
  const _SystemNote({required this.text, required this.onDismiss});

  final String text;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return TechnicalCard(
      borderColor: ActlyColors.signalCyan,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: ActlyColors.signalCyan),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          IconButton(
            tooltip: 'Dismiss note',
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.source,
    required this.bundle,
    required this.entry,
    super.key,
  });

  final EntrySource source;
  final ActivePlanBundle bundle;
  final DailyEntryModel? entry;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.read(context);
    final snoozes = entry?.snoozeCount ?? 0;
    return TechnicalCard(
      padding: EdgeInsets.zero,
      borderColor: source == EntrySource.simulation
          ? ActlyColors.rescueAmber
          : ActlyColors.signalCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            color: source == EntrySource.simulation
                ? ActlyColors.rescueAmber.withValues(alpha: 0.12)
                : ActlyColors.signalCyan.withValues(alpha: 0.10),
            child: Row(
              children: [
                Text(
                  source == EntrySource.simulation
                      ? 'REMINDER // SIMULATION'
                      : 'REMINDER // DUE NOW',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: source == EntrySource.simulation
                            ? ActlyColors.rescueAmber
                            : ActlyColors.signalCyan,
                      ),
                ),
                const Spacer(),
                Text(
                  'SNOOZE $snoozes/2',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IfThenDiagram(
                  trigger: entry?.triggerLabelSnapshot ?? bundle.plan.triggerLabel,
                  action: entry == null
                      ? bundle.selectedAction
                      : entry!.shrunkChosenSnapshot
                          ? entry!.minimumActionSnapshot
                          : entry!.goalActionSnapshot,
                  compact: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => controller.startAction(ActionTaken.full),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start now'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ActlyColors.rescueAmber,
                    side: const BorderSide(color: ActlyColors.rescueAmber),
                  ),
                  onPressed: () => controller.startAction(ActionTaken.backup),
                  icon: const Icon(Icons.alt_route),
                  label: const Text('Use backup plan'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showSnooze(context, snoozes),
                        child: const Text('Remind me later'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _showSkipReasons(context),
                        child: const Text('Skip today'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSnooze(BuildContext context, int count) async {
    final controller = AppScope.read(context);
    if (count >= 2) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => _SheetFrame(
          title: 'Snooze limit reached',
          body:
              'A third delay would turn the reminder into avoidance. Use the backup route or record a skip.',
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ActlyColors.rescueAmber,
              ),
              onPressed: () {
                Navigator.pop(sheetContext);
                controller.startAction(ActionTaken.backup);
              },
              child: const Text('Use backup plan'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                _showSkipReasons(context);
              },
              child: const Text('Record a skip'),
            ),
          ],
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _SheetFrame(
        title: 'Choose a delay',
        body: 'Snoozing is capped at two attempts.',
        children: [
          for (final minutes in const [10, 30, 60]) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await controller.snooze(Duration(minutes: minutes));
                },
                child: Text('$minutes minutes'),
              ),
            ),
            if (minutes != 60) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Future<void> _showSkipReasons(BuildContext context) async {
    final controller = AppScope.read(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _SheetFrame(
        title: 'Why did today not fit?',
        body: 'The answer adjusts the system note. It does not grade you.',
        children: [
          for (final reason in SkipReason.values) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await controller.skipToday(reason);
                },
                child: Text(reason.label),
              ),
            ),
            if (reason != SkipReason.values.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ActiveActionCard extends StatelessWidget {
  const _ActiveActionCard({
    required this.entry,
    required this.bundle,
    super.key,
  });

  final DailyEntryModel entry;
  final ActivePlanBundle bundle;

  @override
  Widget build(BuildContext context) {
    final isBackup = entry.actionTaken == ActionTaken.backup;
    final action = isBackup
        ? bundle.backup.fallbackAction
        : entry.shrunkChosenSnapshot
            ? entry.minimumActionSnapshot
            : entry.goalActionSnapshot;
    final accent = isBackup ? ActlyColors.rescueAmber : ActlyColors.signalCyan;
    return TechnicalCard(
      borderColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(isBackup ? 'Backup route running' : 'Plan running'),
          const SizedBox(height: 12),
          Text(action, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            isBackup
                ? 'This is a rescue, not a lesser result.'
                : 'Started. Mark it complete when the action is finished.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: ActlyColors.mutedSteel),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accent),
            onPressed: () =>
                AppScope.read(context).completeStartedAction(entry),
            child: Text(isBackup ? 'Mark backup complete' : 'Mark plan complete'),
          ),
        ],
      ),
    );
  }
}

class _DayStatusCard extends StatelessWidget {
  const _DayStatusCard({required this.entry, required this.bundle, super.key});

  final DailyEntryModel? entry;
  final ActivePlanBundle bundle;

  @override
  Widget build(BuildContext context) {
    if (entry == null || entry!.actionTaken == ActionTaken.noneYet) {
      return TechnicalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Waiting for trigger'),
            const SizedBox(height: 12),
            Text(
              'Actly will surface the plan around ${bundle.plan.approximateTime} while the app is open.',
            ),
            const SizedBox(height: 6),
            Text(
              'The recurring moment matters more than the exact minute.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    final isBackup = entry!.actionTaken == ActionTaken.backup;
    final isSkip = entry!.actionTaken == ActionTaken.skip;
    final accent = isSkip
        ? ActlyColors.mutedSteel
        : isBackup
            ? ActlyColors.rescueAmber
            : ActlyColors.signalCyan;
    return TechnicalCard(
      borderColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            isSkip
                ? 'Day recorded'
                : isBackup
                    ? 'Day rescued'
                    : 'Plan completed',
          ),
          const SizedBox(height: 12),
          Text(
            isSkip
                ? 'Skipped: ${entry!.skipReason?.label ?? 'reason not recorded'}.'
                : isBackup
                    ? 'Backup plan worked. It counts in effective completion.'
                    : 'Plan worked. Same setup tomorrow?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _WeekSnapshot extends StatelessWidget {
  const _WeekSnapshot({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final result = report.result;
    return TechnicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('This week'),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric(label: 'FULL', value: result.completed.toString()),
              _Metric(
                label: 'RESCUED',
                value: result.rescued.toString(),
                color: ActlyColors.rescueAmber,
              ),
              _Metric(label: 'SKIPPED', value: result.skipped.toString()),
              _Metric(
                label: 'EFFECTIVE',
                value: '${percentage(result.effectiveCompletionRate)}%',
                color: ActlyColors.signalCyan,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.color = ActlyColors.paperBlue,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: ActlyTypography.data(size: 21, color: color)),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 36,
              height: 3,
              margin: const EdgeInsets.only(bottom: 20),
              alignment: Alignment.center,
              color: ActlyColors.divider,
            ),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              body,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: ActlyColors.mutedSteel),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
