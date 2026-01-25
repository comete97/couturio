import 'package:couturio/data/database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class DashboardRepository {
  final AppDatabase _dbHelper = AppDatabase();

  Future<Database> get _db async => await _dbHelper.database;

  // ----------------------- CLIENTS -----------------------
  Future<int> totalClients() async {
    final db = await _db;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as total FROM clients WHERE actif = 1');
    return result.first['total'] as int;
  }

  Future<int> totalVipClients() async {
    final db = await _db;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as total FROM clients WHERE actif = 1 AND is_vip = 1');
    return result.first['total'] as int;
  }

  // ----------------------- COMMANDES -----------------------
  Future<int> totalCommandes() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM commandes');
    return result.first['total'] as int;
  }

  Future<int> commandesParStatut(String statut) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM commandes WHERE statut = ?',
      [statut],
    );
    return result.first['total'] as int;
  }

  Future<int> commandesDuJour() async {
    final db = await _db;
    final today = DateTime.now();
    final result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM commandes WHERE date(date_creation) = date(?)",
      [today.toIso8601String()],
    );
    return result.first['total'] as int;
  }

  Future<int> commandesCetteSemaine() async {
    final db = await _db;
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)).toIso8601String();
    final result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM commandes WHERE date(date_creation) >= date(?)",
      [startOfWeek],
    );
    return result.first['total'] as int;
  }

  Future<int> commandesCeMois() async {
    final db = await _db;
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM commandes WHERE strftime('%Y-%m', date_creation) = ?",
      [yearMonth],
    );
    return result.first['total'] as int;
  }

  Future<int> commandesEnRetard() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM commandes WHERE statut != 'livre' AND date_livraison_prevue < ?",
      [now],
    );
    return result.first['total'] as int;
  }

  // ----------------------- PAIEMENTS -----------------------
  Future<double> totalPaiements() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT SUM(montant) as total FROM paiements');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> paiementsDuJour() async {
    final db = await _db;
    final today = DateTime.now();
    final result = await db.rawQuery(
      "SELECT SUM(montant) as total FROM paiements WHERE date(date_paiement) = date(?)",
      [today.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> paiementsCetteSemaine() async {
    final db = await _db;
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)).toIso8601String();
    final result = await db.rawQuery(
      "SELECT SUM(montant) as total FROM paiements WHERE date(date_paiement) >= date(?)",
      [startOfWeek],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> paiementsCeMois() async {
    final db = await _db;
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final result = await db.rawQuery(
      "SELECT SUM(montant) as total FROM paiements WHERE strftime('%Y-%m', date_paiement) = ?",
      [yearMonth],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ----------------------- LIVRAISONS -----------------------
  Future<int> livraisonsDuJour() async {
    final db = await _db;
    final today = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM livraisons WHERE date(date_livraison_effectuee) = date(?)",
      [today],
    );
    return result.first['total'] as int;
  }

  Future<int> livraisonsEnRetard() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM livraisons WHERE statut != 'livree' AND date_livraison_effectuee < ?",
      [now],
    );
    return result.first['total'] as int;
  }
}
