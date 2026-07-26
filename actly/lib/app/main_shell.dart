import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/data/models/enums.dart';
import 'package:actly/features/data_control/data_control_screen.dart';
import 'package:actly/features/home/home_screen.dart';
import 'package:actly/features/plan/plan_screen.dart';
import 'package:actly/features/report/report_screen.dart';
import 'package:actly/widgets/blueprint_scaffold.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  RecommendationAction? _requestedPlanAction;
  int _requestSerial = 0;

  void _goToPlan() => setState(() => _index = 1);

  void _applyReportSuggestion(RecommendationAction action) {
    setState(() {
      _index = 1;
      _requestedPlanAction = action;
      _requestSerial += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onOpenPlan: _goToPlan),
      PlanScreen(
        requestedAction: _requestedPlanAction,
        requestSerial: _requestSerial,
        onRequestHandled: () => _requestedPlanAction = null,
      ),
      ReportScreen(onApplySuggestion: _applyReportSuggestion),
      const DataControlScreen(),
    ];

    return BlueprintScaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _TechnicalNavigation(
        index: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _TechnicalNavigation extends StatelessWidget {
  const _TechnicalNavigation({
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const items = <({IconData icon, String label})>[
    (icon: Icons.today_outlined, label: 'TODAY'),
    (icon: Icons.schema_outlined, label: 'PLAN'),
    (icon: Icons.analytics_outlined, label: 'REPORT'),
    (icon: Icons.storage_outlined, label: 'DATA'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: ActlyColors.inkNavy,
          border: Border(top: BorderSide(color: ActlyColors.divider)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
        child: Row(
          children: List.generate(items.length, (itemIndex) {
            final item = items[itemIndex];
            final selected = index == itemIndex;
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: item.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => onChanged(itemIndex),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 54),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? ActlyColors.signalCyan.withValues(alpha: 0.10)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? ActlyColors.signalCyan
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 21,
                          color: selected
                              ? ActlyColors.signalCyan
                              : ActlyColors.mutedSteel,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontSize: 10,
                                    color: selected
                                        ? ActlyColors.signalCyan
                                        : ActlyColors.mutedSteel,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
