import 'package:flutter/material.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/core/utils/statut_commande_extension.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/shared/services/commande_service.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';
import 'package:couturio/ui/commandes/pages/commande_detail_page.dart';
import 'package:couturio/ui/commandes/widgets/statut_commande_badge.dart';
import '../../common/widgets/app_bottom_nav.dart';
import 'package:couturio/ui/common/utils/bottom_nav_helper.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/ui/commandes/pages/commande_form_page.dart';
import 'package:couturio/ui/commandes/pages/select_client_for_commande_page.dart';

class CommandeListPage extends StatefulWidget {
  final bool showBottomNav;

  const CommandeListPage({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<CommandeListPage> createState() => _CommandeListPageState();
}

class _CommandeListPageState extends State<CommandeListPage> {
  late CommandeService _commandeService;
  late Future<List<Commande>> _commandesFuture;

  final TextEditingController _searchController = TextEditingController();

  StatutCommande? _selectedStatut;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _commandeService = ServiceLocator().commandeService;
    _loadCommandes();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _loadCommandes() {
    _commandesFuture = _commandeService.getAllCommandes();
  }

  void _refreshCommandes() {
    setState(() {
      _loadCommandes();
    });
  }

  List<Commande> _applyFilters(List<Commande> commandes) {
    return commandes.where((commande) {
      final matchesStatut =
          _selectedStatut == null || commande.statut == _selectedStatut;

      final modele = (commande.modele ?? '').toLowerCase();
      final description = (commande.description ?? '').toLowerCase();
      final notes = (commande.notes ?? '').toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          modele.contains(_searchQuery) ||
          description.contains(_searchQuery) ||
          notes.contains(_searchQuery);

      return matchesStatut && matchesSearch;
    }).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
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
        title: const Text("Commandes"),
      ),

      bottomNavigationBar: widget.showBottomNav
          ? AppBottomNav(
        currentIndex: 1,
        onTap: (index) => handleBottomNav(context, 1, index),
      )
          : null,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Recherche
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

            const SizedBox(height: 14),

            /// Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: "Toutes",
                    selected: _selectedStatut == null,
                    onTap: () {
                      setState(() {
                        _selectedStatut = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: StatutCommande.enAttente.label,
                    selected: _selectedStatut == StatutCommande.enAttente,
                    onTap: () {
                      setState(() {
                        _selectedStatut = StatutCommande.enAttente;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: StatutCommande.enCours.label,
                    selected: _selectedStatut == StatutCommande.enCours,
                    onTap: () {
                      setState(() {
                        _selectedStatut = StatutCommande.enCours;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: StatutCommande.termine.label,
                    selected: _selectedStatut == StatutCommande.termine,
                    onTap: () {
                      setState(() {
                        _selectedStatut = StatutCommande.termine;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: StatutCommande.livre.label,
                    selected: _selectedStatut == StatutCommande.livre,
                    onTap: () {
                      setState(() {
                        _selectedStatut = StatutCommande.livre;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Liste
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

                  final commandes = _applyFilters(snapshot.data ?? []);

                  if (commandes.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async => _refreshCommandes(),
                      child: ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              "Aucune commande trouvée",
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
                    onRefresh: () async => _refreshCommandes(),
                    child: ListView.builder(
                      itemCount: commandes.length,
                      itemBuilder: (context, index) {
                        final commande = commandes[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CommandeDetailPage(commande: commande),
                              ),
                            );

                            _refreshCommandes();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                  AppColors.primary.withOpacity(0.15),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        commande.modele?.isNotEmpty == true
                                            ? commande.modele!
                                            : "Modèle non renseigné",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Prix : ${commande.prixTotal.toStringAsFixed(0)} FCFA",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Livraison prévue : ${_formatDate(commande.dateLivraisonPrevue)}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      StatutCommandeBadge(
                                        statut: commande.statut,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final Client? client = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SelectClientForCommandePage(),
            ),
          );

          if (client == null || !context.mounted) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommandeFormPage(client: client),
            ),
          );

          if (result == true) {
            _refreshCommandes();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Commande"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

    );
  }
}