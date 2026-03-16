import 'dart:io';

import 'package:flutter/material.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/data/models/mesure.dart';
import 'package:couturio/shared/services/mesure_service.dart';
import '../../common/utils/app_colors.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/shared/services/commande_service.dart';
import 'client_form_page.dart';
import 'mesure_form_page.dart';
import '../../commandes/pages/commande_form_page.dart';
//import '../../../core/utils/statut_commande_extension.dart';
import '../../commandes/pages/commande_detail_page.dart';
import '../../commandes/widgets/statut_commande_badge.dart';
import '../../common/widgets/expandable_info_card.dart';

class ClientDetailPage extends StatefulWidget {
  final Client client;

  const ClientDetailPage({
    super.key,
    required this.client,
  });

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  late MesureService _mesureService;
  late Future<Mesure?> _mesureFuture;
  late CommandeService _commandeService;
  late Future<List<Commande>> _commandesFuture;

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  void initState() {
    super.initState();
    _mesureService = ServiceLocator().mesureService;
    _mesureFuture = _mesureService.getLastMesureByClient(widget.client.id!);

    _commandeService = ServiceLocator().commandeService;
    _commandesFuture = _commandeService.getCommandesByClient(widget.client.id!);
  }

  String _formatSexe() {
    if (widget.client.sexe == null) return "Non renseigné";
    return widget.client.sexe.toString().split('.').last;
  }

  String _safeValue(String? value, {String fallback = "Non renseigné"}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }

  String _mesureValue(double? value) {
    return value != null ? "${value.toString()} cm" : "-";
  }

  Future<void> _deleteClient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer le client"),
          content: const Text(
            "Voulez-vous vraiment supprimer ce client ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
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
        );
      },
    );

    if (confirm != true) return;

    await ServiceLocator().clientService.deleteClient(widget.client.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Client supprimé avec succès"),
      ),
    );

    Navigator.pop(context, true);
  }

  void _reloadMesure() {
    setState(() {
      _mesureFuture = _mesureService.getLastMesureByClient(widget.client.id!);
    });
  }
  void _reloadCommandes() {
    setState(() {
      _commandesFuture =
          _commandeService.getCommandesByClient(widget.client.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Détails client"),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommandeFormPage(client: widget.client),
            ),
          );

          if (result == true) {
            _reloadCommandes();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Commande"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// EN-TÊTE CLIENT
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${client.nom.toUpperCase()} ${client.prenom}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientFormPage(client: widget.client),
                              ),
                            );

                            if (result == true && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                          child: const Text("Modifier"),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child:   SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                          ),
                          onPressed: _deleteClient,
                          child: const Text("Supprimer"),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textDark,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                    ),
                ),
                  onPressed: () async {
                    final mesureExistante =
                    await _mesureService.getLastMesureByClient(widget.client.id!);

                    if (!mounted) return;

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MesureFormPage(
                          client: widget.client,
                          mesure: mesureExistante,
                        ),
                      ),
                    );

                    if (result == true) {
                      _reloadMesure();
                    }
                  },

                  child: const Text("Mensuration"),
                  ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            /// CARD IDENTITÉ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Identité du client",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        backgroundImage:
                        client.photo != null && client.photo!.isNotEmpty
                            ? FileImage(File(client.photo!))
                            : null,
                        child: client.photo == null || client.photo!.isEmpty
                            ? const Icon(
                          Icons.person,
                          size: 46,
                          color: AppColors.primary,
                        )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(label: "Nom", value: client.nom),
                            const SizedBox(height: 8),
                            _InfoRow(label: "Prénom", value: client.prenom),
                            const SizedBox(height: 8),
                            _InfoRow(label: "Genre", value: _formatSexe()),
                            const SizedBox(height: 8),
                            _InfoRow(label: "Contact", value: client.telephone),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: "Adresse",
                              value: _safeValue(client.adresse),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// CARD MENSURATIONS
            FutureBuilder<Mesure?>(
              future: _mesureFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final mesure = snapshot.data;

                return ExpandableInfoCard(
                  title: "Mensuration",
                  collapsedHeight: 190,
                  showToggle: mesure != null,
                  child: mesure == null
                      ? const Text(
                    "Aucune mensuration enregistrée",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Haut du corps",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Divider(),
                      _MeasureRow(label: "Tour de cou", value: _mesureValue(mesure.tourCou)),
                      _MeasureRow(label: "Largeur d'épaules", value: _mesureValue(mesure.carrure)),
                      _MeasureRow(label: "Tour de poitrine", value: _mesureValue(mesure.poitrine)),
                      _MeasureRow(label: "Tour de taille", value: _mesureValue(mesure.taille)),
                      _MeasureRow(label: "Longueur du dos", value: _mesureValue(mesure.longueurDos)),

                      const SizedBox(height: 12),
                      const Text(
                        "Bas du corps",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Divider(),
                      _MeasureRow(label: "Tour de taille basse", value: _mesureValue(mesure.tourTailleBasse)),
                      _MeasureRow(label: "Tour de hanches", value: _mesureValue(mesure.hanches)),
                      _MeasureRow(label: "Tour de cuisse", value: _mesureValue(mesure.tourCuisse)),
                      _MeasureRow(label: "Tour de genou", value: _mesureValue(mesure.tourGenou)),
                      _MeasureRow(label: "Tour de cheville", value: _mesureValue(mesure.tourCheville)),
                      _MeasureRow(label: "Longueur du pantalon", value: _mesureValue(mesure.longueurPantalon)),

                      const SizedBox(height: 12),
                      const Text(
                        "Bras",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Divider(),
                      _MeasureRow(label: "Longueur bras", value: _mesureValue(mesure.longueurBras)),
                      _MeasureRow(label: "Tour de bras", value: _mesureValue(mesure.tourBras)),
                      _MeasureRow(label: "Poignet", value: _mesureValue(mesure.poignet)),
                      _MeasureRow(label: "Avant-bras", value: _mesureValue(mesure.tourAvantBras)),
                      _MeasureRow(label: "Longueur manche", value: _mesureValue(mesure.longueurManche)),

                      const SizedBox(height: 12),
                      const Text(
                        "Autres mensurations",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Divider(),
                      Text(
                        mesure.description?.isNotEmpty == true
                            ? mesure.description!
                            : "Aucune description",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        "Notes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Divider(),
                      Text(
                        mesure.notes?.isNotEmpty == true
                            ? mesure.notes!
                            : "Aucune note",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// NOTES
            ExpandableInfoCard(
              title: "Notes",
              collapsedHeight: 80,
              showToggle: client.notes != null && client.notes!.length > 40,
              child: Text(
                _safeValue(client.notes, fallback: "Aucune note"),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// COMMANDES
            FutureBuilder<List<Commande>>(
              future: _commandesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final commandes = snapshot.data ?? [];

                return ExpandableInfoCard(
                  title: "Commandes",
                  collapsedHeight: 260,
                  showToggle: commandes.isNotEmpty,
                  child: commandes.isEmpty
                      ? const Text(
                    "Aucune commande enregistrée",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  )
                      : Column(
                    children: List.generate(commandes.length, (index) {
                      final commande = commandes[index];
                      final isLast = index == commandes.length - 1;

                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommandeDetailPage(commande: commande),
                            ),
                          );

                          if (result == true) {
                            _reloadCommandes();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  if (!isLast)
                                    Container(
                                      width: 2,
                                      height: 110,
                                      color: AppColors.primary.withOpacity(0.35),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        commande.modele?.isNotEmpty == true
                                            ? commande.modele!
                                            : "Modèle non renseigné",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(commande.dateCreation),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Prix total : ${commande.prixTotal.toStringAsFixed(0)} FCFA",
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
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
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
          width: 75,
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

class _MeasureRow extends StatelessWidget {
  final String label;
  final String value;

  const _MeasureRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}