import 'package:couturio/data/models/commande.dart';
import 'package:couturio/data/repositories/commande_repository.dart';
import 'package:couturio/shared/services/livraison_service.dart';

class CommandeService {
  final CommandeRepository _repo;
  final LivraisonService _livraisonService;

  CommandeService(this._repo, this._livraisonService);
  // ------------------- CREATION -------------------
  Future<int> creerCommande(Commande commande) async {
    // Règle métier : une commande commence toujours en attente
    final cmd = Commande(
      clientId: commande.clientId,
      mesureId: commande.mesureId,
      modele: commande.modele,
      description: commande.description,
      photoModele: commande.photoModele,
      prixTotal: commande.prixTotal,
      notes: commande.notes,
      dateLivraisonPrevue: commande.dateLivraisonPrevue,
    );

    return _repo.insertCommande(cmd);
  }

  // ------------------- STATUT -------------------
  Future<void> demarrerCommande(int commandeId) {
    return _repo.updateStatut(commandeId, StatutCommande.enCours);
  }

  Future<void> terminerCommande(int commandeId) {
    return _repo.updateStatut(commandeId, StatutCommande.termine);
  }

  // ---------------- LIVRAISON ----------------
  Future<void> livrerCommande({
    required int commandeId,
    required int livraisonId,
  }) async {
    // 1. Récupérer la livraison
    final livraison = await _livraisonService.getLivraisonById(livraisonId);
    if (livraison == null) {
      throw Exception("Livraison introuvable pour l'ID $livraisonId");
    }

    // 2. Marquer la livraison comme livrée
    await _livraisonService.confirmerLivraison(livraison);

    // 3. Mettre à jour le statut de la commande
    await _repo.updateStatut(
      commandeId,
      StatutCommande.livre,
      dateLivraison: DateTime.now(),
    );
  }


  // ------------------- FINANCE -------------------
  double resteAPayer(Commande commande) {
    return commande.resteAPayer;
  }

  bool estSoldee(Commande commande) {
    return commande.resteAPayer <= 0;
  }

  // ------------------- RETARD -------------------
  bool estEnRetard(Commande commande) {
    if (commande.dateLivraisonPrevue == null) return false;
    if (commande.dateLivraison != null) return false;

    return DateTime.now().isAfter(commande.dateLivraisonPrevue!);
  }

  Future<List<Commande>> commandesEnRetard() {
    return _repo.getCommandesEnRetard();
  }

  // ------------------- TEMPOREL -------------------
  Future<List<Commande>> commandesDuJour() {
    return _repo.getCommandesDuJour();
  }

  Future<List<Commande>> commandesDeLaSemaine() {
    return _repo.getCommandesDeLaSemaine();
  }

  Future<List<Commande>> commandesDuMois() {
    return _repo.getCommandesDuMois();
  }
}
