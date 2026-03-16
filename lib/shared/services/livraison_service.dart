import 'package:couturio/data/models/livraison.dart';
import 'package:couturio/data/repositories/livraison_repository.dart';
import 'package:couturio/shared/services/commande_service.dart';

import '../../data/models/commande.dart';

class LivraisonService {
  final LivraisonRepository _repository;
  final CommandeService _commandeService;

  LivraisonService(this._repository, this._commandeService);

  // ----------------------- CREATION -----------------------
  Future<int> creerLivraison({
    required int commandeId,
    required TypeLivraison type,
    String? livreur,
    String? instructions,
    String? notes,
  }) async {
    final existantes = await _repository.getLivraisonsByCommande(commandeId);
    if (existantes.isNotEmpty) {
      throw Exception("Une livraison existe déjà pour cette commande.");
    }

    final commande = await _commandeService.getCommandeById(commandeId);
    if (commande == null) {
      throw Exception("Commande introuvable.");
    }

    if (commande.statut != StatutCommande.termine) {
      throw Exception("Seules les commandes terminées peuvent être livrées.");
    }

    final livraison = Livraison(
      commandeId: commandeId,
      type: type,
      statut: StatutLivraison.enCours,
      livreur: livreur,
      instructions: instructions,
      notes: notes,
    );

    return _repository.insertLivraison(livraison);
  }

  // ----------------------- CONFIRMATION -----------------------
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
    await _commandeService.livrerCommande(livraison.commandeId);
  }

  // ----------------------- ANNULATION -----------------------
  Future<void> annulerLivraison(Livraison livraison) async {
    final updated = Livraison(
      id: livraison.id,
      commandeId: livraison.commandeId,
      statut: StatutLivraison.annulee,
      dateLivraisonEffectuee: livraison.dateLivraisonEffectuee,
      livreur: livraison.livreur,
      type: livraison.type,
      rappelEnvoye: livraison.rappelEnvoye,
      confirmeParClient: livraison.confirmeParClient,
      instructions: livraison.instructions,
      notes: livraison.notes,
    );

    await _repository.updateLivraison(updated);
  }

  // ----------------------- ECHEC -----------------------
  Future<void> marquerEchec(Livraison livraison) async {
    final updated = Livraison(
      id: livraison.id,
      commandeId: livraison.commandeId,
      statut: StatutLivraison.echec,
      dateLivraisonEffectuee: livraison.dateLivraisonEffectuee,
      livreur: livraison.livreur,
      type: livraison.type,
      rappelEnvoye: livraison.rappelEnvoye,
      confirmeParClient: livraison.confirmeParClient,
      instructions: livraison.instructions,
      notes: livraison.notes,
    );

    await _repository.updateLivraison(updated);
  }

  // ----------------------- UPDATE -----------------------
  Future<int> updateLivraison(Livraison livraison) {
    return _repository.updateLivraison(livraison);
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

  // ----------------------- REGLES UI -----------------------
  bool peutConfirmer(Livraison livraison) {
    return livraison.statut == StatutLivraison.enCours;
  }

  bool peutAnnuler(Livraison livraison) {
    return livraison.statut == StatutLivraison.enCours;
  }

  bool peutMarquerEchec(Livraison livraison) {
    return livraison.statut == StatutLivraison.enCours;
  }

  bool peutSupprimer(Livraison livraison) {
    return livraison.statut == StatutLivraison.annulee ||
        livraison.statut == StatutLivraison.echec;
  }
}