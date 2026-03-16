import 'dart:io';
import 'package:flutter/material.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/shared/services/client_service.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/utils/app_colors.dart';
import '../../common/utils/app_decoration.dart';


class ClientFormPage extends StatefulWidget {
  final Client? client;

  const ClientFormPage({super.key, this.client});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Sexe _sexe = Sexe.homme;

  File? _photo;

  late ClientService _clientService;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _clientService = ServiceLocator().clientService;

    if (widget.client != null) {
      _nomController.text = widget.client!.nom;
      _prenomController.text = widget.client!.prenom;
      _telephoneController.text = widget.client!.telephone;
      _emailController.text = widget.client!.email ?? '';
      _adresseController.text = widget.client!.adresse ?? '';
      _notesController.text = widget.client!.notes ?? '';
      _sexe = widget.client!.sexe ?? Sexe.homme;

      if (widget.client!.photo != null && widget.client!.photo!.isNotEmpty) {
        _photo = File(widget.client!.photo!);
      }
    }
  }

  Future<void> _pickImage() async {

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _photo = File(picked.path);
      });
    }
  }

  Future<void> _saveClient() async {

    if (!_formKey.currentState!.validate()) return;

    final client = Client(
      id: widget.client?.id,
      nom: _nomController.text,
      prenom: _prenomController.text,
      telephone: _telephoneController.text,
      email: _emailController.text,
      adresse: _adresseController.text,
      sexe: _sexe,
      photo: _photo?.path,
      notes: _notesController.text,
      isVip: widget.client?.isVip ?? false,
      actif: widget.client?.actif ?? true,
      createdAt: widget.client?.createdAt ?? DateTime.now(),
      lastCommandeAt: widget.client?.lastCommandeAt,
    );

    if (widget.client == null) {
      await _clientService.addClient(client);
    } else {
      await _clientService.updateClient(client);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.client == null ? "Nouveau client" : "Modifier client"),
        backgroundColor: AppColors.primary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              /// 📷 PHOTO CLIENT
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    backgroundImage: _photo != null ? FileImage(_photo!) : null,
                    child: _photo == null
                        ? const Icon(
                      Icons.camera_alt,
                      size: 36,
                      color: AppColors.primary,
                    )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// NOM
              TextFormField(
                controller: _nomController,
                decoration: appInputDecoration("Nom"),
                validator: (value) =>
                value == null || value.isEmpty ? "Champ obligatoire" : null,
              ),

              const SizedBox(height: 16),

              /// PRENOM
              TextFormField(
                controller: _prenomController,
                decoration: appInputDecoration("Prénom"),
              ),

              const SizedBox(height: 16),

              /// TELEPHONE
              TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: appInputDecoration("Téléphone"),
              ),

              const SizedBox(height: 16),

              /// EMAIL
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: appInputDecoration("Email"),
              ),

              const SizedBox(height: 16),

              /// ADRESSE
              TextFormField(
                controller: _adresseController,
                decoration: appInputDecoration("Adresse"),
              ),

              const SizedBox(height: 16),

              /// SEXE
              DropdownButtonFormField<Sexe>(
                value: _sexe,
                decoration: appInputDecoration("Sexe"),
                items: const [
                  DropdownMenuItem(
                    value: Sexe.homme,
                    child: Text("Homme"),
                  ),
                  DropdownMenuItem(
                    value: Sexe.femme,
                    child: Text("Femme"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sexe = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              /// NOTES
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: appInputDecoration("Note"),
              ),

              const SizedBox(height: 30),

              /// BOUTON ENREGISTRER
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveClient,
                  child: const Text(
                    "Enregistrer",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}