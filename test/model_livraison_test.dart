import 'package:flutter_test/flutter_test.dart';
import 'package:couturio/data/models/livraison.dart';

void main() {
  group('Livraison Model Tests', () {
    test('Création d\'une instance', () {
      final livraison = Livraison(
        id: 1,
        commandeId: 100,
        dateLivraisonEffectuee: DateTime(2026, 1, 25),
        statut: StatutLivraison.enCours,
        livreur: 'Jean',
        type: TypeLivraison.express,
        rappelEnvoye: true,
        confirmeParClient: false,
        instructions: 'Ne pas plier le tissu',
        notes: 'Appeler avant livraison',
      );

      expect(livraison.id, 1);
      expect(livraison.commandeId, 100);
      expect(livraison.dateLivraisonEffectuee, DateTime(2026, 1, 25));
      expect(livraison.statut, StatutLivraison.enCours);
      expect(livraison.livreur, 'Jean');
      expect(livraison.type, TypeLivraison.express);
      expect(livraison.rappelEnvoye, true);
      expect(livraison.confirmeParClient, false);
      expect(livraison.instructions, 'Ne pas plier le tissu');
      expect(livraison.notes, 'Appeler avant livraison');
    });

    test('Conversion toMap et fromMap fonctionne correctement', () {
      final livraison = Livraison(
        id: 2,
        commandeId: 200,
        dateLivraisonEffectuee: DateTime(2026, 2, 1),
        statut: StatutLivraison.livree,
        livreur: 'Marie',
        type: TypeLivraison.standard,
        rappelEnvoye: false,
        confirmeParClient: true,
        instructions: 'Livrer après 15h',
        notes: 'Confirmer réception',
      );

      final map = livraison.toMap();
      final livraisonFromMap = Livraison.fromMap(map);

      expect(livraisonFromMap.id, livraison.id);
      expect(livraisonFromMap.commandeId, livraison.commandeId);
      expect(livraisonFromMap.dateLivraisonEffectuee, livraison.dateLivraisonEffectuee);
      expect(livraisonFromMap.statut, livraison.statut);
      expect(livraisonFromMap.livreur, livraison.livreur);
      expect(livraisonFromMap.type, livraison.type);
      expect(livraisonFromMap.rappelEnvoye, livraison.rappelEnvoye);
      expect(livraisonFromMap.confirmeParClient, livraison.confirmeParClient);
      expect(livraisonFromMap.instructions, livraison.instructions);
      expect(livraisonFromMap.notes, livraison.notes);
    });
  });
}
