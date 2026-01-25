import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:couturio/data/database/app_database.dart';

void main() {
  // 🔑 OBLIGATOIRE sur Linux pour les tests
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Ouverture de la base de données', () async {
    final db = await AppDatabase().database;
    expect(db.isOpen, true);
  });

  test('Insertion et lecture d’un client', () async {
    final db = await AppDatabase().database;

    await db.delete('clients');

    final id = await db.insert('clients', {
      'nom': 'Doe',
      'prenom': 'John',
      'telephone': '97000000',
      'created_at': DateTime.now().toIso8601String(),
    });

    final result = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );

    expect(result.length, 1);
    expect(result.first['nom'], 'Doe');
  });
}
