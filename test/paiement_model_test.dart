import 'package:flutter_test/flutter_test.dart';
import 'package:couturio/data/models/paiement.dart';

void main() {
  group('Paiement Model Test', () {
    test('Création paiement avec date automatique', () {
      final paiement = Paiement(
      
        commandeId: 101,
        montant: 2000,
      );

      
      expect(paiement.commandeId, 101);
      expect(paiement.montant, 2000);
      expect(paiement.datePaiement, isA<DateTime>());
      expect(paiement.notes, null);
    });

    test('toMap et fromMap fonctionnent correctement', () {
      final paiement = Paiement(
        
        commandeId: 102,
        montant: 3500,
        notes: 'Avance sur chemise',
      );

      final map = paiement.toMap();
      expect(map['client_id'], 2);
      expect(map['commande_id'], 102);
      expect(map['montant'], 3500);
      expect(map['notes'], 'Avance sur chemise');

      final newPaiement = Paiement.fromMap(map);
      
      expect(newPaiement.commandeId, 102);
      expect(newPaiement.montant, 3500);
      expect(newPaiement.notes, 'Avance sur chemise');
      expect(newPaiement.datePaiement, isA<DateTime>());
    });

    test('Champs optionnels peuvent rester null', () {
      final paiement = Paiement(commandeId: 103, montant: 1000);
      expect(paiement.notes, null);
    });
  });
}
