import 'package:couturio/data/models/commande.dart';
import 'package:couturio/data/repositories/commande_repository.dart';
import 'package:couturio/shared/services/livraison_service.dart';

class CommandeService {
  final CommandeRepository _repo;
  //final LivraisonService _livraisonService;

  CommandeService(this._repo/*, this._livraisonService*/);

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
      statut: StatutCommande.enAttente,
    );

    return _repo.insertCommande(cmd);
  }

  // ------------------- LECTURE -------------------
  Future<List<Commande>> getAllCommandes() {
    return _repo.getAllCommandes();
  }

  Future<Commande?> getCommandeById(int id) {
    return _repo.getCommandeById(id);
  }

  Future<List<Commande>> getCommandesByClient(int clientId) {
    return _repo.getCommandesByClient(clientId);
  }

  // ------------------- MODIFICATION -------------------
  Future<int> updateCommande(Commande commande) {
    return _repo.updateCommande(commande);
  }

  Future<int> supprimerCommande(int id) {
    return _repo.deleteCommande(id);
  }

  // ------------------- STATUT -------------------
  Future<void> demarrerCommande(int commandeId) {
    return _repo.updateStatut(commandeId, StatutCommande.enCours);
  }

  Future<void> terminerCommande(int commandeId) {
    return _repo.updateStatut(commandeId, StatutCommande.termine);
  }

  Future<void> annulerCommande(int commandeId) {
    return _repo.updateStatut(commandeId, StatutCommande.annulee);
  }

  // ------------------- REGLES DE TRANSITION -------------------
  bool canStart(Commande commande) {
    return commande.statut == StatutCommande.enAttente;
  }

  bool canFinish(Commande commande) {
    return commande.statut == StatutCommande.enCours;
  }

  bool canDeliver(Commande commande) {
    return commande.statut == StatutCommande.termine;
  }

  bool canCancel(Commande commande) {
    return commande.statut == StatutCommande.enAttente ||
        commande.statut == StatutCommande.enCours;
  }
  bool canEdit(Commande commande) {
    return commande.statut == StatutCommande.enAttente ||
        commande.statut == StatutCommande.enCours;
  }
  bool canDelete(Commande commande) {
    return commande.statut == StatutCommande.enAttente ||
        commande.statut == StatutCommande.annulee;
  }

  // ---------------- LIVRAISON ----------------
  Future<void> livrerCommande(int commandeId) async {
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
    if (commande.statut == StatutCommande.livre ||
        commande.statut == StatutCommande.annulee) {
      return false;
    }

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