import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final path = p.join(await getDatabasesPath(), 'actly_v1.db');
    _database = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _create,
    );
    return _database!;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals(
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        original_action TEXT NOT NULL,
        minimum_action TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE diagnoses(
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        clear_when_where TEXT NOT NULL,
        time_energy TEXT NOT NULL,
        actually_want TEXT NOT NULL,
        FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE plans(
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        trigger_id TEXT NOT NULL,
        trigger_label TEXT NOT NULL,
        approximate_time TEXT NOT NULL,
        confidence INTEGER NOT NULL,
        shrunk_chosen INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE backup_plans(
        id TEXT PRIMARY KEY,
        plan_id TEXT NOT NULL,
        obstacle_id TEXT NOT NULL,
        obstacle_label TEXT NOT NULL,
        fallback_action TEXT NOT NULL,
        FOREIGN KEY(plan_id) REFERENCES plans(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_entries(
        id TEXT PRIMARY KEY,
        entry_date TEXT NOT NULL,
        action_taken TEXT NOT NULL,
        streak_value INTEGER NOT NULL,
        snooze_count INTEGER NOT NULL,
        snoozed_until TEXT,
        skip_reason TEXT,
        notification_shown_at TEXT,
        started_at TEXT,
        completed_at TEXT,
        goal_action_snapshot TEXT NOT NULL,
        minimum_action_snapshot TEXT NOT NULL,
        trigger_id_snapshot TEXT NOT NULL,
        trigger_label_snapshot TEXT NOT NULL,
        trigger_time_snapshot TEXT NOT NULL,
        confidence_snapshot INTEGER NOT NULL,
        shrunk_chosen_snapshot INTEGER NOT NULL,
        source TEXT NOT NULL,
        UNIQUE(entry_date, source)
      )
    ''');

    await db.execute('''
      CREATE TABLE weekly_feedback(
        id TEXT PRIMARY KEY,
        iso_week TEXT NOT NULL UNIQUE,
        rating TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_entries_date_source ON daily_entries(entry_date, source)',
    );
    await db.execute(
      'CREATE INDEX idx_entries_trigger ON daily_entries(trigger_id_snapshot)',
    );
  }

  Future<void> rebuild() async {
    await close();
    final path = p.join(await getDatabasesPath(), 'actly_v1.db');
    await deleteDatabase(path);
    await database;
  }

  Future<void> close() async {
    final database = _database;
    if (database != null) {
      await database.close();
      _database = null;
    }
  }
}
