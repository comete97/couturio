import 'package:flutter/material.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/shared/services/dashboard_service.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';
import 'package:couturio/ui/common/widgets/app_bottom_nav.dart';

import 'package:couturio/ui/clients/pages/client_list_page.dart';
import 'package:couturio/ui/clients/pages/client_form_page.dart';
import 'package:couturio/ui/commandes/pages/commande_list_page.dart';
import 'package:couturio/ui/livraisons/pages/livraison_list_page.dart';
import 'package:couturio/ui/common/utils/bottom_nav_helper.dart';
import 'package:couturio/ui/paiements/pages/paiement_list_page.dart';

import 'package:couturio/ui/paiements/pages/paiement_form_page.dart';
import 'package:couturio/ui/paiements/pages/select_commande_for_paiement_page.dart';
import 'package:couturio/data/models/commande.dart';

class DashboardPage extends StatefulWidget {
  final bool showBottomNav;

  const DashboardPage({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardService _dashboardService;
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardService = ServiceLocator().dashboardService;
    _loadDashboard();
  }

  void _loadDashboard() {
    _dashboardFuture = _fetchDashboardData();
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final totalClients = await _dashboardService.totalClients();
    final totalVipClients = await _dashboardService.totalVipClients();

    final totalCommandes = await _dashboardService.totalCommandes();
    final commandesDuJour = await _dashboardService.commandesDuJour();
    final commandesEnRetard = await _dashboardService.commandesEnRetard();

    final paiementsCeMois = await _dashboardService.paiementsCeMois();

    final livraisonsDuJour = await _dashboardService.livraisonsDuJour();
    final livraisonsEnRetard = await _dashboardService.livraisonsEnRetard();

    return {
      'totalClients': totalClients,
      'totalVipClients': totalVipClients,
      'totalCommandes': totalCommandes,
      'commandesDuJour': commandesDuJour,
      'commandesEnRetard': commandesEnRetard,
      'paiementsCeMois': paiementsCeMois,
      'livraisonsDuJour': livraisonsDuJour,
      'livraisonsEnRetard': livraisonsEnRetard,
    };
  }

  String _formatMoney(double value) {
    return "${value.toStringAsFixed(0)} FCFA";
  }


  void _goToNewClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClientFormPage()),
    );

    if (result == true) {
      setState(() {
        _loadDashboard();
      });
    }
  }

  void _goToCommandes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommandeListPage()),
    );
  }

  void _goToClients() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClientListPage()),
    );
  }

  void _showChooseClientMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Choisissez d’abord un client pour créer une commande."),
      ),
    );
  }

  Future<void> _goToNewPaiement() async {
    final Commande? commande = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectCommandeForPaiementPage(),
      ),
    );

    if (commande == null || !mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaiementFormPage(commande: commande),
      ),
    );

    if (result == true) {
      setState(() {
        _loadDashboard();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Accueil"),
      ),

      bottomNavigationBar: widget.showBottomNav
          ? AppBottomNav(
        currentIndex: 0,
        onTap: (index) => handleBottomNav(context, 0, index),
      )
          : null,

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadDashboard();
          });
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                children: [
                  SizedBox(height: 220),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  SizedBox(height: 220),
                  Center(
                    child: Text(
                      "Erreur lors du chargement du tableau de bord",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data ?? {};

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.monitor_outlined,
                      size: 30,
                      color: AppColors.textDark,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Tableau de board",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                DashboardHeroCard(
                  onAddCommande: _showChooseClientMessage,
                  onAddClient: _goToNewClient,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _DashboardCard(
                        title: "Clients",
                        value: "${data['totalClients'] ?? 0}",
                        subtitle: "VIP : ${data['totalVipClients'] ?? 0}",
                        icon: Icons.people,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DashboardCard(
                        title: "Commandes",
                        value: "${data['totalCommandes'] ?? 0}",
                        subtitle: "Aujourd’hui : ${data['commandesDuJour'] ?? 0}",
                        icon: Icons.receipt_long,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _DashboardCard(
                        title: "CA du mois",
                        value: _formatMoney(
                          (data['paiementsCeMois'] ?? 0.0) as double,
                        ),
                        subtitle: "Paiements reçus",
                        icon: Icons.payments,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DashboardCard(
                        title: "Livraisons",
                        value: "${data['livraisonsDuJour'] ?? 0}",
                        subtitle: "Aujourd’hui",
                        icon: Icons.local_shipping,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Alertes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                _AlertTile(
                  title: "Commandes en retard",
                  value: "${data['commandesEnRetard'] ?? 0}",
                  icon: Icons.warning_amber_rounded,
                ),
                const SizedBox(height: 10),
                _AlertTile(
                  title: "Livraisons en retard",
                  value: "${data['livraisonsEnRetard'] ?? 0}",
                  icon: Icons.local_shipping_outlined,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Accès rapides",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickActionChip(
                      label: "Nouveau client",
                      icon: Icons.person_add,
                      onTap: _goToNewClient,
                    ),
                    _QuickActionChip(
                      label: "Voir commandes",
                      icon: Icons.add_box,
                      onTap: _goToCommandes,
                    ),
                    _QuickActionChip(
                      label: "Mensurations",
                      icon: Icons.straighten,
                      onTap: _goToClients,
                    ),

                    _QuickActionChip(
                      label: "Créer commande",
                      icon: Icons.receipt_long,
                      onTap: _showChooseClientMessage,
                    ),

                    _QuickActionChip(
                      label: "Voir paiements",
                      icon: Icons.payments_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaiementListPage(),
                          ),
                        );
                      },
                    ),

                    _QuickActionChip(
                      label: "Ajouter paiement",
                      icon: Icons.payments_outlined,
                      onTap: _goToNewPaiement,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DashboardHeroCard extends StatelessWidget {
  final VoidCallback onAddCommande;
  final VoidCallback onAddClient;

  const DashboardHeroCard({
    super.key,
    required this.onAddCommande,
    required this.onAddClient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF67CFCF),
            Color(0xFF58C7C7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Natitingou",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Meilleur gestion des\ncommande et des retard de\nvotre atelier",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroActionButton(
                      label: "Ajouter une commande",
                      onTap: onAddCommande,
                    ),
                    _HeroActionButton(
                      label: "Ajouter un client",
                      onTap: onAddClient,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Icon(
            Icons.checkroom,
            size: 92,
            color: Colors.white.withOpacity(0.92),
          ),
        ],
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HeroActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Icon(icon, color: AppColors.primary, size: 28),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _AlertTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, color: AppColors.primary, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.primary),
      labelStyle: const TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}