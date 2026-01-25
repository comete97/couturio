import 'package:couturio/data/models/paiement.dart';
import 'package:couturio/data/repositories/paiement_repository.dart';

class PaiementService {
  final PaiementRepository _repo = PaiementRepository();

  // ------------------- AJOUTER UN PAIEMENT -------------------
  Future<int> ajouterPaiement(Paiement paiement) async {
    return await _repo.insertPaiement(paiement);
  }

  // ------------------- MISE À JOUR -------------------
  Future<int> modifierPaiement(Paiement paiement) async {
    return await _repo.updatePaiement(paiement);
  }

  // ------------------- SUPPRESSION -------------------
  Future<int> supprimerPaiement(int id) async {
    return await _repo.deletePaiement(id);
  }

  // ------------------- TOTAL PAYÉ -------------------
  Future<double> totalPayePourCommande(int commandeId) async {
    return await _repo.totalPayePourCommande(commandeId);
  }

  // ------------------- RESTE À PAYER -------------------
  Future<double> resteAPayer(int commandeId, double prixTotal) async {
    final totalPaye = await totalPayePourCommande(commandeId);
    return prixTotal - totalPaye;
  }

  // ------------------- RÉCUPÉRATION -------------------
  Future<List<Paiement>> getPaiementsByCommande(int commandeId) async {
    return await _repo.getPaiementsByCommande(commandeId);
  }

  Future<List<Paiement>> getPaiementsByClient(int clientId) async {
    return await _repo.getPaiementsByClient(clientId);
  }

  Future<Paiement?> getPaiementById(int id) async {
    return await _repo.getPaiementById(id);
  }

  Future<List<Paiement>> getAllPaiements() async {
    return await _repo.getAllPaiements();
  }

  // ------------------- FILTRES TEMPORELS -------------------
  Future<List<Paiement>> paiementsDuJour() async {
    return await _repo.paiementsDuJour();
  }

  Future<List<Paiement>> paiementsDeLaSemaine() async {
    return await _repo.paiementsDeLaSemaine();
  }

  Future<List<Paiement>> paiementsDuMois() async {
    return await _repo.paiementsDuMois();
  }

  Future<List<Paiement>> paiementsEntreDates(DateTime start, DateTime end) async {
    return await _repo.paiementsEntreDates(start, end);
  }

  // ------------------- STATISTIQUES / RAPPORTS -------------------
  /// Somme totale payée par un client sur toutes ses commandes
  Future<double> totalPayeParClient(int clientId) async {
    final paiements = await _repo.getPaiementsByClient(clientId);
    return paiements.fold<double>(0.0, (sum, p) => sum + p.montant);
  }

  /// Moyenne des paiements par commande
  Future<double> moyennePaiementParCommande(int commandeId) async {
    final paiements = await _repo.getPaiementsByCommande(commandeId);
    if (paiements.isEmpty) return 0.0;
    final total = paiements.fold(0.0, (sum, p) => sum + p.montant);
    return total / paiements.length;
  }

  /// Paiements récents (limit)
  Future<List<Paiement>> paiementsRecents({int limit = 10}) async {
    final allPaiements = await _repo.getAllPaiements();
    return allPaiements.take(limit).toList();
  }
}
