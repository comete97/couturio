import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'couturio.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // --------------------- Table Clients ---------------------
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        telephone TEXT NOT NULL,
        email TEXT,
        adresse TEXT,
        sexe TEXT,
        photo TEXT,
        notes TEXT,
        is_vip INTEGER NOT NULL DEFAULT 0,
        actif INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        last_commande_at TEXT
      )
    ''');

    // --------------------- Table Mesures ---------------------
    await db.execute('''
      CREATE TABLE mesures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        poitrine REAL,
        taille REAL,
        carrure REAL,
        longueur_dos REAL,
        tour_cou REAL,
        tour_taille_haute REAL,
        hanches REAL,
        tour_cuisse REAL,
        longueur_pantalon REAL,
        tour_taille_basse REAL,
        tour_genou REAL,
        tour_cheville REAL,
        entrejambe REAL,
        longueur_bras REAL,
        tour_bras REAL,
        poignet REAL,
        tour_avant_bras REAL,
        longueur_epaule_bras REAL,
        longueur_dos_bras REAL,
        longueur_maniere REAL,
        tous_biceps REAL,
        tous_epaules REAL,
        longueur_avant_bras REAL,
        description TEXT,
        notes TEXT,
        date TEXT,
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');

    // --------------------- Table Commandes ---------------------
    await db.execute('''
      CREATE TABLE commandes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        mesure_id INTEGER,
        modele TEXT,
        description TEXT,
        photo_modele TEXT,
        statut TEXT NOT NULL DEFAULT 'enAttente',
        date_creation TEXT NOT NULL,
        date_livraison_prevue TEXT,
        date_livraison TEXT,
        prix_total REAL NOT NULL,
        notes TEXT,
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY(mesure_id) REFERENCES mesures(id)
      )
    ''');

    // --------------------- Table Paiements ---------------------
    await db.execute('''
      CREATE TABLE paiements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commande_id INTEGER NOT NULL,
        montant REAL NOT NULL,
        date_paiement TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY(commande_id) REFERENCES commandes(id) ON DELETE CASCADE
      )
    ''');

    // --------------------- Table Livraisons ---------------------
    await db.execute('''
      CREATE TABLE livraisons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commande_id INTEGER NOT NULL,
        date_livraison_effectuee TEXT,
        statut TEXT NOT NULL DEFAULT 'enCours',
        livreur TEXT,
        type TEXT NOT NULL DEFAULT 'standard',
        rappel_envoye INTEGER NOT NULL DEFAULT 0,
        confirme_par_client INTEGER NOT NULL DEFAULT 0,
        instructions TEXT,
        notes TEXT,
        FOREIGN KEY(commande_id) REFERENCES commandes(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<Database> openTestDatabase() async {
    return await openDatabase(
      ':memory:', // Base temporaire en RAM
      version: 1,
      onCreate: (db, version) async {
        // On crée toutes les tables comme dans _onCreate
        await db.execute('''
          CREATE TABLE clients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            telephone TEXT NOT NULL,
            email TEXT,
            adresse TEXT,
            sexe TEXT,
            photo TEXT,
            notes TEXT,
            is_vip INTEGER NOT NULL DEFAULT 0,
            actif INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL,
            last_commande_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE commandes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER NOT NULL,
            mesure_id INTEGER,
            modele TEXT,
            description TEXT,
            photo_modele TEXT,
            statut TEXT NOT NULL DEFAULT 'enAttente',
            date_creation TEXT NOT NULL,
            date_livraison_prevue TEXT,
            date_livraison TEXT,
            prix_total REAL NOT NULL,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE paiements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            commande_id INTEGER NOT NULL,
            client_id INTEGER,
            montant REAL NOT NULL,
            date_paiement TEXT NOT NULL,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE livraisons (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            commande_id INTEGER NOT NULL,
            date_livraison_effectuee TEXT,
            statut TEXT NOT NULL DEFAULT 'enCours',
            livreur TEXT,
            type TEXT NOT NULL DEFAULT 'standard',
            rappel_envoye INTEGER NOT NULL DEFAULT 0,
            confirme_par_client INTEGER NOT NULL DEFAULT 0,
            instructions TEXT,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE mesures (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER,
            poitrine REAL,
            taille REAL,
            carrure REAL,
            longueur_dos REAL,
            tour_cou REAL,
            tour_taille_haute REAL,
            hanches REAL,
            tour_cuisse REAL,
            longueur_pantalon REAL,
            tour_taille_basse REAL,
            tour_genou REAL,
            tour_cheville REAL,
            entrejambe REAL,
            longueur_bras REAL,
            tour_bras REAL,
            poignet REAL,
            tour_avant_bras REAL,
            longueur_epaule_bras REAL,
            longueur_dos_bras REAL,
            longueur_maniere REAL,
            tous_biceps REAL,
            tous_epaules REAL,
            longueur_avant_bras REAL,
            description TEXT,
            notes TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

}
