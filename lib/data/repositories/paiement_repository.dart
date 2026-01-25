import 'package:couturio/data/database/app_database.dart';
import 'package:couturio/data/models/paiement.dart';
import 'package:sqflite/sqflite.dart';

class PaiementRepository {
  final AppDatabase _dbHelper = AppDatabase();

  // ----------------------- INSERT -----------------------
  Future<int> insertPaiement(Paiement paiement) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'paiements',
      paiement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------- GET ALL -----------------------
  Future<List<Paiement>> getAllPaiements() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'paiements',
      orderBy: 'date_paiement DESC',
    );
    return maps.map((m) => Paiement.fromMap(m)).toList();
  }

  // ----------------------- GET BY ID -----------------------
  Future<Paiement?> getPaiementById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'paiements',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Paiement.fromMap(maps.first);
    return null;
  }

  // ----------------------- GET BY COMMANDE -----------------------
  Future<List<Paiement>> getPaiementsByCommande(int commandeId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'paiements',
      where: 'commande_id = ?',
      whereArgs: [commandeId],
      orderBy: 'date_paiement DESC',
    );
    return maps.map((m) => Paiement.fromMap(m)).toList();
  }

  // ----------------------- GET BY CLIENT -----------------------
  Future<List<Paiement>> getPaiementsByClient(int clientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'paiements',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date_paiement DESC',
    );
    return maps.map((m) => Paiement.fromMap(m)).toList();
  }

  // ----------------------- UPDATE -----------------------
  Future<int> updatePaiement(Paiement paiement) async {
    final db = await _dbHelper.database;
    return await db.update(
      'paiements',
      paiement.toMap(),
      where: 'id = ?',
      whereArgs: [paiement.id],
    );
  }

  // ----------------------- DELETE -----------------------
  Future<int> deletePaiement(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'paiements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------- TOTAL PAYÉ POUR UNE COMMANDE -----------------------
  Future<double> totalPayePourCommande(int commandeId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(montant) as total FROM paiements WHERE commande_id = ?',
      [commandeId],
    );
    return result.first['total'] != null ? (result.first['total'] as num).toDouble() : 0.0;
  }

  // ----------------------- FILTRES TEMPORELLES -----------------------

  Future<List<Paiement>> paiementsDuJour() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final maps = await db.query(
      'paiements',
      where: "date(date_paiement) = date(?)",
      whereArgs: [today.toIso8601String()],
      orderBy: 'date_paiement DESC',
    );
    return maps.map((m) => Paiement.fromMap(m)).toList();
  }

  Future<List<Paiement>> paiementsDeLaSemaine() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    final maps = await db.query(
      'paiements',
      where: "date(date_paiement) BETWEEN date(?) AND date(?)",
      whereArgs: [startOfWeek.toIso8601String(), endOfWeek.toIso8601String()],
      orderBy: 'date_paiement DESC',
    );
    return maps.map((m) => Paiement.fromMap(m)).toList();
  }

  Future<List<Paiement>> paiementsDuMois() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final maps = await db.query(
      'paiements',
      where: "strftime('%Y-%m', date_paiement) = ?",
      whereArgs: ['${now.year}-${now.month.toString().padLeft(2, '0')}'],
      orderBy: 'date_paiement DESC',
    );
    return maps.map((m) => Paiement.fromMap(m)).toList();
  }

  Future<List<Paiement>> paiementsEntreDates(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'paiements',
      where: "date(date_paiement) BETWEEN date(?) AND date(?)",
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date_paiement DESC',
    );
    return maps.map((m) => Paiement.fromMap(m)).toList();
  }
}
