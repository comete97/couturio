import 'package:flutter/material.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/data/models/paiement.dart';
import 'package:couturio/shared/services/client_service.dart';
import 'package:couturio/shared/services/commande_service.dart';
import 'package:couturio/shared/services/paiement_service.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';

class PaiementListPage extends StatefulWidget {
  const PaiementListPage({super.key});

  @override
  State<PaiementListPage> createState() => _PaiementListPageState();
}

class _PaiementListPageState extends State<PaiementListPage> {
  late PaiementService _paiementService;
  late CommandeService _commandeService;
  late ClientService _clientService;

  late Future<List<Paiement>> _paiementsFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'tous';

  final Map<int, Commande?> _commandesMap = {};
  final Map<int, Client?> _clientsMap = {};

  double _totalJour = 0;
  double _totalMois = 0;
  int _nombrePaiements = 0;

  @override
  void initState() {
    super.initState();

    _paiementService = ServiceLocator().paiementService;
    _commandeService = ServiceLocator().commandeService;
    _clientService = ServiceLocator().clientService;

    _loadPaiements();
    _loadResume();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _loadPaiements() {
    _paiementsFuture = _fetchPaiements();
  }

  Future<void> _loadResume() async {
    final paiementsJour = await _paiementService.paiementsDuJour();
    final paiementsMois = await _paiementService.paiementsDuMois();
    final allPaiements = await _paiementService.getAllPaiements();

    if (!mounted) return;

    setState(() {
      _totalJour = paiementsJour.fold<double>(0.0, (sum, p) => sum + p.montant);
      _totalMois = paiementsMois.fold<double>(0.0, (sum, p) => sum + p.montant);
      _nombrePaiements = allPaiements.length;
    });
  }

  Future<List<Paiement>> _fetchPaiements() async {
    switch (_selectedFilter) {
      case 'jour':
        return _paiementService.paiementsDuJour();
      case 'semaine':
        return _paiementService.paiementsDeLaSemaine();
      case 'mois':
        return _paiementService.paiementsDuMois();
      default:
        return _paiementService.getAllPaiements();
    }
  }

  Future<void> _loadAssociations(List<Paiement> paiements) async {
    for (final paiement in paiements) {
      if (!_commandesMap.containsKey(paiement.commandeId)) {
        final commande = await _commandeService.getCommandeById(paiement.commandeId);
        _commandesMap[paiement.commandeId] = commande;

        if (commande != null && !_clientsMap.containsKey(commande.clientId)) {
          final client = await _clientService.getClientById(commande.clientId);
          _clientsMap[commande.clientId] = client;
        }
      }
    }
  }

  List<Paiement> _applySearch(List<Paiement> paiements) {
    if (_searchQuery.isEmpty) return paiements;

    return paiements.where((paiement) {
      final commande = _commandesMap[paiement.commandeId];
      final client = commande != null ? _clientsMap[commande.clientId] : null;

      final commandeNom = (commande?.modele ?? '').toLowerCase();
      final clientNom = client != null
          ? "${client.prenom} ${client.nom}".toLowerCase()
          : '';
      final notes = (paiement.notes ?? '').toLowerCase();
      final mode = _modePaiementLabel(paiement.modePaiement).toLowerCase();
      final montant = paiement.montant.toString();

      return commandeNom.contains(_searchQuery) ||
          clientNom.contains(_searchQuery) ||
          notes.contains(_searchQuery) ||
          mode.contains(_searchQuery) ||
          montant.contains(_searchQuery);
    }).toList();
  }

  void _refreshPage() {
    setState(() {
      _loadPaiements();
    });
    _loadResume();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _formatMoney(double value) {
    return "${value.toStringAsFixed(0)} FCFA";
  }

  String _modePaiementLabel(ModePaiement mode) {
    switch (mode) {
      case ModePaiement.especes:
        return "Espèces";
      case ModePaiement.mobileMoney:
        return "Mobile Money";
      case ModePaiement.virement:
        return "Virement";
    }
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
  }) {
    final selected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
          _loadPaiements();
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.18),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: AppColors.primary),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
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
        title: const Text("Paiements"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Résumé
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "Aujourd’hui",
                    value: _formatMoney(_totalJour),
                    icon: Icons.today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: "Ce mois",
                    value: _formatMoney(_totalMois),
                    icon: Icons.calendar_month,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SummaryWideCard(
              title: "Nombre total de paiements",
              value: _nombrePaiements.toString(),
              icon: Icons.payments,
            ),

            const SizedBox(height: 16),

            /// Recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un paiement",
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

            const SizedBox(height: 14),

            /// Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(label: "Tous", value: 'tous'),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: "Aujourd’hui", value: 'jour'),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: "Semaine", value: 'semaine'),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: "Mois", value: 'mois'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Timeline
            Expanded(
              child: FutureBuilder<List<Paiement>>(
                future: _paiementsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erreur lors du chargement des paiements"),
                    );
                  }

                  final rawPaiements = snapshot.data ?? [];

                  return FutureBuilder<void>(
                    future: _loadAssociations(rawPaiements),
                    builder: (context, _) {
                      final paiements = _applySearch(rawPaiements);

                      if (paiements.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async => _refreshPage(),
                          child: ListView(
                            children: [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  "Aucun paiement trouvé",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _refreshPage(),
                        child: ListView.builder(
                          itemCount: paiements.length,
                          itemBuilder: (context, index) {
                            final paiement = paiements[index];
                            final isLast = index == paiements.length - 1;

                            final commande = _commandesMap[paiement.commandeId];
                            final client = commande != null
                                ? _clientsMap[commande.clientId]
                                : null;

                            final titreCommande =
                            commande?.modele?.trim().isNotEmpty == true
                                ? commande!.modele!
                                : "Commande #${paiement.commandeId}";

                            final nomClient = client != null
                                ? "${client.prenom} ${client.nom}"
                                : "Client non renseigné";

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Timeline
                                  Column(
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      if (!isLast)
                                        Container(
                                          width: 2,
                                          height: 120,
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  ),

                                  const SizedBox(width: 12),

                                  /// Card paiement
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _formatMoney(paiement.montant),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(paiement.datePaiement),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            titreCommande,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            nomClient,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Mode : ${_modePaiementLabel(paiement.modePaiement)}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          if (paiement.notes?.trim().isNotEmpty ==
                                              true) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              paiement.notes!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryWideCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryWideCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.14),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}