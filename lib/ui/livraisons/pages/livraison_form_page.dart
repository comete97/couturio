import 'package:flutter/material.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/data/models/livraison.dart';
import 'package:couturio/shared/services/livraison_service.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';

class LivraisonFormPage extends StatefulWidget {
  final Commande commande;

  const LivraisonFormPage({
    super.key,
    required this.commande,
  });

  @override
  State<LivraisonFormPage> createState() => _LivraisonFormPageState();
}

class _LivraisonFormPageState extends State<LivraisonFormPage> {
  final _formKey = GlobalKey<FormState>();

  late LivraisonService _livraisonService;

  final TextEditingController _livreurController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  TypeLivraison _typeLivraison = TypeLivraison.standard;

  @override
  void initState() {
    super.initState();
    _livraisonService = ServiceLocator().livraisonService;
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

  Future<void> _saveLivraison() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _livraisonService.creerLivraison(
        commandeId: widget.commande.id!,
        type: _typeLivraison,
        livreur: _livreurController.text.trim(),
        instructions: _instructionsController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Livraison créée")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
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
    _livreurController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Nouvelle livraison"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: "Commande",
              children: [
                Text(
                  widget.commande.modele?.isNotEmpty == true
                      ? widget.commande.modele!
                      : "Commande #${widget.commande.id}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            _sectionCard(
              title: "Informations de livraison",
              children: [
                DropdownButtonFormField<TypeLivraison>(
                  value: _typeLivraison,
                  decoration: _inputDecoration("Type de livraison"),
                  items: TypeLivraison.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_typeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _typeLivraison = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _livreurController,
                  decoration: _inputDecoration("Livreur"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Entrez le nom du livreur";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 3,
                  decoration: _inputDecoration("Instructions"),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
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
                onPressed: _saveLivraison,
                child: const Text(
                  "Enregistrer la livraison",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}