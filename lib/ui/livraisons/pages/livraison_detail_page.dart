import 'package:flutter/material.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/data/models/livraison.dart';
import 'package:couturio/shared/services/client_service.dart';
import 'package:couturio/shared/services/commande_service.dart';
import 'package:couturio/shared/services/livraison_service.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';
import 'package:couturio/ui/common/widgets/expandable_info_card.dart';
import 'package:couturio/core/utils/statut_livraison_extension.dart';

class LivraisonDetailPage extends StatefulWidget {
  final Livraison livraison;

  const LivraisonDetailPage({
    super.key,
    required this.livraison,
  });

  @override
  State<LivraisonDetailPage> createState() => _LivraisonDetailPageState();
}

class _LivraisonDetailPageState extends State<LivraisonDetailPage> {
  late Livraison _livraison;
  late LivraisonService _livraisonService;
  late CommandeService _commandeService;
  late ClientService _clientService;

  Commande? _commande;
  Client? _client;

  @override
  void initState() {
    super.initState();
    _livraison = widget.livraison;
    _livraisonService = ServiceLocator().livraisonService;
    _commandeService = ServiceLocator().commandeService;
    _clientService = ServiceLocator().clientService;
    _loadCommandeEtClient();
  }

  Future<void> _loadCommandeEtClient() async {
    final commande = await _commandeService.getCommandeById(_livraison.commandeId);

    Client? client;
    if (commande != null) {
      client = await _clientService.getClientById(commande.clientId);
    }

    if (!mounted) return;

    setState(() {
      _commande = commande;
      _client = client;
    });
  }

  Future<void> _reloadLivraison() async {
    if (_livraison.id == null) return;

    final updated = await _livraisonService.getLivraisonById(_livraison.id!);
    if (updated != null && mounted) {
      setState(() {
        _livraison = updated;
      });
    }

    await _loadCommandeEtClient();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _safeValue(String? value, {String fallback = "Non renseigné"}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
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

  String get _titreCommande {
    if (_commande?.modele != null && _commande!.modele!.trim().isNotEmpty) {
      return _commande!.modele!;
    }
    return "Commande #${_livraison.commandeId}";
  }

  String get _nomClient {
    if (_client != null) {
      return "${_client!.prenom} ${_client!.nom}";
    }
    return "Chargement...";
  }

  Future<void> _confirmerLivraison() async {
    await _livraisonService.confirmerLivraison(_livraison);
    await _reloadLivraison();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Livraison confirmée")),
    );
  }

  Future<void> _annulerLivraison() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Annuler la livraison"),
        content: const Text("Voulez-vous vraiment annuler cette livraison ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Non"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Oui"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (_livraison.id == null) {
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    await _livraisonService.annulerLivraison(_livraison);
    await _reloadLivraison();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Livraison annulée")),
    );
  }

  Future<void> _marquerEchec() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Marquer en échec"),
        content: const Text("Voulez-vous marquer cette livraison comme échouée ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Non"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Oui"),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (_livraison.id == null) return;

    await _livraisonService.marquerEchec(_livraison);
    await _reloadLivraison();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Livraison marquée en échec")),
    );
  }

  Future<void> _supprimerLivraison() async {
    if (_livraison.id == null) {
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer la livraison"),
        content: const Text("Voulez-vous vraiment supprimer cette livraison ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Non"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _livraisonService.supprimerLivraison(_livraison.id!);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Détails livraison"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (_livraisonService.peutConfirmer(_livraison))
              _ActionButton(
                label: "Confirmer",
                icon: Icons.check_circle,
                color: Colors.green,
                onPressed: _confirmerLivraison,
              ),
            if (_livraisonService.peutAnnuler(_livraison))
              _ActionButton(
                label: "Annuler",
                icon: Icons.cancel,
                color: Colors.orange,
                onPressed: _annulerLivraison,
              ),
            if (_livraisonService.peutMarquerEchec(_livraison))
              _ActionButton(
                label: "Échec",
                icon: Icons.error,
                color: Colors.deepOrange,
                onPressed: _marquerEchec,
              ),
            if (_livraisonService.peutSupprimer(_livraison))
              _ActionButton(
                label: "Supprimer",
                icon: Icons.delete,
                color: Colors.red,
                onPressed: _supprimerLivraison,
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// EN-TÊTE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _livraison.statut.backgroundColor,
                    child: Icon(
                      _livraison.statut.icon,
                      color: _livraison.statut.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titreCommande,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _nomClient,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _livraison.statut.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _livraison.statut.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _livraison.statut.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INFOS GÉNÉRALES
            ExpandableInfoCard(
              title: "Informations générales",
              collapsedHeight: 200,
              showToggle: false,
              child: Column(
                children: [
                  _InfoRow(
                    label: "Commande",
                    value: _titreCommande,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Client",
                    value: _nomClient,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Type",
                    value: _typeLabel(_livraison.type),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Livreur",
                    value: _safeValue(_livraison.livreur),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Créée le",
                    value: _commande != null
                        ? _formatDate(_commande!.dateCreation)
                        : "Chargement...",
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Date prévue",
                    value: _commande != null
                        ? _formatDate(_commande!.dateLivraisonPrevue)
                        : "Chargement...",
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Date effective",
                    value: _formatDate(_livraison.dateLivraisonEffectuee),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Rappel envoyé",
                    value: _livraison.rappelEnvoye ? "Oui" : "Non",
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Confirmée client",
                    value: _livraison.confirmeParClient ? "Oui" : "Non",
                  ),
                ],
              ),
            ),

            ExpandableInfoCard(
              title: "Instructions",
              collapsedHeight: 90,
              showToggle: (_livraison.instructions ?? "").length > 90,
              child: Text(
                _safeValue(
                  _livraison.instructions,
                  fallback: "Aucune instruction",
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ),

            ExpandableInfoCard(
              title: "Notes",
              collapsedHeight: 90,
              showToggle: (_livraison.notes ?? "").length > 90,
              child: Text(
                _safeValue(_livraison.notes, fallback: "Aucune note"),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "$label :",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.12),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withOpacity(0.5)),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}