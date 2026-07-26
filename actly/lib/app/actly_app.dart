import 'package:actly/app/actly_controller.dart';
import 'package:actly/app/app_scope.dart';
import 'package:actly/app/main_shell.dart';
import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/core/design/actly_theme.dart';
import 'package:actly/features/onboarding/onboarding_screen.dart';
import 'package:actly/features/plan/goal_wizard_screen.dart';
import 'package:actly/widgets/blueprint_scaffold.dart';
import 'package:flutter/material.dart';

class ActlyApp extends StatefulWidget {
  const ActlyApp({super.key});

  @override
  State<ActlyApp> createState() => _ActlyAppState();
}

class _ActlyAppState extends State<ActlyApp> with WidgetsBindingObserver {
  late final ActlyController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ActlyController();
    _controller.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.onAppResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        title: 'Actly',
        debugShowCheckedModeBanner: false,
        theme: ActlyTheme.dark(),
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    if (!controller.initialized) return const _LoadingScreen();
    if (controller.fatalError != null) return const _StorageErrorScreen();
    if (!controller.onboardingComplete) return const OnboardingScreen();
    if (controller.bundle == null) return const GoalWizardScreen();
    return const MainShell();
  }
}

class _StorageErrorScreen extends StatefulWidget {
  const _StorageErrorScreen();

  @override
  State<_StorageErrorScreen> createState() => _StorageErrorScreenState();
}

class _StorageErrorScreenState extends State<_StorageErrorScreen> {
  bool _working = false;

  Future<void> _retry() async {
    setState(() => _working = true);
    await AppScope.read(context).retryInitialization();
    if (mounted) setState(() => _working = false);
  }

  Future<void> _confirmRebuild() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset local Actly storage?'),
        content: const Text(
          'This deletes all local Actly plans, history, feedback, and settings on this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep data'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: ActlyColors.faultRed,
              foregroundColor: ActlyColors.paperBlue,
            ),
            child: const Text('Delete and rebuild'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _working = true);
    await AppScope.read(context).rebuildLocalStorage();
    if (mounted) setState(() => _working = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlueprintScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.storage_outlined,
                    size: 44,
                    color: ActlyColors.rescueAmber,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'LOCAL STORAGE DID NOT OPEN',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: ActlyColors.rescueAmber,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Actly could not read its local database.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Retry first. Use the rebuild option only when retry keeps failing; rebuilding permanently removes local Actly data from this device.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ActlyColors.mutedSteel,
                        ),
                  ),
                  const SizedBox(height: 26),
                  FilledButton.icon(
                    onPressed: _working ? null : _retry,
                    icon: _working
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('Retry local storage'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _working ? null : _confirmRebuild,
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('Delete data and rebuild storage'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return BlueprintScaffold(
      body: Center(
        child: Semantics(
          label: 'Loading Actly local data',
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ActlyColors.signalCyan,
                ),
              ),
              SizedBox(height: 16),
              Text('LOADING LOCAL SYSTEM'),
            ],
          ),
        ),
      ),
    );
  }
}
