import 'package:flutter_test/flutter_test.dart';
import 'package:couturio/data/models/client.dart';

void main() {
  group('Client Model Test', () {
    test('Création client et date automatique', () {
      final client = Client(
        nom: 'Alice',
        prenom: 'Brunet',
        telephone: '12345678',
      );

      // Vérifie que le nom et téléphone sont corrects
      expect(client.nom, 'Alice');
      expect(client.prenom, 'Brunet');
      expect(client.telephone, '12345678');

      // Vérifie que la date est générée automatiquement
      expect(client.createdAt, isA<DateTime>());
    });

    test('toMap et fromMap fonctionnent', () {
      final client = Client(
        nom: 'Bob',
        prenom: 'Smith',
        telephone: '87654321',
        adresse: 'Rue des Fleurs',
        isVip: true,
      );

      final map = client.toMap();

      // Vérifie que la map contient les clés attendues
      expect(map['nom'], 'Bob');
      expect(map['adresse'], 'Rue des Fleurs');
      expect(map['is_vip'], 1);

      // Convertit la map en objet
      final newClient = Client.fromMap(map);

      expect(newClient.nom, 'Bob');
      expect(newClient.adresse, 'Rue des Fleurs');
      expect(newClient.isVip, true);
    });
  });
}
