import 'package:couturio/data/models/client.dart';
import 'package:couturio/data/repositories/client_repository.dart';
import 'package:couturio/data/repositories/commande_repository.dart';

class ClientService {
  final ClientRepository _clientRepo;
  final CommandeRepository _commandeRepo;

  ClientService(this._clientRepo, this._commandeRepo);

  // ----------------------- CRUD de base -----------------------
  Future<int> addClient(Client client) async {
    return await _clientRepo.insertClient(client);
  }

  Future<List<Client>> getAllClients() async {
    return await _clientRepo.getAllClients();
  }

  Future<Client?> getClientById(int id) async {
    return await _clientRepo.getClientById(id);
  }

  Future<int> updateClient(Client client) async {
    return await _clientRepo.updateClient(client);
  }

  Future<int> deleteClient(int id) async {
    return await _clientRepo.deleteClient(id);
  }

  Future<int> deleteClientPermanently(int id) async {
    return await _clientRepo.deleteClientPermanently(id);
  }

  // ----------------------- Recherche -----------------------
  Future<List<Client>> searchClients(String query) async {
    return await _clientRepo.searchClients(query);
  }

  // ----------------------- VIP -----------------------
  Future<List<Client>> getVipClients() async {
    return await _clientRepo.getVipClients();
  }

  Future<List<Client>> getNonVipClients() async {
    final all = await _clientRepo.getAllClients();
    final vips = await _clientRepo.getVipClients();
    return all.where((c) => !vips.contains(c)).toList();
  }

  Future<double> getPercentageVip() async {
    final all = await _clientRepo.getAllClients();
    final vips = await _clientRepo.getVipClients();
    if (all.isEmpty) return 0;
    return (vips.length / all.length) * 100;
  }

  Future<void> toggleVipStatus(int clientId) async {
    final client = await _clientRepo.getClientById(clientId);
    if (client != null) {
      final updated = Client(
        id: client.id,
        nom: client.nom,
        prenom: client.prenom,
        telephone: client.telephone,
        email: client.email,
        adresse: client.adresse,
        sexe: client.sexe,
        photo: client.photo,
        notes: client.notes,
        isVip: !client.isVip,
        actif: client.actif,
        createdAt: client.createdAt,
        lastCommandeAt: client.lastCommandeAt,
      );
      await _clientRepo.updateClient(updated);
    }
  }

  // ----------------------- Gestion des notes -----------------------
  Future<void> addNoteToClient(int clientId, String note) async {
    final client = await _clientRepo.getClientById(clientId);
    if (client != null) {
      final updated = Client(
        id: client.id,
        nom: client.nom,
        prenom: client.prenom,
        telephone: client.telephone,
        email: client.email,
        adresse: client.adresse,
        sexe: client.sexe,
        photo: client.photo,
        notes: ('${client.notes ?? ''}\n$note').trim(),
        isVip: client.isVip,
        actif: client.actif,
        createdAt: client.createdAt,
        lastCommandeAt: client.lastCommandeAt,
      );
      await _clientRepo.updateClient(updated);
    }
  }

  // ----------------------- Filtrage temporel -----------------------
  Future<List<Client>> getClientsRecents({int jours = 7}) async {
    final all = await _clientRepo.getAllClients();
    final limite = DateTime.now().subtract(Duration(days: jours));
    return all.where((c) => c.createdAt.isAfter(limite)).toList();
  }

  Future<List<Client>> getClientsSansCommande() async {
    final allClients = await _clientRepo.getAllClients();
    final clientsAvecCommande = await _commandeRepo.getAllClientsWithCommande();
    return allClients.where((c) => !clientsAvecCommande.contains(c.id)).toList();
  }

  Future<List<Client>> getClientsAvecCommandesRecente({int jours = 7}) async {
    final limite = DateTime.now().subtract(Duration(days: jours));
    final commandes = await _commandeRepo.getCommandesSince(limite);
    final ids = commandes.map((c) => c.clientId).toSet();
    final all = await _clientRepo.getAllClients();
    return all.where((c) => ids.contains(c.id)).toList();
  }

  // ----------------------- Recherche avancée -----------------------
  Future<List<Client>> searchClientsAdvanced({
    String? nom,
    String? prenom,
    String? telephone,
    bool? isVip,
  }) async {
    final all = await _clientRepo.getAllClients();
    return all.where((c) {
      bool matches = true;
      if (nom != null) matches = matches && c.nom.toLowerCase().contains(nom.toLowerCase());
      if (prenom != null) matches = matches && c.prenom.toLowerCase().contains(prenom.toLowerCase());
      if (telephone != null) matches = matches && c.telephone.contains(telephone);
      if (isVip != null) matches = matches && c.isVip == isVip;
      return matches;
    }).toList();
  }

  // ----------------------- Activation / Désactivation -----------------------
  Future<void> activateClient(int clientId) async {
    final client = await _clientRepo.getClientById(clientId);
    if (client != null && !client.actif) {
      final updated = Client(
        id: client.id,
        nom: client.nom,
        prenom: client.prenom,
        telephone: client.telephone,
        email: client.email,
        adresse: client.adresse,
        sexe: client.sexe,
        photo: client.photo,
        notes: client.notes,
        isVip: client.isVip,
        actif: true,
        createdAt: client.createdAt,
        lastCommandeAt: client.lastCommandeAt,
      );
      await _clientRepo.updateClient(updated);
    }
  }
}
