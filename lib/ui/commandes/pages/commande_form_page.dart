import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/data/models/mesure.dart';

import 'package:couturio/shared/services/commande_service.dart';
import 'package:couturio/shared/services/mesure_service.dart';
import '../../common/utils/app_colors.dart';

class CommandeFormPage extends StatefulWidget {
  final Client client;
  final Commande? commande;

  const CommandeFormPage({
    super.key,
    required this.client,
    this.commande,
  });

  @override
  State<CommandeFormPage> createState() => _CommandeFormPageState();
}

class _CommandeFormPageState extends State<CommandeFormPage> {
  final _formKey = GlobalKey<FormState>();

  late CommandeService _commandeService;
  late MesureService _mesureService;

  bool get isEditing => widget.commande != null;

  Mesure? _mesure;

  final TextEditingController _modeleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _dateLivraison;
  File? _photo;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _commandeService = ServiceLocator().commandeService;
    _mesureService = ServiceLocator().mesureService;

    _loadMesure();

    if (isEditing) {
      final c = widget.commande!;

      _modeleController.text = c.modele ?? '';
      _descriptionController.text = c.description ?? '';
      _prixController.text = c.prixTotal.toString();
      _notesController.text = c.notes ?? '';
      _dateLivraison = c.dateLivraisonPrevue;

      if (c.photoModele != null && c.photoModele!.trim().isNotEmpty) {
        _photo = File(c.photoModele!);
      }
    }
  }

  Future<void> _loadMesure() async {
    final mesure = await _mesureService.getLastMesureByClient(widget.client.id!);

    if (!mounted) return;

    setState(() {
      _mesure = mesure;
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        _photo = File(picked.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateLivraison ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateLivraison = picked;
      });
    }
  }

  Future<void> _saveCommande() async {
    if (!_formKey.currentState!.validate()) return;

    final prix = double.tryParse(
      _prixController.text.trim().replaceAll(',', '.'),
    );

    if (prix == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un prix valide."),
        ),
      );
      return;
    }

    if (isEditing) {
      final updatedCommande = Commande(
        id: widget.commande!.id,
        clientId: widget.client.id!,
        mesureId: _mesure?.id ?? widget.commande!.mesureId,
        modele: _modeleController.text.trim(),
        description: _descriptionController.text.trim(),
        photoModele: _photo?.path,
        statut: widget.commande!.statut,
        dateCreation: widget.commande!.dateCreation,
        dateLivraisonPrevue: _dateLivraison,
        dateLivraison: widget.commande!.dateLivraison,
        prixTotal: prix,
        notes: _notesController.text.trim(),
        paiements: widget.commande!.paiements,
      );

      await _commandeService.updateCommande(updatedCommande);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Commande mise à jour"),
        ),
      );
    } else {
      final newCommande = Commande(
        clientId: widget.client.id!,
        mesureId: _mesure?.id,
        modele: _modeleController.text.trim(),
        description: _descriptionController.text.trim(),
        photoModele: _photo?.path,
        prixTotal: prix,
        dateLivraisonPrevue: _dateLivraison,
        notes: _notesController.text.trim(),
      );

      await _commandeService.creerCommande(newCommande);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Commande enregistrée"),
        ),
      );
    }

    Navigator.pop(context, true);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
      ),
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
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _modeleController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          isEditing ? "Modifier commande" : "Nouvelle commande",
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// CLIENT
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${widget.client.nom.toUpperCase()} ${widget.client.prenom}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// INFOS COMMANDE
            _sectionCard(
              title: "Informations de la commande",
              children: [
                TextFormField(
                  controller: _modeleController,
                  decoration: _inputDecoration("Modèle"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Entrez le modèle";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration("Description"),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prixController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration("Prix total"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Entrez un prix";
                    }
                    if (double.tryParse(value.trim().replaceAll(',', '.')) == null) {
                      return "Prix invalide";
                    }
                    return null;
                  },
                ),
              ],
            ),

            /// LIVRAISON
            _sectionCard(
              title: "Livraison",
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _dateLivraison == null
                        ? "Choisir date de livraison"
                        : "${_dateLivraison!.day.toString().padLeft(2, '0')}/${_dateLivraison!.month.toString().padLeft(2, '0')}/${_dateLivraison!.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
              ],
            ),

            /// PHOTO MODELE
            _sectionCard(
              title: "Photo du modèle",
              children: [
                if (_photo != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _photo!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: Text(
                    _photo == null ? "Choisir une photo" : "Changer la photo",
                  ),
                ),
              ],
            ),

            /// NOTES
            _sectionCard(
              title: "Notes",
              children: [
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: _inputDecoration("Instructions spéciales"),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ENREGISTRER / METTRE À JOUR
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saveCommande,
                child: Text(
                  isEditing ? "Mettre à jour la commande" : "Enregistrer la commande",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}