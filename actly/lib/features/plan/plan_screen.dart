import 'package:actly/app/app_scope.dart';
import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/data/models/enums.dart';
import 'package:actly/widgets/choice_tile.dart';
import 'package:actly/widgets/if_then_diagram.dart';
import 'package:actly/widgets/radial_gauge.dart';
import 'package:actly/widgets/technical_card.dart';
import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({
    required this.requestSerial,
    required this.onRequestHandled,
    super.key,
    this.requestedAction,
  });

  final RecommendationAction? requestedAction;
  final int requestSerial;
  final VoidCallback onRequestHandled;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  @override
  void didUpdateWidget(covariant PlanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.requestedAction != null &&
        widget.requestSerial != oldWidget.requestSerial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openRequestedEditor(widget.requestedAction!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final bundle = controller.bundle!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'PLAN // CONTROL PANEL',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ActlyColors.signalCyan,
              ),
        ),
        const SizedBox(height: 8),
        Text('Inspect the system.',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Changes apply from the next new daily entry. Existing history keeps its original snapshot.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: ActlyColors.mutedSteel),
        ),
        const SizedBox(height: 20),
        IfThenDiagram(
          trigger: bundle.plan.triggerLabel,
          action: bundle.selectedAction,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _editTrigger(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit trigger'),
          ),
        ),
        const SizedBox(height: 12),
        TechnicalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Action size'),
              const SizedBox(height: 14),
              ChoiceTile(
                label: 'Original plan',
                description: bundle.goal.originalAction,
                selected: !bundle.plan.shrunkChosen,
                onTap: () => controller.chooseSmallerPlan(false),
              ),
              const SizedBox(height: 10),
              ChoiceTile(
                label: 'Smaller plan',
                description: bundle.goal.minimumAction,
                selected: bundle.plan.shrunkChosen,
                accent: ActlyColors.rescueAmber,
                onTap: () => controller.chooseSmallerPlan(true),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  RadialGauge(
                    value: bundle.plan.confidence,
                    size: 88,
                    animate: false,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'The confidence score is historical context. Changing action size remains explicit.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TechnicalCard(
          borderColor: ActlyColors.rescueAmber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Backup route'),
              const SizedBox(height: 12),
              Text(
                bundle.backup.obstacle.label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: ActlyColors.mutedSteel),
              ),
              const SizedBox(height: 7),
              Text(
                bundle.backup.fallbackAction,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ActlyColors.rescueAmber,
                    ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: ActlyColors.rescueAmber,
                  side: const BorderSide(color: ActlyColors.rescueAmber),
                ),
                onPressed: () => _editBackup(context),
                icon: const Icon(Icons.alt_route),
                label: const Text('Edit backup plan'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TechnicalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Diagnosis snapshot'),
              const SizedBox(height: 14),
              _DiagnosticRow(
                label: 'Clear when and where',
                value: bundle.diagnosis.clearWhenWhere.label,
              ),
              _DiagnosticRow(
                label: 'Time and energy fit',
                value: bundle.diagnosis.timeEnergy.label,
              ),
              _DiagnosticRow(
                label: 'Actually wanted',
                value: bundle.diagnosis.actuallyWant.label,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openRequestedEditor(RecommendationAction action) async {
    widget.onRequestHandled();
    switch (action) {
      case RecommendationAction.editBackup:
        await _editBackup(context);
        return;
      case RecommendationAction.editTrigger:
        await _editTrigger(context);
        return;
      case RecommendationAction.shrinkPlan:
        await _reviewActionSize(context);
        return;
      case RecommendationAction.none:
        return;
    }
  }

  Future<void> _reviewActionSize(BuildContext context) async {
    final controller = AppScope.read(context);
    final current = controller.bundle!;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Review action size',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the version that fits the next real week. Actly will not change it silently.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ActlyColors.mutedSteel,
                    ),
              ),
              const SizedBox(height: 18),
              ChoiceTile(
                label: 'Use original plan',
                description: current.goal.originalAction,
                selected: !current.plan.shrunkChosen,
                onTap: () async {
                  await controller.chooseSmallerPlan(false);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 10),
              ChoiceTile(
                label: 'Use smaller plan',
                description: current.goal.minimumAction,
                selected: current.plan.shrunkChosen,
                accent: ActlyColors.rescueAmber,
                onTap: () async {
                  await controller.chooseSmallerPlan(true);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editBackup(BuildContext context) async {
    final controller = AppScope.read(context);
    final current = controller.bundle!;
    var obstacle = current.backup.obstacle;
    final text = TextEditingController(text: current.backup.fallbackAction);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                    Text(
                      'Edit backup route',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A fallback should be easier under the exact obstacle it is built for.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: ActlyColors.mutedSteel),
                    ),
                    const SizedBox(height: 18),
                    for (final value in ObstacleType.values) ...[
                      ChoiceTile(
                        label: value.label,
                        selected: obstacle == value,
                        accent: ActlyColors.rescueAmber,
                        onTap: () => setSheetState(() => obstacle = value),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: text,
                      maxLength: 90,
                      decoration:
                          const InputDecoration(labelText: 'Fallback action'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ActlyColors.rescueAmber,
                      ),
                      onPressed: () async {
                        if (text.text.trim().isEmpty) return;
                        await controller.updateBackup(
                          obstacle: obstacle,
                          fallbackAction: text.text,
                        );
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: const Text('Save backup plan'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    text.dispose();
  }

  Future<void> _editTrigger(BuildContext context) async {
    final controller = AppScope.read(context);
    final current = controller.bundle!;
    var triggerId = current.plan.triggerId;
    var triggerLabel = current.plan.triggerLabel;
    final parts = current.plan.approximateTime.split(':');
    var time = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 18,
      minute: int.tryParse(parts.last) ?? 30,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            String formattedTime() =>
                '${time.hour.toString().padLeft(2, '0')}:'
                '${time.minute.toString().padLeft(2, '0')}';

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Edit trigger',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a recurring moment first. The time remains approximate.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: ActlyColors.mutedSteel),
                    ),
                    const SizedBox(height: 18),
                    for (final option in _TriggerChoice.values) ...[
                      ChoiceTile(
                        label: option.label,
                        description: 'Approx. ${option.time}',
                        selected: triggerId == option.id,
                        onTap: () {
                          final timeParts = option.time.split(':');
                          setSheetState(() {
                            triggerId = option.id;
                            triggerLabel = option.label;
                            time = TimeOfDay(
                              hour: int.parse(timeParts[0]),
                              minute: int.parse(timeParts[1]),
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: time,
                          helpText: 'Approximate trigger time',
                        );
                        if (!sheetContext.mounted) return;
                        if (picked != null) {
                          setSheetState(() => time = picked);
                        }
                      },
                      icon: const Icon(Icons.schedule),
                      label: Text('Approximate time: ${formattedTime()}'),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.updateTrigger(
                          triggerId: triggerId,
                          triggerLabel: triggerLabel,
                          approximateTime: formattedTime(),
                        );
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: const Text('Save trigger'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              value.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ActlyColors.signalCyan,
                  ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 11),
          const Divider(height: 1),
          const SizedBox(height: 11),
        ],
      ],
    );
  }
}

class _TriggerChoice {
  const _TriggerChoice(this.id, this.label, this.time);

  final String id;
  final String label;
  final String time;

  static const values = <_TriggerChoice>[
    _TriggerChoice('after_breakfast', 'Right after breakfast', '08:15'),
    _TriggerChoice('after_lunch', 'Right after lunch', '13:00'),
    _TriggerChoice('after_work', 'When work or class ends', '17:30'),
    _TriggerChoice('when_home', 'When I get home', '18:30'),
    _TriggerChoice('after_dinner', 'Right after dinner', '20:00'),
    _TriggerChoice('before_bed', 'Before I go to sleep', '22:30'),
  ];
}
