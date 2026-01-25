//import 'dart:convert';
import 'package:couturio/data/database/app_database.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/data/models/paiement.dart';
import 'package:sqflite/sqflite.dart';

class CommandeRepository {
  final AppDatabase _dbHelper = AppDatabase();
  // ----------------------- INSERT -----------------------
  Future<int> insertCommande(Commande commande) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'commandes',
      commande.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------- GET ALL -----------------------
  Future<List<Commande>> getAllCommandes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'commandes',
      orderBy: 'date_creation DESC',
    );
    return maps.map((m) => Commande.fromMap(m)).toList();
  }

  // ----------------------- GET BY ID -----------------------
  Future<Commande?> getCommandeById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'commandes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Commande.fromMap(maps.first);
    return null;
  }

  // ----------------------- GET BY CLIENT -----------------------
  Future<List<Commande>> getCommandesByClient(int clientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'commandes',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date_creation DESC',
    );
    return maps.map((m) => Commande.fromMap(m)).toList();
  }

  // ----------------------- UPDATE -----------------------
  Future<int> updateCommande(Commande commande) async {
    final db = await _dbHelper.database;
    return await db.update(
      'commandes',
      commande.toMap(),
      where: 'id = ?',
      whereArgs: [commande.id],
    );
  }

  // ----------------------- DELETE -----------------------
  Future<int> deleteCommande(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'commandes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------- GET COMMANDES EN RETARD -----------------------
  Future<List<Commande>> getCommandesEnRetard() async {
    final db = await _dbHelper.database;
    final nowIso = DateTime.now().toIso8601String();
    final maps = await db.query(
      'commandes',
      where: 'date_livraison_prevue IS NOT NULL AND date_livraison IS NULL AND date_livraison_prevue < ?',
      whereArgs: [nowIso],
      orderBy: 'date_livraison_prevue ASC',
    );
    return maps.map((m) => Commande.fromMap(m)).toList();
  }

  // ----------------------- GET COMMANDES TERMINEES -----------------------
  Future<List<Commande>> getCommandesTerminees() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'commandes',
      where: 'statut = ?',
      whereArgs: ['termine'],
      orderBy: 'date_livraison DESC',
    );
    return maps.map((m) => Commande.fromMap(m)).toList();
  }

  // ----------------------- AJOUTER UN PAIEMENT -----------------------
  Future<int> addPaiement(Paiement paiement) async {
    final db = await _dbHelper.database;
    final commande = await getCommandeById(paiement.commandeId);
    if (commande != null) {
      commande.paiements.add(paiement);
      await updateCommande(commande);
    }
    return await db.insert(
      'paiements',
      paiement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------- GET PAIEMENTS D’UNE COMMANDE -----------------------
  Future<List<Paiement>> getPaiementsByCommande(int commandeId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'paiements',
      where: 'commande_id = ?',
      whereArgs: [commandeId],
      orderBy: 'date_paiement ASC',
    );
    return maps.map((m) => Paiement.fromMap(m)).toList();
  }

  // ----------------------- FILTRES TEMPORRIELS -----------------------
  Future<List<Commande>> getCommandesDuJour() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startIso = DateTime(today.year, today.month, today.day).toIso8601String();
    final endIso = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    final maps = await db.query(
      'commandes',
      where: 'date_creation BETWEEN ? AND ?',
      whereArgs: [startIso, endIso],
      orderBy: 'date_creation DESC',
    );
    return maps.map((m) => Commande.fromMap(m)).toList();
  }

  Future<List<Commande>> getCommandesDeLaSemaine() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final firstDay = today.subtract(Duration(days: today.weekday - 1));
    final lastDay = firstDay.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    final maps = await db.query(
      'commandes',
      where: 'date_creation BETWEEN ? AND ?',
      whereArgs: [firstDay.toIso8601String(), lastDay.toIso8601String()],
      orderBy: 'date_creation DESC',
    );
    return maps.map((m) => Commande.fromMap(m)).toList();
  }

  Future<List<Commande>> getCommandesDuMois() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startMonth = DateTime(today.year, today.month, 1);
    final endMonth = DateTime(today.year, today.month + 1, 0, 23, 59, 59);
    final maps = await db.query(
      'commandes',
      where: 'date_creation BETWEEN ? AND ?',
      whereArgs: [startMonth.toIso8601String(), endMonth.toIso8601String()],
      orderBy: 'date_creation DESC',
    );
    return maps.map((m) => Commande.fromMap(m)).toList();
  }

  // ------------------------- AUTRES METHODES UTILES -----------------------
  Future<List<Commande>> getCommandesSince(DateTime date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'commandes',
      where: 'date_creation >= ?',
      whereArgs: [date.toIso8601String()],
      orderBy: 'date_creation DESC',
    );
    return maps.map((m) => Commande.fromMap(m)).toList();
  }

  Future<List<int>> getAllClientsWithCommande() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('SELECT DISTINCT client_id FROM commandes');
    return maps.map((m) => m['client_id'] as int).toList();
  }
  Future<int> updateStatut(int commandeId, StatutCommande statut, {DateTime? dateLivraison}) async {
    final db = await _dbHelper.database;
    final Map<String, dynamic> updates = {'statut': statut.name};
    if (dateLivraison != null) {
      updates['date_livraison'] = dateLivraison.toIso8601String();
    }
    return await db.update(
      'commandes',
      updates,
      where: 'id = ?',
      whereArgs: [commandeId],
    );
  }

}