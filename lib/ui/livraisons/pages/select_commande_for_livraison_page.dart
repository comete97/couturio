import 'package:flutter/material.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/shared/services/commande_service.dart';
import 'package:couturio/shared/services/livraison_service.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';

class SelectCommandeForLivraisonPage extends StatefulWidget {
  const SelectCommandeForLivraisonPage({super.key});

  @override
  State<SelectCommandeForLivraisonPage> createState() =>
      _SelectCommandeForLivraisonPageState();
}

class _SelectCommandeForLivraisonPageState
    extends State<SelectCommandeForLivraisonPage> {
  late CommandeService _commandeService;
  late LivraisonService _livraisonService;

  late Future<List<Commande>> _commandesFuture;

  @override
  void initState() {
    super.initState();
    _commandeService = ServiceLocator().commandeService;
    _livraisonService = ServiceLocator().livraisonService;
    _commandesFuture = _fetchCommandesEligibles();
  }

  Future<List<Commande>> _fetchCommandesEligibles() async {
    final commandes = await _commandeService.getAllCommandes();
    final livraisons = await _livraisonService.getToutesLesLivraisons();

    final commandeIdsAvecLivraison = livraisons
        .where((l) => l.id != null)
        .map((l) => l.commandeId)
        .toSet();

    return commandes.where((c) {
      return c.id != null &&
          c.statut == StatutCommande.termine &&
          !commandeIdsAvecLivraison.contains(c.id);
    }).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Choisir une commande"),
      ),
      body: FutureBuilder<List<Commande>>(
        future: _commandesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Erreur lors du chargement des commandes"),
            );
          }

          final commandes = snapshot.data ?? [];

          if (commandes.isEmpty) {
            return const Center(
              child: Text("Aucune commande terminée disponible"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              final commande = commandes[index];

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(commande.modele ?? "Commande"),
                  subtitle: Text(
                    "Livraison prévue : ${_formatDate(commande.dateLivraisonPrevue)}",
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
      ),
    );
  }
}