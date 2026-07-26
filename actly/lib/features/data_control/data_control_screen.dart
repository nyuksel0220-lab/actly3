import 'dart:convert';
import 'dart:typed_data';

import 'package:actly/app/app_scope.dart';
import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/core/design/actly_typography.dart';
import 'package:actly/widgets/technical_card.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class DataControlScreen extends StatelessWidget {
  const DataControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'DATA // LOCAL DEVICE',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ActlyColors.signalCyan,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your records. Your controls.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'V1 has no account, backend or cloud sync. Product records remain in the local SQLite database.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: ActlyColors.mutedSteel),
        ),
        const SizedBox(height: 20),
        TechnicalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Entry inventory'),
              const SizedBox(height: 18),
              Row(
                children: [
                  _CountBlock(
                    label: 'REAL',
                    value: controller.counts.real,
                    color: ActlyColors.signalCyan,
                  ),
                  const SizedBox(width: 12),
                  _CountBlock(
                    label: 'SIMULATION',
                    value: controller.counts.simulation,
                    color: ActlyColors.rescueAmber,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Real weekly reports exclude all entries tagged simulation.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TechnicalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel('Export'),
              const SizedBox(height: 12),
              Text(
                'Creates a readable JSON file containing every locally stored goal, plan, entry and weekly response.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _export(context),
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Export my data'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TechnicalCard(
          borderColor: ActlyColors.rescueAmber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel('Simulation controls'),
              const SizedBox(height: 12),
              Text(
                'Remove only reminder-preview records. Real entries and your current plan remain intact.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: ActlyColors.rescueAmber,
                  side: const BorderSide(color: ActlyColors.rescueAmber),
                ),
                onPressed: controller.counts.simulation == 0
                    ? null
                    : () => _clearSimulation(context),
                icon: const Icon(Icons.cleaning_services_outlined),
                label: const Text('Clear only my test/demo data'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TechnicalCard(
          borderColor: ActlyColors.faultRed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'DESTRUCTIVE CONTROL',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: ActlyColors.faultRed,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Delete the plan, diagnosis, all real and simulation entries, weekly feedback and first-launch state.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: ActlyColors.faultRed,
                  side: const BorderSide(color: ActlyColors.faultRed),
                ),
                onPressed: () => _reset(context),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete everything and reset the app'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context) async {
    final controller = AppScope.read(context);
    try {
      final json = await controller.exportData();
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final file = XFile.fromData(
        Uint8List.fromList(utf8.encode(json)),
        mimeType: 'application/json',
        name: 'actly_export_$stamp.json',
      );
      if (!context.mounted) return;
      final renderBox = context.findRenderObject() as RenderBox?;
      final shareOrigin = renderBox == null
          ? null
          : renderBox.localToGlobal(Offset.zero) & renderBox.size;
      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          subject: 'Actly data export',
          text: 'Actly local data export',
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    }
  }

  Future<void> _clearSimulation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear simulation data?'),
        content: const Text(
          'Only records created through “Preview/test this reminder now” will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep data'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ActlyColors.rescueAmber,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear test data'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await AppScope.read(context).clearSimulationData();
    }
  }

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
          'This cannot be undone. The app will return to the first onboarding screen and all local records will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ActlyColors.faultRed,
              foregroundColor: ActlyColors.paperBlue,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete and reset'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await AppScope.read(context).resetEverything();
    }
  }
}

class _CountBlock extends StatelessWidget {
  const _CountBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: ActlyTypography.data(size: 31, color: color),
            ),
            const SizedBox(height: 7),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
