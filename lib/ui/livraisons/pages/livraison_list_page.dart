import 'package:flutter/material.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/shared/services/livraison_service.dart';
import 'package:couturio/shared/services/commande_service.dart';
import 'package:couturio/data/models/livraison.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';
import 'package:couturio/ui/common/widgets/app_bottom_nav.dart';
import 'package:couturio/ui/common/utils/bottom_nav_helper.dart';
import 'package:couturio/core/utils/statut_livraison_extension.dart';
import 'package:couturio/ui/livraisons/pages/livraison_detail_page.dart';
import 'package:couturio/ui/livraisons/pages/select_commande_for_livraison_page.dart';
import 'package:couturio/ui/livraisons/pages/livraison_form_page.dart';

class LivraisonListPage extends StatefulWidget {
  final bool showBottomNav;

  const LivraisonListPage({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<LivraisonListPage> createState() => _LivraisonListPageState();
}

class _LivraisonListPageState extends State<LivraisonListPage> {
  late LivraisonService _livraisonService;
  late CommandeService _commandeService;
  late Future<List<Livraison>> _livraisonsFuture;

  String _searchQuery = '';
  String _selectedFilter = 'toutes';

  final TextEditingController _searchController = TextEditingController();
  final Map<int, Commande?> _commandesMap = {};

  @override
  void initState() {
    super.initState();
    _livraisonService = ServiceLocator().livraisonService;
    _commandeService = ServiceLocator().commandeService;
    _loadLivraisons();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _loadLivraisons() {
    _livraisonsFuture = _fetchLivraisons();
  }

  Future<List<Livraison>> _fetchLivraisons() async {
    switch (_selectedFilter) {
      case 'enCours':
        return _livraisonService.getLivraisonsEnCours();
      case 'livree':
        return _livraisonService.getLivraisonsLivrees();
      default:
        return _livraisonService.getToutesLesLivraisons();
    }
  }

  void _refreshLivraisons() {
    setState(() {
      _loadLivraisons();
    });
  }

  Future<void> _loadCommandesAssociees(List<Livraison> livraisons) async {
    for (final livraison in livraisons) {
      if (!_commandesMap.containsKey(livraison.commandeId)) {
        final commande =
        await _commandeService.getCommandeById(livraison.commandeId);
        _commandesMap[livraison.commandeId] = commande;
      }
    }
  }

  List<Livraison> _applySearch(List<Livraison> livraisons) {
    if (_searchQuery.isEmpty) return livraisons;

    return livraisons.where((livraison) {
      final livreur = (livraison.livreur ?? '').toLowerCase();
      final instructions = (livraison.instructions ?? '').toLowerCase();
      final notes = (livraison.notes ?? '').toLowerCase();
      final type = livraison.type.name.toLowerCase();
      final statut = livraison.statut.label.toLowerCase();

      final commande = _commandesMap[livraison.commandeId];
      final modele = (commande?.modele ?? '').toLowerCase();

      return livreur.contains(_searchQuery) ||
          instructions.contains(_searchQuery) ||
          notes.contains(_searchQuery) ||
          type.contains(_searchQuery) ||
          statut.contains(_searchQuery) ||
          modele.contains(_searchQuery) ||
          livraison.commandeId.toString().contains(_searchQuery);
    }).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _typeLabel(TypeLivraison type) {
    switch (type) {
      case TypeLivraison.standard:
        return "Standard";
      case TypeLivraison.express:
        return "Express";
      case TypeLivraison.retraitAtelier:
        return "Retrait atelier";
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
          _loadLivraisons();
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

  Future<void> _ajouterLivraison() async {
    final Commande? commande = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectCommandeForLivraisonPage(),
      ),
    );

    if (commande == null || !mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LivraisonFormPage(commande: commande),
      ),
    );

    if (result == true) {
      _refreshLivraisons();
    }
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
        title: const Text("Livraisons"),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? AppBottomNav(
        currentIndex: 3,
        onTap: (index) => handleBottomNav(context, 3, index),
      )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _ajouterLivraison,
        icon: const Icon(Icons.add),
        label: const Text("Livraison"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher une livraison",
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(label: "Toutes", value: 'toutes'),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: "En cours", value: 'enCours'),
                  const SizedBox(width: 8),
                  _buildFilterChip(label: "Livrées", value: 'livree'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Livraison>>(
                future: _livraisonsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erreur lors du chargement des livraisons"),
                    );
                  }

                  final rawLivraisons = snapshot.data ?? [];

                  return FutureBuilder<void>(
                    future: _loadCommandesAssociees(rawLivraisons),
                    builder: (context, commandeSnapshot) {
                      final livraisons = _applySearch(rawLivraisons);

                      if (livraisons.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async => _refreshLivraisons(),
                          child: ListView(
                            children: [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  "Aucune livraison trouvée",
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
                        onRefresh: () async => _refreshLivraisons(),
                        child: ListView.builder(
                          itemCount: livraisons.length,
                          itemBuilder: (context, index) {
                            final livraison = livraisons[index];
                            final commande = _commandesMap[livraison.commandeId];

                            final titreCommande =
                            commande?.modele?.isNotEmpty == true
                                ? commande!.modele!
                                : "Commande #${livraison.commandeId}";

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LivraisonDetailPage(livraison: livraison),
                                  ),
                                );

                                if (result == true) {
                                  _refreshLivraisons();
                                }
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
                                      livraison.statut.backgroundColor,
                                      child: Icon(
                                        livraison.statut.icon,
                                        color: livraison.statut.color,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            titreCommande,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Livreur : ${livraison.livreur?.isNotEmpty == true ? livraison.livreur! : 'Non renseigné'}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Type : ${_typeLabel(livraison.type)}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Date : ${_formatDate(livraison.dateLivraisonEffectuee)}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: livraison
                                                  .statut.backgroundColor,
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              livraison.statut.label,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: livraison.statut.color,
                                              ),
                                            ),
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