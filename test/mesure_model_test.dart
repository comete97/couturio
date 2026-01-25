import 'package:flutter_test/flutter_test.dart';
import 'package:couturio/data/models/mesure.dart';

void main() {
  group('Mesure Model Test', () {
    test('Création mesure avec date automatique', () {
      final mesure = Mesure(
        clientId: 1,
        poitrine: 90,
        taille: 70,
      );

      // Vérifie les valeurs
      expect(mesure.clientId, 1);
      expect(mesure.poitrine, 90);
      expect(mesure.taille, 70);

      // Vérifie que la date est générée automatiquement
      expect(mesure.date, isA<DateTime>());

      // Champs optionnels non fournis doivent être null
      expect(mesure.hanches, null);
      expect(mesure.description, null);
    });

    test('toMap et fromMap fonctionnent correctement', () {
      final mesure = Mesure(
        clientId: 2,
        poitrine: 85,
        taille: 65,
        carrure: 40,
        longueurDos: 45,
        tourCou: 38,
        hanches: 90,
        tourCuisse: 55,
        longueurPantalon: 100,
        longueurBras: 60,
        poignet: 18,
        description: 'Mesure spéciale pour robe',
        notes: 'Prendre en compte la posture',
      );

      final map = mesure.toMap();

      // Vérifie que les valeurs sont correctement converties en Map
      expect(map['client_id'], 2);
      expect(map['poitrine'], 85);
      expect(map['description'], 'Mesure spéciale pour robe');
      expect(map['notes'], 'Prendre en compte la posture');

      // Reconstruction depuis Map
      final newMesure = Mesure.fromMap(map);

      expect(newMesure.clientId, 2);
      expect(newMesure.poitrine, 85);
      expect(newMesure.description, 'Mesure spéciale pour robe');
      expect(newMesure.notes, 'Prendre en compte la posture');
      expect(newMesure.longueurBras, 60);
      expect(newMesure.hanches, 90);
    });

    test('Champs optionnels peuvent rester null', () {
      final mesure = Mesure(clientId: 3);

      // Tous les champs optionnels doivent être null
      expect(mesure.poitrine, null);
      expect(mesure.taille, null);
      expect(mesure.description, null);
      expect(mesure.notes, null);
    });
  });
}
