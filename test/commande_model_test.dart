import 'package:flutter_test/flutter_test.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/data/models/paiement.dart';

void main() {
  group('Commande Model Tests with JSON Paiements', () {
    
    test('toMap/fromMap avec JSON fonctionne', () {
      final paiement1 = Paiement(commandeId: 1, montant: 1500);
      final paiement2 = Paiement(commandeId: 1, montant: 1000);

      final commande = Commande(
        clientId: 1,
        prixTotal: 5000,
        modele: 'Robe soirée',
        description: 'Robe rouge satin',
        paiements: [paiement1, paiement2],
      );

      // Conversion en Map (paiements sérialisés en JSON)
      final map = commande.toMap();
      expect(map['paiements'], isA<String>()); // JSON string

      // Reconstruction depuis Map
      final newCommande = Commande.fromMap(map);

      expect(newCommande.clientId, 1);
      expect(newCommande.modele, 'Robe soirée');
      expect(newCommande.description, 'Robe rouge satin');
      expect(newCommande.paiements.length, 2);
      expect(newCommande.resteAPayer, 2500); // 5000 - (1500+1000)
    });

    test('Commande avec statut et date livraison', () {
      final now = DateTime.now();
      final livraison = now.add(Duration(days: 5));

      final commande = Commande(
        clientId: 2,
        prixTotal: 3000,
        statut: StatutCommande.enCours,
        dateLivraisonPrevue: livraison,
      );

      final map = commande.toMap();
      final newCommande = Commande.fromMap(map);

      expect(newCommande.statut, StatutCommande.enCours);
      expect(newCommande.dateLivraisonPrevue, livraison);
      expect(newCommande.resteAPayer, 3000);
    });
  });
}
