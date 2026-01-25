import 'package:couturio/data/models/livraison.dart';
import 'package:couturio/data/repositories/livraison_repository.dart';

class LivraisonService {
  final LivraisonRepository _repository = LivraisonRepository();

  // ----------------------- CREATION -----------------------
  Future<int> creerLivraison({
    required int commandeId,
    TypeLivraison type = TypeLivraison.standard,
    String? livreur,
    String? instructions,
    String? notes,
  }) {
    final livraison = Livraison(
      commandeId: commandeId,
      type: type,
      livreur: livreur,
      instructions: instructions,
      notes: notes,
    );

    return _repository.insertLivraison(livraison);
  }

  // ----------------------- CONFIRMATION DE LIVRAISON -----------------------
  Future<void> confirmerLivraison(Livraison livraison) async {
    final updated = Livraison(
      id: livraison.id,
      commandeId: livraison.commandeId,
      statut: StatutLivraison.livree,
      dateLivraisonEffectuee: DateTime.now(),
      livreur: livraison.livreur,
      type: livraison.type,
      rappelEnvoye: livraison.rappelEnvoye,
      confirmeParClient: true,
      instructions: livraison.instructions,
      notes: livraison.notes,
    );

    await _repository.updateLivraison(updated);
  }

  // ----------------------- RAPPEL -----------------------
  Future<void> marquerRappelEnvoye(Livraison livraison) async {
    final updated = Livraison(
      id: livraison.id,
      commandeId: livraison.commandeId,
      statut: livraison.statut,
      dateLivraisonEffectuee: livraison.dateLivraisonEffectuee,
      livreur: livraison.livreur,
      type: livraison.type,
      rappelEnvoye: true,
      confirmeParClient: livraison.confirmeParClient,
      instructions: livraison.instructions,
      notes: livraison.notes,
    );

    await _repository.updateLivraison(updated);
  }

  // ----------------------- LECTURE -----------------------
  Future<List<Livraison>> getToutesLesLivraisons() {
    return _repository.getAllLivraisons();
  }

  Future<Livraison?> getLivraisonById(int id) {
    return _repository.getLivraisonById(id);
  }

  Future<List<Livraison>> getLivraisonsParCommande(int commandeId) {
    return _repository.getLivraisonsByCommande(commandeId);
  }

  // ----------------------- FILTRES -----------------------
  Future<List<Livraison>> getLivraisonsEnCours() {
    return _repository.getLivraisonsEnCours();
  }

  Future<List<Livraison>> getLivraisonsLivrees() {
    return _repository.getLivraisonsLivrees();
  }

  Future<List<Livraison>> getLivraisonsParType(TypeLivraison type) {
    return _repository.getLivraisonsByType(type);
  }

  // ----------------------- SUPPRESSION -----------------------
  Future<void> supprimerLivraison(int id) {
    return _repository.deleteLivraison(id);
  }
}
