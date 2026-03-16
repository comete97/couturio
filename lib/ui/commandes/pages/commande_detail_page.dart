import 'dart:io';

import 'package:flutter/material.dart';
import 'package:couturio/data/models/commande.dart';
//import 'package:couturio/core/utils/statut_commande_extension.dart';
import 'package:couturio/ui/commandes/widgets/statut_commande_badge.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';
import 'package:couturio/ui/common/widgets/expandable_info_card.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/shared/services/commande_service.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/ui/clients/pages/client_detail_page.dart';
import 'commande_form_page.dart';

import 'package:couturio/data/models/paiement.dart';
import 'package:couturio/shared/services/paiement_service.dart';
import 'package:couturio/ui/paiements/pages/paiement_form_page.dart';

class CommandeDetailPage extends StatefulWidget {
  final Commande commande;

  const CommandeDetailPage({
    super.key,
    required this.commande,
  });

  @override
  State<CommandeDetailPage> createState() => _CommandeDetailPageState();
}

class _CommandeDetailPageState extends State<CommandeDetailPage> {
  late Commande _commande;
  late CommandeService _commandeService;

  late PaiementService _paiementService;
  late Future<List<Paiement>> _paiementsFuture;
  double _totalPaye = 0;
  double _resteAPayer = 0;

  Client? _client;

  @override
  void initState() {
    super.initState();
    _commande = widget.commande;
    _commandeService = ServiceLocator().commandeService;
    _paiementService = ServiceLocator().paiementService;
    _loadPaiements();
    _loadClient();
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

  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _loadClient() async {
    final client =
    await ServiceLocator().clientService.getClientById(_commande.clientId);

    if (!mounted) return;

    setState(() {
      _client = client;
    });
  }
  Future<void> _reloadCommande() async {
    final updated = await _commandeService.getCommandeById(_commande.id!);
    if (updated != null && mounted) {
      setState(() {
        _commande = updated;
      });
    }
    _reloadPaiements();
  }

  Future<void> _modifierCommande() async {
    final client = await ServiceLocator()
        .clientService
        .getClientById(_commande.clientId);

    if (client == null || !mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommandeFormPage(
          client: client,
          commande: _commande,
        ),
      ),
    );

    if (result == true) {
      await _reloadCommande();
    }
  }

  Future<void> _demarrerCommande() async {
    await _commandeService.demarrerCommande(_commande.id!);
    await _reloadCommande();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Commande démarrée"),
      ),
    );
  }

  Future<void> _terminerCommande() async {
    await _commandeService.terminerCommande(_commande.id!);
    await _reloadCommande();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Commande terminée"),
      ),
    );
  }

  Future<void> _annulerCommande() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Annuler la commande"),
        content: const Text(
          "Voulez-vous vraiment annuler cette commande ?",
        ),
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

    await _commandeService.annulerCommande(_commande.id!);
    await _reloadCommande();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Commande annulée"),
      ),
    );
  }

  Future<void> _supprimerCommande() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer la commande"),
        content: const Text(
          "Voulez-vous vraiment supprimer cette commande ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Non"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _commandeService.supprimerCommande(_commande.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Commande supprimée"),
      ),
    );

    Navigator.pop(context, true);
  }

  void _loadPaiements() {
    _paiementsFuture = _paiementService.getPaiementsByCommande(_commande.id!);
    _loadResumePaiements();
  }

  Future<void> _loadResumePaiements() async {
    final total = await _paiementService.totalPayePourCommande(_commande.id!);
    final reste = await _paiementService.resteAPayerPourCommande(_commande);

    if (!mounted) return;

    setState(() {
      _totalPaye = total;
      _resteAPayer = reste;
    });
  }

  void _reloadPaiements() {
    setState(() {
      _loadPaiements();
    });
  }

  Future<void> _ajouterPaiement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaiementFormPage(commande: _commande),
      ),
    );

    if (result == true) {
      _reloadPaiements();
    }
  }

  Future<void> _modifierPaiement(Paiement paiement) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaiementFormPage(
          commande: _commande,
          paiement: paiement,
        ),
      ),
    );

    if (result == true) {
      _reloadPaiements();
    }
  }

  Future<void> _supprimerPaiement(Paiement paiement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer le paiement"),
        content: const Text("Voulez-vous vraiment supprimer ce paiement ?"),
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

    await _paiementService.supprimerPaiement(paiement.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Paiement supprimé")),
    );

    _reloadPaiements();
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Détails commande"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_commande.mesureId != null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final Client? client = await ServiceLocator()
                        .clientService
                        .getClientById(_commande.clientId);

                    if (client != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClientDetailPage(client: client),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.straighten),
                  label: const Text(
                    "Voir la mensuration",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            if (_commande.mesureId != null) const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (_commandeService.canStart(_commande))
                  _ActionButton(
                    label: "Démarrer",
                    icon: Icons.play_arrow,
                    color: Colors.blue,
                    onPressed: _demarrerCommande,
                  ),

                if (_commandeService.canEdit(_commande))
                  _ActionButton(
                    label: "Modifier",
                    icon: Icons.edit,
                    color: AppColors.primary,
                    onPressed: _modifierCommande,
                  ),

                if (_commandeService.canFinish(_commande))
                  _ActionButton(
                    label: "Terminer",
                    icon: Icons.check,
                    color: Colors.green,
                    onPressed: _terminerCommande,
                  ),

                if (_commandeService.canCancel(_commande))
                  _ActionButton(
                    label: "Annuler",
                    icon: Icons.cancel,
                    color: Colors.orange,
                    onPressed: _annulerCommande,
                  ),

                if (_commandeService.canDelete(_commande))
                  _ActionButton(
                    label: "Supprimer",
                    icon: Icons.delete,
                    color: Colors.red,
                    onPressed: _supprimerCommande,
                  ),
              ],
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
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _safeValue(_commande.modele, fallback: "Commande"),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StatutCommandeBadge(
                          statut: _commande.statut,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INFOS PRINCIPALES
            ExpandableInfoCard(
              title: "Informations générales",
              collapsedHeight: 170,
              showToggle: false,
              child: Column(
                children: [
                  _InfoRow(
                    label: "Client",
                    value: _client != null
                        ? "${_client!.prenom} ${_client!.nom}"
                        : "Chargement...",
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Prix total",
                    value: "${_commande.prixTotal.toStringAsFixed(0)} FCFA",
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Reste à payer",
                    value: "${_commande.resteAPayer.toStringAsFixed(0)} FCFA",
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Créée le",
                    value: _formatDate(_commande.dateCreation),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Livraison prévue",
                    value: _formatDate(_commande.dateLivraisonPrevue),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: "Livrée le",
                    value: _formatDate(_commande.dateLivraison),
                  ),
                ],
              ),
            ),

            /// PHOTO MODELE
            ExpandableInfoCard(
              title: "Photo du modèle",
              collapsedHeight: 210,
              showToggle: false,
              child: _commande.photoModele != null &&
                  _commande.photoModele!.trim().isNotEmpty
                  ? GestureDetector(
                onTap: () {
                  _showImagePreview(context, _commande.photoModele!);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(_commande.photoModele!),
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        alignment: Alignment.center,
                        child: const Text(
                          "Impossible de charger l'image",
                        ),
                      );
                    },
                  ),
                ),
              )
                  : Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            /// DESCRIPTION
            ExpandableInfoCard(
              title: "Description",
              collapsedHeight: 90,
              showToggle: (_commande.description ?? "").length > 90,
              child: Text(
                _safeValue(
                  _commande.description,
                  fallback: "Aucune description",
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ),

            /// NOTES
            ExpandableInfoCard(
              title: "Notes",
              collapsedHeight: 90,
              showToggle: (_commande.notes ?? "").length > 90,
              child: Text(
                _safeValue(_commande.notes, fallback: "Aucune note"),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ExpandableInfoCard(
              title: "Paiements",
              collapsedHeight: 220,
              showToggle: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _ResumeRow(
                          label: "Total commande",
                          value: "${_commande.prixTotal.toStringAsFixed(0)} FCFA",
                        ),
                        const SizedBox(height: 8),
                        _ResumeRow(
                          label: "Total payé",
                          value: "${_totalPaye.toStringAsFixed(0)} FCFA",
                        ),
                        const SizedBox(height: 8),
                        _ResumeRow(
                          label: "Reste à payer",
                          value: "${_resteAPayer.toStringAsFixed(0)} FCFA",
                          highlight: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _ajouterPaiement,
                      icon: const Icon(Icons.payments),
                      label: const Text("Ajouter un paiement"),
                    ),
                  ),

                  const SizedBox(height: 16),

                  FutureBuilder<List<Paiement>>(
                    future: _paiementsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final paiements = snapshot.data ?? [];

                      if (paiements.isEmpty) {
                        return const Text(
                          "Aucun paiement enregistré",
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textDark,
                          ),
                        );
                      }

                      return Column(
                        children: paiements.map((paiement) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${paiement.montant.toStringAsFixed(0)} FCFA",
                                  style: const TextStyle(
                                    fontSize: 16,
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
                                const SizedBox(height: 4),
                                Text(
                                  "Mode : ${_modePaiementLabel(paiement.modePaiement)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  paiement.notes?.trim().isNotEmpty == true
                                      ? paiement.notes!
                                      : "Aucune note",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _modifierPaiement(paiement),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text("Modifier"),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      onPressed: () => _supprimerPaiement(paiement),
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text("Supprimer"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
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
          width: 110,
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

class _ResumeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ResumeRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.primary : AppColors.textDark;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: color,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}