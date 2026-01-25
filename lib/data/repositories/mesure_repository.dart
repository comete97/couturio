import 'package:couturio/data/database/app_database.dart';
import 'package:couturio/data/models/mesure.dart';
import 'package:sqflite/sqflite.dart';

class MesureRepository {
  final AppDatabase _dbHelper = AppDatabase();

  // ----------------------- INSERT -----------------------
  Future<int> insertMesure(Mesure mesure) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'mesures',
      mesure.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------- GET ALL -----------------------
  Future<List<Mesure>> getAllMesures() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'mesures',
      orderBy: 'date DESC',
    );
    return maps.map((m) => Mesure.fromMap(m)).toList();
  }

  // ----------------------- GET BY ID -----------------------
  Future<Mesure?> getMesureById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'mesures',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Mesure.fromMap(maps.first);
    return null;
  }

  // ----------------------- GET BY CLIENT -----------------------
  Future<List<Mesure>> getMesuresByClient(int clientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'mesures',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Mesure.fromMap(m)).toList();
  }

  // ----------------------- UPDATE -----------------------
  Future<int> updateMesure(Mesure mesure) async {
    final db = await _dbHelper.database;
    return await db.update(
      'mesures',
      mesure.toMap(),
      where: 'id = ?',
      whereArgs: [mesure.id],
    );
  }

  // ----------------------- DELETE (HARD DELETE) -----------------------
  Future<int> deleteMesure(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'mesures',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------- SEARCH -----------------------
  // Exemple : recherche par description ou notes
  Future<List<Mesure>> searchMesures(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'mesures',
      where: 'description LIKE ? OR notes LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Mesure.fromMap(m)).toList();
  }

    // ----------------------- GET LAST MESURE BY CLIENT -----------------------
  Future<Mesure?> getLastMesureByClient(int clientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'mesures',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) return Mesure.fromMap(maps.first);
    return null;
  }
}
