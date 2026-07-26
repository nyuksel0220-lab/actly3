import 'package:actly/app/actly_controller.dart';
import 'package:actly/app/app_scope.dart';
import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/data/models/enums.dart';
import 'package:actly/widgets/blueprint_scaffold.dart';
import 'package:actly/widgets/choice_tile.dart';
import 'package:actly/widgets/if_then_diagram.dart';
import 'package:actly/widgets/radial_gauge.dart';
import 'package:actly/widgets/technical_card.dart';
import 'package:flutter/material.dart';

class GoalWizardScreen extends StatefulWidget {
  const GoalWizardScreen({super.key});

  @override
  State<GoalWizardScreen> createState() => _GoalWizardScreenState();
}

class _GoalWizardScreenState extends State<GoalWizardScreen> {
  static const _totalSteps = 7;
  int _step = 0;
  bool _saving = false;

  GoalCategory? _category;
  final _originalController = TextEditingController();
  final _minimumController = TextEditingController();
  final _fallbackController = TextEditingController();

  DiagnosisAnswer? _clearWhenWhere;
  DiagnosisAnswer? _timeEnergy;
  DiagnosisAnswer? _actuallyWant;
  int _confidence = 7;
  bool? _useSmaller;
  _TriggerOption? _trigger;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 30);
  ObstacleType? _obstacle;

  @override
  void dispose() {
    _originalController.dispose();
    _minimumController.dispose();
    _fallbackController.dispose();
    super.dispose();
  }

  bool get _canAdvance => switch (_step) {
        0 => _category != null,
        1 =>
          _originalController.text.trim().isNotEmpty &&
              _minimumController.text.trim().isNotEmpty,
        2 =>
          _clearWhenWhere != null &&
              _timeEnergy != null &&
              _actuallyWant != null,
        3 => _confidence >= 7 || _useSmaller != null,
        4 => _trigger != null,
        5 => _obstacle != null && _fallbackController.text.trim().isNotEmpty,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    return BlueprintScaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    if (_step > 0)
                      IconButton(
                        tooltip: 'Previous step',
                        onPressed: () => setState(() => _step -= 1),
                        icon: const Icon(Icons.arrow_back),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        'BUILD PLAN',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              letterSpacing: 1.6,
                            ),
                      ),
                    ),
                    Text(
                      '${(_step + 1).toString().padLeft(2, '0')} / '
                      '${_totalSteps.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (_step + 1) / _totalSteps,
                  minHeight: 2,
                  backgroundColor: ActlyColors.divider,
                  color: _step == 5
                      ? ActlyColors.rescueAmber
                      : ActlyColors.signalCyan,
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: _buildStep(context),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !_canAdvance || _saving ? null : _advance,
                child: Text(
                  _step == _totalSteps - 1
                      ? (_saving ? 'Saving plan' : 'Save plan')
                      : _nextLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _nextLabel => switch (_step) {
        0 => 'Define the behavior',
        1 => 'Run 60-second diagnosis',
        2 => 'Set confidence',
        3 => 'Attach a trigger',
        4 => 'Build a backup route',
        5 => 'Review the plan',
        _ => 'Save plan',
      };

  Widget _buildStep(BuildContext context) => switch (_step) {
        0 => _goalStep(context),
        1 => _actionStep(context),
        2 => _diagnosisStep(context),
        3 => _confidenceStep(context),
        4 => _triggerStep(context),
        5 => _backupStep(context),
        _ => _reviewStep(context),
      };

  Widget _header(String code, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ActlyColors.signalCyan,
              ),
        ),
        const SizedBox(height: 10),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 10),
        Text(
          body,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: ActlyColors.mutedSteel),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _goalStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'INPUT 01',
          'Choose one behavior domain.',
          'V1 keeps one active goal. A narrow system is easier to test than ten simultaneous intentions.',
        ),
        ...GoalCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ChoiceTile(
              label: category.label,
              selected: _category == category,
              leading: Icon(_categoryIcon(category)),
              onTap: () {
                setState(() {
                  _category = category;
                  _originalController.text = category.defaultAction;
                  _minimumController.text = category.defaultMinimumAction;
                  _fallbackController.text = category.defaultMinimumAction;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _actionStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'INPUT 02',
          'State the action so it can be observed.',
          'Use a verb and a measurable end point. “Be healthier” cannot be completed. “Walk for 20 minutes” can.',
        ),
        TextField(
          controller: _originalController,
          maxLength: 90,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Original action',
            hintText: 'Walk for 20 minutes',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _minimumController,
          maxLength: 90,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Smaller action',
            hintText: 'Walk for 5 minutes',
          ),
        ),
        const SizedBox(height: 8),
        const TechnicalCard(
          borderColor: ActlyColors.rescueAmber,
          child: Text(
            'The smaller action is not used automatically. You decide whether to use it after rating confidence.',
          ),
        ),
      ],
    );
  }

  Widget _diagnosisStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'DIAGNOSIS',
          'Three constraints. Tap the honest answer.',
          'No score is shown. The questions exist to expose what the plan depends on.',
        ),
        _DiagnosisQuestion(
          index: '01',
          question: 'Is it clear exactly when and where you will do this?',
          value: _clearWhenWhere,
          onChanged: (value) => setState(() => _clearWhenWhere = value),
        ),
        const SizedBox(height: 16),
        _DiagnosisQuestion(
          index: '02',
          question: 'Do you honestly have the time and energy for this today?',
          value: _timeEnergy,
          onChanged: (value) => setState(() => _timeEnergy = value),
        ),
        const SizedBox(height: 16),
        _DiagnosisQuestion(
          index: '03',
          question:
              'Do you actually want this, or do you mainly feel that you “should”?',
          value: _actuallyWant,
          onChanged: (value) => setState(() => _actuallyWant = value),
        ),
      ],
    );
  }

  Widget _confidenceStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'CALIBRATION',
          'How likely are you to actually do this tomorrow?',
          'Rate the real plan, not the person you hope to be on a perfect day.',
        ),
        Center(child: RadialGauge(value: _confidence)),
        Slider(
          value: _confidence.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: _confidence.toString(),
          onChanged: (value) {
            setState(() {
              _confidence = value.round();
              if (_confidence >= 7) _useSmaller = false;
              if (_confidence < 7 && _useSmaller == false) {
                _useSmaller = null;
              }
            });
          },
        ),
        if (_confidence < 7) ...[
          const SizedBox(height: 12),
          Text(
            'The plan may be larger than tomorrow allows. Choose explicitly.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _PlanSizeChoice(
                  label: 'KEEP ORIGINAL',
                  action: _originalController.text.trim(),
                  selected: _useSmaller == false,
                  accent: ActlyColors.signalCyan,
                  onTap: () => setState(() => _useSmaller = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PlanSizeChoice(
                  label: 'USE SMALLER',
                  action: _minimumController.text.trim(),
                  selected: _useSmaller == true,
                  accent: ActlyColors.rescueAmber,
                  onTap: () => setState(() => _useSmaller = true),
                ),
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          TechnicalCard(
            child: Text(
              'Confidence is $_confidence/10. The original plan remains selected.',
            ),
          ),
        ],
      ],
    );
  }

  Widget _triggerStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'IF → THEN',
          'Attach the action to a real moment.',
          'The clock is approximate. The recurring moment is the main trigger.',
        ),
        ..._TriggerOption.defaults.map((trigger) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ChoiceTile(
              label: trigger.label,
              description: 'Approx. ${trigger.time}',
              selected: _trigger?.id == trigger.id,
              onTap: () {
                setState(() {
                  _trigger = trigger;
                  _time = _parseTime(trigger.time);
                });
              },
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickTime,
          icon: const Icon(Icons.schedule),
          label: Text('Set approximate time: ${_formatTime(_time)}'),
        ),
        if (_trigger != null) ...[
          const SizedBox(height: 20),
          IfThenDiagram(
            trigger: _trigger!.label,
            action: _selectedAction,
            compact: true,
          ),
        ],
      ],
    );
  }

  Widget _backupStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'BACKUP ROUTE',
          'What is most likely to get in the way?',
          'Prepare the fallback before the obstacle arrives. Using it rescues the day; it is not a red outcome.',
        ),
        ...ObstacleType.values.map((obstacle) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ChoiceTile(
              label: obstacle.label,
              selected: _obstacle == obstacle,
              accent: ActlyColors.rescueAmber,
              onTap: () => setState(() => _obstacle = obstacle),
            ),
          );
        }),
        const SizedBox(height: 10),
        TextField(
          controller: _fallbackController,
          maxLength: 90,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Fallback action',
            hintText: 'Walk indoors for 5 minutes',
          ),
        ),
        const SizedBox(height: 8),
        TechnicalCard(
          borderColor: ActlyColors.rescueAmber,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.alt_route,
                color: ActlyColors.rescueAmber,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'BACKUP → ${_fallbackController.text.trim().isEmpty ? 'Define a fallback action' : _fallbackController.text.trim()}',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'FINAL CHECK',
          'The plan is a small operating system for tomorrow.',
          'Nothing changes automatically later. Every adjustment remains your choice.',
        ),
        IfThenDiagram(
          trigger: _trigger!.label,
          action: _selectedAction,
        ),
        const SizedBox(height: 16),
        TechnicalCard(
          borderColor: ActlyColors.rescueAmber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Backup route'),
              const SizedBox(height: 12),
              Text(_obstacle!.label),
              const SizedBox(height: 8),
              Text(
                _fallbackController.text.trim(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ActlyColors.rescueAmber,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TechnicalCard(
          child: Row(
            children: [
              RadialGauge(value: _confidence, size: 92, animate: false),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Confidence'),
                    const SizedBox(height: 8),
                    Text(
                      _useSmaller == true
                          ? 'Smaller action selected by you.'
                          : 'Original action selected.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _selectedAction => _useSmaller == true
      ? _minimumController.text.trim()
      : _originalController.text.trim();

  Future<void> _advance() async {
    if (_step < _totalSteps - 1) {
      setState(() => _step += 1);
      return;
    }

    setState(() => _saving = true);
    await AppScope.read(context).savePlan(
      PlanDraft(
        category: _category!,
        originalAction: _originalController.text,
        minimumAction: _minimumController.text,
        clearWhenWhere: _clearWhenWhere!,
        timeEnergy: _timeEnergy!,
        actuallyWant: _actuallyWant!,
        confidence: _confidence,
        shrunkChosen: _useSmaller ?? false,
        triggerId: _trigger!.id,
        triggerLabel: _trigger!.label,
        approximateTime: _formatTime(_time),
        obstacle: _obstacle!,
        fallbackAction: _fallbackController.text,
      ),
    );
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Approximate trigger time',
    );
    if (!mounted) return;
    if (selected != null) setState(() => _time = selected);
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  IconData _categoryIcon(GoalCategory category) => switch (category) {
        GoalCategory.movement => Icons.directions_walk,
        GoalCategory.sleep => Icons.bedtime_outlined,
        GoalCategory.study => Icons.menu_book_outlined,
        GoalCategory.screenTime => Icons.phone_android,
        GoalCategory.hydration => Icons.water_drop_outlined,
        GoalCategory.social => Icons.forum_outlined,
        GoalCategory.exercise => Icons.fitness_center,
      };
}

class _PlanSizeChoice extends StatelessWidget {
  const _PlanSizeChoice({
    required this.label,
    required this.action,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final String action;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label: $action',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 152),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.12)
                  : ActlyColors.panelBlue,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? accent : ActlyColors.divider,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: selected ? accent : ActlyColors.mutedSteel,
                              fontSize: 10,
                            ),
                      ),
                    ),
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: selected ? accent : ActlyColors.mutedSteel,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  action,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosisQuestion extends StatelessWidget {
  const _DiagnosisQuestion({
    required this.index,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final String index;
  final String question;
  final DiagnosisAnswer? value;
  final ValueChanged<DiagnosisAnswer> onChanged;

  @override
  Widget build(BuildContext context) {
    return TechnicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q$index',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ActlyColors.signalCyan,
                ),
          ),
          const SizedBox(height: 8),
          Text(question, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DiagnosisAnswer.values.map((answer) {
                  final selected = value == answer;
                  return SizedBox(
                    width: (constraints.maxWidth - 16) / 3,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selected
                            ? ActlyColors.signalCyan.withValues(alpha: 0.12)
                            : null,
                        side: BorderSide(
                          color: selected
                              ? ActlyColors.signalCyan
                              : ActlyColors.divider,
                        ),
                      ),
                      onPressed: () => onChanged(answer),
                      child: Text(answer.label),
                    ),
                  );
                }).toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TriggerOption {
  const _TriggerOption(this.id, this.label, this.time);

  final String id;
  final String label;
  final String time;

  static const defaults = <_TriggerOption>[
    _TriggerOption('after_breakfast', 'Right after breakfast', '08:15'),
    _TriggerOption('after_lunch', 'Right after lunch', '13:00'),
    _TriggerOption('after_work', 'When work or class ends', '17:30'),
    _TriggerOption('when_home', 'When I get home', '18:30'),
    _TriggerOption('after_dinner', 'Right after dinner', '20:00'),
    _TriggerOption('before_bed', 'Before I go to sleep', '22:30'),
  ];
}
