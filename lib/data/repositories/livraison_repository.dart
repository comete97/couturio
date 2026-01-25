import 'package:couturio/data/database/app_database.dart';
import 'package:couturio/data/models/livraison.dart';
import 'package:sqflite/sqflite.dart';

class LivraisonRepository {
  final AppDatabase _dbHelper = AppDatabase();

  // ----------------------- INSERT -----------------------
  Future<int> insertLivraison(Livraison livraison) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'livraisons',
      livraison.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------- GET ALL -----------------------
  Future<List<Livraison>> getAllLivraisons() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'livraisons',
      orderBy: 'id DESC',
    );
    return maps.map((m) => Livraison.fromMap(m)).toList();
  }

  // ----------------------- GET BY ID -----------------------
  Future<Livraison?> getLivraisonById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'livraisons',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Livraison.fromMap(maps.first);
    return null;
  }

  // ----------------------- GET BY COMMANDE -----------------------
  Future<List<Livraison>> getLivraisonsByCommande(int commandeId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'livraisons',
      where: 'commande_id = ?',
      whereArgs: [commandeId],
      orderBy: 'id DESC',
    );
    return maps.map((m) => Livraison.fromMap(m)).toList();
  }

  // ----------------------- UPDATE -----------------------
  Future<int> updateLivraison(Livraison livraison) async {
    final db = await _dbHelper.database;
    return await db.update(
      'livraisons',
      livraison.toMap(),
      where: 'id = ?',
      whereArgs: [livraison.id],
    );
  }

  // ----------------------- DELETE -----------------------
  Future<int> deleteLivraison(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'livraisons',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------- FILTRAGE -----------------------
  Future<List<Livraison>> getLivraisonsEnCours() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'livraisons',
      where: 'statut = ?',
      whereArgs: ['enCours'],
      orderBy: 'id DESC',
    );
    return maps.map((m) => Livraison.fromMap(m)).toList();
  }

  Future<List<Livraison>> getLivraisonsLivrees() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'livraisons',
      where: 'statut = ?',
      whereArgs: ['livree'],
      orderBy: 'id DESC',
    );
    return maps.map((m) => Livraison.fromMap(m)).toList();
  }

  Future<List<Livraison>> getLivraisonsByType(TypeLivraison type) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'livraisons',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'id DESC',
    );
    return maps.map((m) => Livraison.fromMap(m)).toList();
  }
}
