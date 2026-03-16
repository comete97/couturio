import 'package:couturio/data/repositories/dashboard_repository.dart';

class DashboardService {
  final DashboardRepository _repo;

  DashboardService(this._repo);

  Future<int> totalClients() => _repo.totalClients();
  Future<int> totalVipClients() => _repo.totalVipClients();

  Future<int> totalCommandes() => _repo.totalCommandes();
  Future<int> commandesDuJour() => _repo.commandesDuJour();
  Future<int> commandesCetteSemaine() => _repo.commandesCetteSemaine();
  Future<int> commandesCeMois() => _repo.commandesCeMois();
  Future<int> commandesEnRetard() => _repo.commandesEnRetard();

  Future<double> totalPaiements() => _repo.totalPaiements();
  Future<double> paiementsDuJour() => _repo.paiementsDuJour();
  Future<double> paiementsCetteSemaine() => _repo.paiementsCetteSemaine();
  Future<double> paiementsCeMois() => _repo.paiementsCeMois();

  Future<int> livraisonsDuJour() => _repo.livraisonsDuJour();
  Future<int> livraisonsEnRetard() => _repo.livraisonsEnRetard();
}