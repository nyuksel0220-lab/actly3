import 'package:actly/app/app_scope.dart';
import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/widgets/blueprint_scaffold.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const _pages = <({String code, String title, String body})>[
    (
      code: 'PRINCIPLE 01',
      title: "Don't try to get more motivated. Make the plan smaller instead.",
      body:
          'Actly works on the plan itself. No streak pressure. No motivational speeches.',
    ),
    (
      code: 'PRINCIPLE 02',
      title:
          'Actly finds the real obstacle in your way and fits the goal to your actual life.',
      body:
          'Time, energy, clarity and context are design constraints, not character flaws.',
    ),
    (
      code: 'PRINCIPLE 03',
      title: "A small plan isn't failure. It's the engineering of not stopping.",
      body:
          'A backup action rescues a difficult day. It counts because the direction stayed intact.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    return BlueprintScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'ACTLY',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 2.2,
                      ),
                ),
                const Spacer(),
                Text(
                  '${(_index + 1).toString().padLeft(2, '0')} / 03',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_index + 1) / _pages.length,
              minHeight: 2,
              backgroundColor: ActlyColors.divider,
              color: ActlyColors.signalCyan,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ActlyColors.signalCyan,
                              ),
                            ),
                            child: Text(
                              page.code,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: ActlyColors.signalCyan),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            page.title,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            page.body,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: ActlyColors.mutedSteel),
                          ),
                          const SizedBox(height: 36),
                          _SchematicMark(index: index),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_index < _pages.length - 1) {
                    await _pageController.nextPage(
                      duration: reducedMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    );
                  } else {
                    await AppScope.read(context).completeOnboarding();
                  }
                },
                child: Text(
                  _index == _pages.length - 1
                      ? 'Choose one goal'
                      : 'Read next principle',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchematicMark extends StatelessWidget {
  const _SchematicMark({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final labels = switch (index) {
      0 => ('LARGE PLAN', 'SMALLER START'),
      1 => ('REAL OBSTACLE', 'FITTED PLAN'),
      _ => ('DIFFICULT DAY', 'BACKUP ROUTE'),
    };
    return Semantics(
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(child: _Block(label: labels.$1)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.arrow_forward,
              color: ActlyColors.signalCyan,
            ),
          ),
          Expanded(
            child: _Block(
              label: labels.$2,
              accent: index == 2
                  ? ActlyColors.rescueAmber
                  : ActlyColors.signalCyan,
            ),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.label,
    this.accent = ActlyColors.mutedSteel,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ActlyColors.blueprintBlue,
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
            ),
      ),
    );
  }
}
