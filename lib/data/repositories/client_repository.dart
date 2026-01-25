import 'package:couturio/data/database/app_database.dart';
import 'package:couturio/data/models/client.dart';
import 'package:sqflite/sqflite.dart';

class ClientRepository {
  final AppDatabase _dbHelper = AppDatabase();
  // ----------------------- INSERT -----------------------
  Future<int> insertClient(Client client) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'clients',
      client.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------- GET ALL -----------------------
  Future<List<Client>> getAllClients() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'clients',
      where: 'actif = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Client.fromMap(m)).toList();
  }

  // ----------------------- GET BY ID -----------------------
  Future<Client?> getClientById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Client.fromMap(maps.first);
    }
    return null;
  }

  // ----------------------- UPDATE -----------------------
  Future<int> updateClient(Client client) async {
    final db = await _dbHelper.database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  // ----------------------- DELETE (SOFT DELETE) -----------------------
  Future<int> deleteClient(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'clients',
      {'actif': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------- DELETE (HARD DELETE) -----------------------
  Future<int> deleteClientPermanently(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------- SEARCH -----------------------
  Future<List<Client>> searchClients(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'clients',
      where: 'actif = ? AND (nom LIKE ? OR prenom LIKE ? OR telephone LIKE ?)',
      whereArgs: [1, '%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Client.fromMap(m)).toList();
  }

  // ----------------------- GET VIP -----------------------
  Future<List<Client>> getVipClients() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'clients',
      where: 'is_vip = ? AND actif = ?',
      whereArgs: [1, 1],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Client.fromMap(m)).toList();
  }
}
