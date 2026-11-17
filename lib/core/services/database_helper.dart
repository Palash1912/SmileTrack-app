import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/brushing/data/models/brushing_log.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smiletrack.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table with credentials and active session tracking
    await db.execute('''
      CREATE TABLE users (
        uid TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        display_name TEXT,
        avatar_url TEXT,
        age INTEGER DEFAULT 0,
        country TEXT,
        timezone TEXT,
        created_at TEXT NOT NULL,
        total_points INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        max_streak INTEGER DEFAULT 0,
        badges TEXT,
        is_logged_in INTEGER DEFAULT 0
      )
    ''');

    // Brushing logs table for tracking daily count and sessions
    await db.execute('''
      CREATE TABLE brushing_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        date_key TEXT NOT NULL,
        session TEXT NOT NULL,
        timezone TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        points_earned INTEGER DEFAULT 10,
        FOREIGN KEY (user_id) REFERENCES users (uid) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_brushing_user_date ON brushing_logs (user_id, date_key)',
    );
    await db.execute(
      'CREATE INDEX idx_brushing_user_session ON brushing_logs (user_id, date_key, session)',
    );
  }

  // ─────────────────────────────────────────────
  // USER & CREDENTIAL OPERATIONS
  // ─────────────────────────────────────────────

  Future<void> insertUser(
    UserModel user,
    String password, {
    bool isLoggedIn = true,
  }) async {
    final db = await database;
    if (isLoggedIn) {
      await db.update('users', {'is_logged_in': 0});
    }

    final data = user.toMap(
      password: password,
      isLoggedIn: isLoggedIn ? 1 : 0,
    );

    await db.insert(
      'users',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> validateCredentials(String email, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'LOWER(email) = LOWER(?) AND password = ?',
      whereArgs: [email.trim(), password],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'LOWER(email) = LOWER(?)',
      whereArgs: [email.trim()],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  Future<UserModel?> getActiveUser() async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'is_logged_in = 1',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  Future<void> setLoggedInUser(String uid) async {
    final db = await database;
    await db.update('users', {'is_logged_in': 0});
    await db.update(
      'users',
      {'is_logged_in': 1},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  Future<void> clearActiveUser() async {
    final db = await database;
    await db.update('users', {'is_logged_in': 0});
  }

  Future<String?> getPasswordForUser(String uid) async {
    final db = await database;
    final results = await db.query(
      'users',
      columns: ['password'],
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first['password'] as String?;
  }

  Future<void> updatePassword(String uid, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      {
        'display_name': user.displayName,
        'avatar_url': user.avatarUrl,
        'age': user.age,
        'country': user.country,
        'timezone': user.timezone,
        'total_points': user.totalPoints,
        'current_streak': user.currentStreak,
        'max_streak': user.maxStreak,
      },
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  Future<int> addPoints(String uid, int pointsEarned) async {
    final db = await database;
    final results = await db.query(
      'users',
      columns: ['total_points'],
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );

    int current = 0;
    if (results.isNotEmpty) {
      current = results.first['total_points'] as int? ?? 0;
    }

    final newTotal = current + pointsEarned;
    await db.update(
      'users',
      {'total_points': newTotal},
      where: 'uid = ?',
      whereArgs: [uid],
    );

    return newTotal;
  }

  Future<void> updateStreaks(
    String uid,
    int currentStreak,
    int maxStreak,
  ) async {
    final db = await database;
    await db.update(
      'users',
      {
        'current_streak': currentStreak,
        'max_streak': maxStreak,
      },
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // ─────────────────────────────────────────────
  // BRUSHING LOGS & DAILY COUNT OPERATIONS
  // ─────────────────────────────────────────────

  Future<void> insertBrushingLog(BrushingLog log) async {
    final db = await database;
    await db.insert(
      'brushing_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getBrushingCountForDate(String userId, String dateKey) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM brushing_logs WHERE user_id = ? AND date_key = ?',
      [userId, dateKey],
    );

    if (result.isEmpty) return 0;
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> hasBrushedSessionToday(
    String userId,
    String dateKey,
    String session,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM brushing_logs WHERE user_id = ? AND date_key = ? AND session = ?',
      [userId, dateKey, session],
    );

    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<List<BrushingLog>> getLogsForDate(String userId, String dateKey) async {
    final db = await database;
    final results = await db.query(
      'brushing_logs',
      where: 'user_id = ? AND date_key = ?',
      whereArgs: [userId, dateKey],
      orderBy: 'timestamp ASC',
    );

    return results.map((m) => BrushingLog.fromMap(m)).toList();
  }

  Future<List<BrushingLog>> getLogsForMonth(
    String userId,
    int year,
    int month,
  ) async {
    final db = await database;
    final monthPrefix =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}%';

    final results = await db.query(
      'brushing_logs',
      where: 'user_id = ? AND date_key LIKE ?',
      whereArgs: [userId, monthPrefix],
      orderBy: 'timestamp ASC',
    );

    return results.map((m) => BrushingLog.fromMap(m)).toList();
  }

  Future<List<BrushingLog>> getAllLogsForUser(String userId) async {
    final db = await database;
    final results = await db.query(
      'brushing_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp ASC',
    );

    return results.map((m) => BrushingLog.fromMap(m)).toList();
  }
}
