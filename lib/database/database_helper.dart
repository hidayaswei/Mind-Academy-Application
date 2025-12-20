import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = 'MindAcademy.db';
  static const _dbVersion = 4; 

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
  path,
  version: _dbVersion,
  onConfigure: (db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  },
  onCreate: _onCreate,
  onUpgrade: _onUpgrade,
);

  }

  // أول مرة تُنشأ القاعدة
  Future _onCreate(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,di
        phone TEXT
      )
    ''');

    // إنشاء أدمن افتراضي
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@mindacademy.com',
      'password': '123456',
      'role': 'admin',
      'phone': null,
    });

    // جدول المواد
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    // جدول الأساتذة
    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        specialization TEXT
      )
    ''');

    // جدول الدروس (مربوط بالمواد + الأساتذة)
    await db.execute('''
  CREATE TABLE lessons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject_id INTEGER NOT NULL,
    teacher_id INTEGER NOT NULL,
    day_of_week TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE CASCADE
  )
''');


    // جدول الحجوزات
   await db.execute('''
  CREATE TABLE bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL,
    status TEXT NOT NULL,
    created_at TEXT NOT NULL,
    cancelled_at TEXT,
    FOREIGN KEY (student_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
  )
''');

  }

 Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 4) {
    await db.execute('PRAGMA foreign_keys = OFF');

    await db.execute('DROP TABLE IF EXISTS bookings');
    await db.execute('DROP TABLE IF EXISTS lessons');

    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        teacher_id INTEGER NOT NULL,
        day_of_week TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        lesson_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        cancelled_at TEXT,
        FOREIGN KEY (student_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('PRAGMA foreign_keys = ON');
  }
}

  // ================== SUBJECTS ==================

  Future<int> insertSubject(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('subjects', row);
  }

  Future<List<Map<String, dynamic>>> getAllSubjects() async {
    final db = await database;
    return await db.query('subjects', orderBy: 'name ASC');
  }

  Future<int> updateSubject(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'] as int;return await db.update(
      'subjects',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // ================== TEACHERS ==================

  Future<int> insertTeacher(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('teachers', row);
  }

  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    final db = await database;
    return await db.query('teachers', orderBy: 'name ASC');
  }

  Future<int> updateTeacher(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'] as int;
    return await db.update(
      'teachers',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  // ================== LESSONS ==================

  Future<int> insertLesson(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('lessons', row);
  }

  Future<int> updateLesson(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'] as int;
    return await db.update(
      'lessons',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLesson(int id) async {
    final db = await database;
    return await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }

  // جلب الدروس لمادة معينة
  // ---------- lessons ----------
Future<List<Map<String, dynamic>>> getLessonsBySubject(int subjectId) async {
  final db = await database;

  return await db.rawQuery('''
    SELECT 
      lessons.id,
      lessons.subject_id,
      lessons.teacher_id,
      lessons.day_of_week,
      lessons.start_time,
      lessons.end_time,
      teachers.name AS teacher_name
    FROM lessons
    LEFT JOIN teachers 
      ON lessons.teacher_id = teachers.id
    WHERE lessons.subject_id = ?
    ORDER BY lessons.day_of_week, lessons.start_time
  ''', [subjectId]);
}

  // (اختياري) جلب الدروس مع اسم المادة واسم الأستاذ
  Future<List<Map<String, dynamic>>> getLessonsWithDetails() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT lessons.id,
             lessons.day_of_week,
             lessons.start_time,
             lessons.end_time,
             subjects.name AS subject_name,
             teachers.name AS teacher_name
      FROM lessons
      JOIN subjects ON lessons.subject_id = subjects.id
      JOIN teachers ON lessons.teacher_id = teachers.id
      ORDER BY subjects.name, lessons.day_of_week, lessons.start_time
    ''');
  }

  // ================== BOOKINGS ==================

  Future<int> insertBooking(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('bookings', row);
  }

  Future<List<Map<String, dynamic>>> getBookingsByStudent(int studentId) async {
    final db = await database;
    return await db.query(
      'bookings',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'created_at DESC',
    );
  }

 // إلغاء الحجز )
Future<void> cancelBooking(int bookingId) async {
  final dbInstance = await database;

  await dbInstance.update(
    'bookings',
    {
      'status': 'cancelled',   // نخلي حالة الحجز ملغاة
    },
    where: 'id = ?',
    whereArgs: [bookingId],
  );
}

  // ================== USERS ==================

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('users', row);
  }

  // تسجيل الدخول
  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
    String email,
    String password,
  ) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // كل المستخدمين أو حسب الدور
  Future<List<Map<String, dynamic>>> getUsers([String? role]) async {
    final db = await database;

    if (role == null) {
      return await db.query(
        'users',
        orderBy: 'role ASC, name ASC',
      );} else {
      return await db.query(
        'users',
        where: 'role = ?',
        whereArgs: [role],
        orderBy: 'name ASC',
      );
    }
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'] as int;

    return await db.update(
      'users',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUserPassword(int id, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}