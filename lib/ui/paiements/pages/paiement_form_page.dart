import 'package:flutter/material.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/data/models/paiement.dart';
import 'package:couturio/shared/services/paiement_service.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';

class PaiementFormPage extends StatefulWidget {
  final Commande commande;
  final Paiement? paiement;

  const PaiementFormPage({
    super.key,
    required this.commande,
    this.paiement,
  });

  @override
  State<PaiementFormPage> createState() => _PaiementFormPageState();
}

class _PaiementFormPageState extends State<PaiementFormPage> {
  final _formKey = GlobalKey<FormState>();

  late PaiementService _paiementService;

  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool get isEditing => widget.paiement != null;

  ModePaiement _modePaiement = ModePaiement.especes;
  double _totalPaye = 0;
  double _reste = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _paiementService = ServiceLocator().paiementService;

    if (isEditing) {
      _montantController.text = widget.paiement!.montant.toString();
      _notesController.text = widget.paiement!.notes ?? '';
      _modePaiement = widget.paiement!.modePaiement;
    }

    _loadResume();
  }

  Future<void> _loadResume() async {
    final totalPaye =
    await _paiementService.totalPayePourCommande(widget.commande.id!);

    double reste = widget.commande.prixTotal - totalPaye;

    if (isEditing) {
      reste += widget.paiement!.montant;
    }

    if (!mounted) return;

    setState(() {
      _totalPaye = totalPaye;
      _reste = reste;
      _isLoading = false;
    });
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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

  Future<void> _savePaiement() async {
    if (!_formKey.currentState!.validate()) return;

    final montant = double.tryParse(
      _montantController.text.trim().replaceAll(',', '.'),
    );

    if (montant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un montant valide."),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (isEditing) {
        final paiement = Paiement(
          id: widget.paiement!.id,
          commandeId: widget.commande.id!,
          montant: montant,
          datePaiement: widget.paiement!.datePaiement,
          notes: _notesController.text.trim(),
          modePaiement: _modePaiement,
        );

        await _paiementService.modifierPaiement(paiement);
      } else {
        final paiement = Paiement(
          commandeId: widget.commande.id!,
          montant: montant,
          notes: _notesController.text.trim(),
          modePaiement: _modePaiement,
        );

        await _paiementService.ajouterPaiement(paiement);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? "Paiement mis à jour" : "Paiement enregistré",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titreCommande = widget.commande.modele?.trim().isNotEmpty == true
        ? widget.commande.modele!
        : "Commande #${widget.commande.id}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          isEditing ? "Modifier paiement" : "Nouveau paiement",
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: "Commande",
              children: [
                Text(
                  titreCommande,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _ResumeRow(
                  label: "Total commande",
                  value: _formatMoney(widget.commande.prixTotal),
                ),
                const SizedBox(height: 8),
                _ResumeRow(
                  label: "Déjà payé",
                  value: _formatMoney(_totalPaye),
                ),
                const SizedBox(height: 8),
                _ResumeRow(
                  label: "Reste à payer",
                  value: _formatMoney(_reste),
                  isHighlight: true,
                ),
              ],
            ),
            _sectionCard(
              title: "Informations du paiement",
              children: [
                TextFormField(
                  controller: _montantController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration("Montant"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Entrez un montant";
                    }
                    final montant = double.tryParse(
                      value.trim().replaceAll(',', '.'),
                    );
                    if (montant == null) {
                      return "Montant invalide";
                    }
                    if (montant <= 0) {
                      return "Le montant doit être supérieur à zéro";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ModePaiement>(
                  value: _modePaiement,
                  decoration: _inputDecoration("Mode de paiement"),
                  items: ModePaiement.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(_modePaiementLabel(mode)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _modePaiement = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: _inputDecoration("Notes"),
                ),
              ],
            ),
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
                onPressed: _isSaving ? null : _savePaiement,
                child: Text(
                  _isSaving
                      ? "Enregistrement..."
                      : isEditing
                      ? "Mettre à jour le paiement"
                      : "Enregistrer le paiement",
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

class _ResumeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _ResumeRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHighlight ? AppColors.primary : AppColors.textDark;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: color,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}