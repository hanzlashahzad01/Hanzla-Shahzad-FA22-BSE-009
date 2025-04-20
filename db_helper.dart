import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'member.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'committee.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE members(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            totalContributed REAL,
            totalReceived REAL
          )
        ''');
      },
    );
  }

  Future<int> insertMember(Member member) async {
    final database = await db;
    return await database.insert('members', member.toMap());
  }

  Future<List<Member>> getMembers() async {
    final database = await db;
    final result = await database.query('members');
    return result.map((map) => Member.fromMap(map)).toList();
  }

  Future<int> updateMember(Member member) async {
    final database = await db;
    return await database.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> clearAll() async {
    final database = await db;
    await database.delete('members');
  }
}
