import 'dart:convert';

import 'package:actly/data/db/app_database.dart';
import 'package:actly/data/models/enums.dart';
import 'package:actly/data/models/models.dart';
import 'package:sqflite/sqflite.dart';

class DataCounts {
  const DataCounts({required this.real, required this.simulation});

  final int real;
  final int simulation;
}

class AppRepository {
  AppRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<ActivePlanBundle?> loadActiveBundle() async {
    final db = await _database.database;
    final goals = await db.query(
      'goals',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (goals.isEmpty) return null;

    final goal = GoalModel.fromMap(goals.first);
    final diagnoses = await db.query(
      'diagnoses',
      where: 'goal_id = ?',
      whereArgs: [goal.id],
      limit: 1,
    );
    final plans = await db.query(
      'plans',
      where: 'goal_id = ? AND is_active = 1',
      whereArgs: [goal.id],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (diagnoses.isEmpty || plans.isEmpty) return null;

    final plan = PlanModel.fromMap(plans.first);
    final backups = await db.query(
      'backup_plans',
      where: 'plan_id = ?',
      whereArgs: [plan.id],
      limit: 1,
    );
    if (backups.isEmpty) return null;

    return ActivePlanBundle(
      goal: goal,
      diagnosis: DiagnosisModel.fromMap(diagnoses.first),
      plan: plan,
      backup: BackupPlanModel.fromMap(backups.first),
    );
  }

  Future<void> saveNewBundle(ActivePlanBundle bundle) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.update('goals', {'is_active': 0});
      await txn.update('plans', {'is_active': 0});
      await txn.insert('goals', bundle.goal.toMap());
      await txn.insert('diagnoses', bundle.diagnosis.toMap());
      await txn.insert('plans', bundle.plan.toMap());
      await txn.insert('backup_plans', bundle.backup.toMap());
    });
  }

  Future<void> updateBackupPlan(BackupPlanModel backup) async {
    final db = await _database.database;
    await db.update(
      'backup_plans',
      backup.toMap(),
      where: 'id = ?',
      whereArgs: [backup.id],
    );
  }

  Future<void> updatePlan(PlanModel plan) async {
    final db = await _database.database;
    await db.update(
      'plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<DailyEntryModel?> getEntryForDate(
    DateTime date,
    EntrySource source,
  ) async {
    final db = await _database.database;
    final rows = await db.query(
      'daily_entries',
      where: 'entry_date = ? AND source = ?',
      whereArgs: [dateOnly(date), source.name],
      limit: 1,
    );
    return rows.isEmpty ? null : DailyEntryModel.fromMap(rows.first);
  }

  Future<void> upsertDailyEntry(DailyEntryModel entry) async {
    final db = await _database.database;
    await db.insert(
      'daily_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DailyEntryModel>> getEntries({
    DateTime? from,
    DateTime? to,
    EntrySource? source,
  }) async {
    final db = await _database.database;
    final conditions = <String>[];
    final args = <Object?>[];

    if (from != null) {
      conditions.add('entry_date >= ?');
      args.add(dateOnly(from));
    }
    if (to != null) {
      conditions.add('entry_date <= ?');
      args.add(dateOnly(to));
    }
    if (source != null) {
      conditions.add('source = ?');
      args.add(source.name);
    }

    final rows = await db.query(
      'daily_entries',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'entry_date ASC',
    );
    return rows.map(DailyEntryModel.fromMap).toList(growable: false);
  }

  Future<DataCounts> getDataCounts() async {
    final db = await _database.database;
    final real = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM daily_entries WHERE source = ?',
            [EntrySource.real.name],
          ),
        ) ??
        0;
    final simulation = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM daily_entries WHERE source = ?',
            [EntrySource.simulation.name],
          ),
        ) ??
        0;
    return DataCounts(real: real, simulation: simulation);
  }

  Future<void> clearSimulationData() async {
    final db = await _database.database;
    await db.delete(
      'daily_entries',
      where: 'source = ?',
      whereArgs: [EntrySource.simulation.name],
    );
  }

  Future<void> saveWeeklyFeedback(WeeklyFeedbackModel feedback) async {
    final db = await _database.database;
    await db.insert(
      'weekly_feedback',
      feedback.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<WeeklyFeedbackModel?> getWeeklyFeedback(String isoWeek) async {
    final db = await _database.database;
    final rows = await db.query(
      'weekly_feedback',
      where: 'iso_week = ?',
      whereArgs: [isoWeek],
      limit: 1,
    );
    return rows.isEmpty ? null : WeeklyFeedbackModel.fromMap(rows.first);
  }

  Future<String> exportAllData() async {
    final db = await _database.database;
    final tables = <String>[
      'goals',
      'diagnoses',
      'plans',
      'backup_plans',
      'daily_entries',
      'weekly_feedback',
    ];
    final payload = <String, Object?>{
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'product': 'Actly',
    };
    for (final table in tables) {
      payload[table] = await db.query(table);
    }
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> rebuildDatabase() => _database.rebuild();

  Future<void> resetEverything() async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('weekly_feedback');
      await txn.delete('daily_entries');
      await txn.delete('backup_plans');
      await txn.delete('plans');
      await txn.delete('diagnoses');
      await txn.delete('goals');
    });
  }
}
