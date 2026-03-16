import 'package:flutter/material.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/shared/services/client_service.dart';
import 'package:couturio/shared/services/commande_service.dart';
import 'package:couturio/shared/services/paiement_service.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';

class SelectCommandeForPaiementPage extends StatefulWidget {
  const SelectCommandeForPaiementPage({super.key});

  @override
  State<SelectCommandeForPaiementPage> createState() =>
      _SelectCommandeForPaiementPageState();
}

class _SelectCommandeForPaiementPageState
    extends State<SelectCommandeForPaiementPage> {
  late CommandeService _commandeService;
  late PaiementService _paiementService;
  late ClientService _clientService;

  late Future<List<Commande>> _commandesFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<int, Client?> _clientsMap = {};

  @override
  void initState() {
    super.initState();
    _commandeService = ServiceLocator().commandeService;
    _paiementService = ServiceLocator().paiementService;
    _clientService = ServiceLocator().clientService;

    _commandesFuture = _fetchCommandesNonSoldees();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<List<Commande>> _fetchCommandesNonSoldees() async {
    final commandes = await _commandeService.getAllCommandes();
    final List<Commande> nonSoldees = [];

    for (final commande in commandes) {
      if (commande.id == null) continue;

      final estSoldee = await _paiementService.estSoldee(commande);
      if (!estSoldee) {
        nonSoldees.add(commande);
      }
    }

    return nonSoldees;
  }

  Future<void> _loadClients(List<Commande> commandes) async {
    for (final commande in commandes) {
      if (!_clientsMap.containsKey(commande.clientId)) {
        final client = await _clientService.getClientById(commande.clientId);
        _clientsMap[commande.clientId] = client;
      }
    }
  }

  List<Commande> _applySearch(List<Commande> commandes) {
    if (_searchQuery.isEmpty) return commandes;

    return commandes.where((commande) {
      final modele = (commande.modele ?? '').toLowerCase();
      final client = _clientsMap[commande.clientId];
      final nomClient = client != null
          ? "${client.prenom} ${client.nom}".toLowerCase()
          : '';

      return modele.contains(_searchQuery) ||
          nomClient.contains(_searchQuery) ||
          commande.id.toString().contains(_searchQuery);
    }).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _formatMoney(double value) {
    return "${value.toStringAsFixed(0)} FCFA";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Choisir une commande"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher une commande",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                floatingLabelStyle: const TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryDark,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Commande>>(
                future: _commandesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erreur lors du chargement des commandes"),
                    );
                  }

                  final rawCommandes = snapshot.data ?? [];

                  return FutureBuilder<void>(
                    future: _loadClients(rawCommandes),
                    builder: (context, _) {
                      final commandes = _applySearch(rawCommandes);

                      if (commandes.isEmpty) {
                        return const Center(
                          child: Text("Aucune commande non soldée trouvée"),
                        );
                      }

                      return ListView.builder(
                        itemCount: commandes.length,
                        itemBuilder: (context, index) {
                          final commande = commandes[index];
                          final client = _clientsMap[commande.clientId];
                          final titreCommande =
                          commande.modele?.trim().isNotEmpty == true
                              ? commande.modele!
                              : "Commande #${commande.id}";

                          return FutureBuilder<double>(
                            future: _paiementService.resteAPayerPourCommande(
                              commande,
                            ),
                            builder: (context, resteSnapshot) {
                              final reste = resteSnapshot.data ?? commande.prixTotal;

                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                    AppColors.primary.withOpacity(0.15),
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  title: Text(titreCommande),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        client != null
                                            ? "${client.prenom} ${client.nom}"
                                            : "Client non renseigné",
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Livraison prévue : ${_formatDate(commande.dateLivraisonPrevue)}",
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Reste : ${_formatMoney(reste)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.pop(context, commande);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}