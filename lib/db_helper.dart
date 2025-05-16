import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE data(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      categoria TEXT,
      descripcion TEXT,
      monto REAL,
      fecha TEXT
    )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "database_name.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createData(
    String categoria,
    String? descripcion,
    double monto,
    String fecha,
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'categoria': categoria,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha,
    };
    final id = await db.insert(
      'data',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );

    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();
    return db.query('data', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await SQLHelper.db();
    return db.query('data', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateData(
    int id,
    String categoria,
    String? descripcion,
    double monto,
    String fecha,
  ) async {
    final db = await SQLHelper.db();
    final data = {
      'categoria': categoria,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha,
    };
    final result = await db.update(
      'data',
      data,
      where: "id = ?",
      whereArgs: [id],
    );
    return result;
  }

  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('data', where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }
}
