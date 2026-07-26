import 'package:actly/app/app_scope.dart';
import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/core/design/actly_typography.dart';
import 'package:actly/data/models/enums.dart';
import 'package:actly/services/pattern_analysis_service.dart';
import 'package:actly/widgets/technical_card.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({required this.onApplySuggestion, super.key});

  final ValueChanged<RecommendationAction> onApplySuggestion;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final report = controller.report;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'WEEKLY REPORT // REAL DATA ONLY',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ActlyColors.signalCyan,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'What the plan taught us.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Simulation entries are excluded. Patterns are withheld until the minimum observation rules are met.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: ActlyColors.mutedSteel),
        ),
        const SizedBox(height: 20),
        _ResultSection(result: report.result),
        const SizedBox(height: 16),
        _PatternSection(report: report),
        const SizedBox(height: 16),
        _SuggestionSection(
          suggestion: report.suggestion,
          onApply: report.suggestion.action == RecommendationAction.none
              ? null
              : () => onApplySuggestion(report.suggestion.action),
        ),
        const SizedBox(height: 20),
        _WeeklyFeedback(
          selected: controller.currentWeekFeedback?.rating,
          onSelect: controller.saveWeeklyFeedback,
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.result});

  final ReportResult result;

  @override
  Widget build(BuildContext context) {
    return TechnicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Result'),
          const SizedBox(height: 18),
          Row(
            children: [
              _ResultMetric(label: 'PLANNED', value: result.planned),
              _ResultMetric(label: 'COMPLETED', value: result.completed),
              _ResultMetric(
                label: 'RESCUED',
                value: result.rescued,
                color: ActlyColors.rescueAmber,
              ),
              _ResultMetric(label: 'SKIPPED', value: result.skipped),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ActlyColors.signalCyan.withValues(alpha: 0.09),
              border: Border.all(color: ActlyColors.signalCyan),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Effective completion rate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${percentage(result.effectiveCompletionRate)}%',
                  style: ActlyTypography.data(
                    size: 29,
                    color: ActlyColors.signalCyan,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Full completions and successful backup routes both count.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({
    required this.label,
    required this.value,
    this.color = ActlyColors.paperBlue,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: ActlyTypography.data(size: 25, color: color),
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}

class _PatternSection extends StatelessWidget {
  const _PatternSection({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    return TechnicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Pattern learned'),
          const SizedBox(height: 16),
          if (report.insights.isEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.hourglass_empty,
                  color: ActlyColors.mutedSteel,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Not enough real data yet. Actly needs at least three observations before it describes a pattern; trigger comparisons need more.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: ActlyColors.mutedSteel),
                  ),
                ),
              ],
            )
          else
            ...report.insights.take(3).map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(top: 7),
                          color: ActlyColors.signalCyan,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(insight)),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _SuggestionSection extends StatelessWidget {
  const _SuggestionSection({
    required this.suggestion,
    required this.onApply,
  });

  final WeeklySuggestion suggestion;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return TechnicalCard(
      borderColor: ActlyColors.rescueAmber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Suggestion for next week'),
          const SizedBox(height: 14),
          Text(
            suggestion.text,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (onApply != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ActlyColors.rescueAmber,
              ),
              onPressed: onApply,
              child: Text(_buttonLabel(suggestion.action)),
            ),
          ],
        ],
      ),
    );
  }

  String _buttonLabel(RecommendationAction action) => switch (action) {
        RecommendationAction.editBackup => 'Edit backup plan',
        RecommendationAction.editTrigger => 'Edit trigger',
        RecommendationAction.shrinkPlan => 'Review action size',
        RecommendationAction.none => 'Keep current plan',
      };
}

class _WeeklyFeedback extends StatelessWidget {
  const _WeeklyFeedback({required this.selected, required this.onSelect});

  final FeedbackRating? selected;
  final ValueChanged<FeedbackRating> onSelect;

  @override
  Widget build(BuildContext context) {
    return TechnicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Was this week's suggestion actually useful?",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 13),
          Row(
            children: FeedbackRating.values.map((rating) {
              final active = selected == rating;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: rating == FeedbackRating.no ? 0 : 8,
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: active
                          ? ActlyColors.signalCyan.withValues(alpha: 0.12)
                          : null,
                      side: BorderSide(
                        color: active
                            ? ActlyColors.signalCyan
                            : ActlyColors.divider,
                      ),
                    ),
                    onPressed: selected == null ? () => onSelect(rating) : null,
                    child: Text(rating.label),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
          if (selected != null) ...[
            const SizedBox(height: 8),
            Text(
              'Response saved for this ISO week.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
