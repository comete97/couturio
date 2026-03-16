import 'package:flutter/material.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/data/models/mesure.dart';
import 'package:couturio/shared/services/mesure_service.dart';
import '../../common/utils/app_colors.dart';

class MesureFormPage extends StatefulWidget {
  final Client client;
  final Mesure? mesure;

  const MesureFormPage({
    super.key,
    required this.client,
    this.mesure,
  });

  @override
  State<MesureFormPage> createState() => _MesureFormPageState();
}

class _MesureFormPageState extends State<MesureFormPage> {
  final _formKey = GlobalKey<FormState>();

  late MesureService _mesureService;

  // ---------------- HAUT DU CORPS ----------------
  final TextEditingController _poitrineController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _carrureController = TextEditingController();
  final TextEditingController _longueurDosController = TextEditingController();
  final TextEditingController _tourCouController = TextEditingController();
  final TextEditingController _tourTailleHauteController =
  TextEditingController();

  // ---------------- BAS DU CORPS ----------------
  final TextEditingController _hanchesController = TextEditingController();
  final TextEditingController _tourCuisseController = TextEditingController();
  final TextEditingController _longueurPantalonController =
  TextEditingController();
  final TextEditingController _tourTailleBasseController =
  TextEditingController();
  final TextEditingController _tourGenouController = TextEditingController();
  final TextEditingController _tourChevilleController = TextEditingController();
  final TextEditingController _entrejambeController = TextEditingController();

  // ---------------- BRAS ----------------
  final TextEditingController _longueurBrasController = TextEditingController();
  final TextEditingController _tourBrasController = TextEditingController();
  final TextEditingController _poignetController = TextEditingController();
  final TextEditingController _tourAvantBrasController =
  TextEditingController();
  final TextEditingController _longueurEpauleBrasController =
  TextEditingController();
  final TextEditingController _longueurDosBrasController =
  TextEditingController();
  final TextEditingController _longueurMancheController =
  TextEditingController();
  final TextEditingController _tousBicepsController = TextEditingController();
  final TextEditingController _tousEpaulesController = TextEditingController();
  final TextEditingController _longueurAvantBrasController =
  TextEditingController();

  // ---------------- AUTRES ----------------
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mesureService = ServiceLocator().mesureService;
    _prefillIfEdit();
  }

  void _prefillIfEdit() {
    final mesure = widget.mesure;
    if (mesure == null) return;

    _poitrineController.text = _toText(mesure.poitrine);
    _tailleController.text = _toText(mesure.taille);
    _carrureController.text = _toText(mesure.carrure);
    _longueurDosController.text = _toText(mesure.longueurDos);
    _tourCouController.text = _toText(mesure.tourCou);
    _tourTailleHauteController.text = _toText(mesure.tourTailleHaute);

    _hanchesController.text = _toText(mesure.hanches);
    _tourCuisseController.text = _toText(mesure.tourCuisse);
    _longueurPantalonController.text = _toText(mesure.longueurPantalon);
    _tourTailleBasseController.text = _toText(mesure.tourTailleBasse);
    _tourGenouController.text = _toText(mesure.tourGenou);
    _tourChevilleController.text = _toText(mesure.tourCheville);
    _entrejambeController.text = _toText(mesure.entrejambe);

    _longueurBrasController.text = _toText(mesure.longueurBras);
    _tourBrasController.text = _toText(mesure.tourBras);
    _poignetController.text = _toText(mesure.poignet);
    _tourAvantBrasController.text = _toText(mesure.tourAvantBras);
    _longueurEpauleBrasController.text = _toText(mesure.longueurEpauleBras);
    _longueurDosBrasController.text = _toText(mesure.longueurDosBras);
    _longueurMancheController.text = _toText(mesure.longueurManche);
    _tousBicepsController.text = _toText(mesure.tousBiceps);
    _tousEpaulesController.text = _toText(mesure.tousEpaules);
    _longueurAvantBrasController.text = _toText(mesure.longueurAvanBras);

    _descriptionController.text = mesure.description ?? '';
    _notesController.text = mesure.notes ?? '';
  }

  String _toText(double? value) => value?.toString() ?? '';

  double? _parseDouble(String value) {
    final trimmed = value.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
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
        borderSide: const BorderSide(
          color: AppColors.primary,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.3,
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

  Widget _numberField(
      TextEditingController controller,
      String label,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
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
          _sectionTitle(title),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Future<void> _saveMesure() async {
    if (!_formKey.currentState!.validate()) return;

    final mesure = Mesure(
      id: widget.mesure?.id,
      clientId: widget.client.id!,
      // Haut du corps
      poitrine: _parseDouble(_poitrineController.text),
      taille: _parseDouble(_tailleController.text),
      carrure: _parseDouble(_carrureController.text),
      longueurDos: _parseDouble(_longueurDosController.text),
      tourCou: _parseDouble(_tourCouController.text),
      tourTailleHaute: _parseDouble(_tourTailleHauteController.text),

      // Bas du corps
      hanches: _parseDouble(_hanchesController.text),
      tourCuisse: _parseDouble(_tourCuisseController.text),
      longueurPantalon: _parseDouble(_longueurPantalonController.text),
      tourTailleBasse: _parseDouble(_tourTailleBasseController.text),
      tourGenou: _parseDouble(_tourGenouController.text),
      tourCheville: _parseDouble(_tourChevilleController.text),
      entrejambe: _parseDouble(_entrejambeController.text),

      // Bras
      longueurBras: _parseDouble(_longueurBrasController.text),
      tourBras: _parseDouble(_tourBrasController.text),
      poignet: _parseDouble(_poignetController.text),
      tourAvantBras: _parseDouble(_tourAvantBrasController.text),
      longueurEpauleBras: _parseDouble(_longueurEpauleBrasController.text),
      longueurDosBras: _parseDouble(_longueurDosBrasController.text),
      longueurManche: _parseDouble(_longueurMancheController.text),
      tousBiceps: _parseDouble(_tousBicepsController.text),
      tousEpaules: _parseDouble(_tousEpaulesController.text),
      longueurAvanBras: _parseDouble(_longueurAvantBrasController.text),

      // Autres
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),

      date: widget.mesure?.date ?? DateTime.now(),
    );

    if (!_mesureService.validateMesure(mesure)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Certaines valeurs de mensuration sont invalides."),
        ),
      );
      return;
    }

    await _mesureService.saveMesure(mesure);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.mesure == null
              ? "Mensuration enregistrée avec succès"
              : "Mensuration mise à jour avec succès",
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _poitrineController.dispose();
    _tailleController.dispose();
    _carrureController.dispose();
    _longueurDosController.dispose();
    _tourCouController.dispose();
    _tourTailleHauteController.dispose();

    _hanchesController.dispose();
    _tourCuisseController.dispose();
    _longueurPantalonController.dispose();
    _tourTailleBasseController.dispose();
    _tourGenouController.dispose();
    _tourChevilleController.dispose();
    _entrejambeController.dispose();

    _longueurBrasController.dispose();
    _tourBrasController.dispose();
    _poignetController.dispose();
    _tourAvantBrasController.dispose();
    _longueurEpauleBrasController.dispose();
    _longueurDosBrasController.dispose();
    _longueurMancheController.dispose();
    _tousBicepsController.dispose();
    _tousEpaulesController.dispose();
    _longueurAvantBrasController.dispose();

    _descriptionController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mesure != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          isEdit ? "Modifier mensuration" : "Nouvelle mensuration",
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// Client
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

            /// Haut du corps
            _sectionCard(
              title: "Haut du corps",
              children: [
                _numberField(_tourCouController, "Tour de cou"),
                _numberField(_carrureController, "Largeur d'épaules / Carrure"),
                _numberField(_poitrineController, "Tour de poitrine"),
                _numberField(_tailleController, "Tour de taille"),
                _numberField(_tourTailleHauteController, "Tour de taille haute"),
                _numberField(_longueurDosController, "Longueur du dos"),
              ],
            ),

            /// Bas du corps
            _sectionCard(
              title: "Bas du corps",
              children: [
                _numberField(_tourTailleBasseController, "Tour de taille basse"),
                _numberField(_hanchesController, "Tour de hanches"),
                _numberField(_tourCuisseController, "Tour de cuisse"),
                _numberField(_tourGenouController, "Tour de genou"),
                _numberField(_tourChevilleController, "Tour de cheville"),
                _numberField(_entrejambeController, "Entrejambe"),
                _numberField(_longueurPantalonController, "Longueur du pantalon"),
              ],
            ),

            /// Bras
            _sectionCard(
              title: "Bras",
              children: [
                _numberField(_longueurBrasController, "Longueur du bras"),
                _numberField(_tourBrasController, "Tour de bras"),
                _numberField(_poignetController, "Poignet"),
                _numberField(_tourAvantBrasController, "Tour d’avant-bras"),
                _numberField(_longueurEpauleBrasController, "Longueur épaule-bras"),
                _numberField(_longueurDosBrasController, "Longueur dos-bras"),
                _numberField(_longueurMancheController, "Longueur manche"),
                _numberField(_tousBicepsController, "Tour biceps"),
                _numberField(_tousEpaulesController, "Tour épaules"),
                _numberField(_longueurAvantBrasController, "Longueur avant-bras"),
              ],
            ),

            /// Autres mesures
            _sectionCard(
              title: "Autres mesures",
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _inputDecoration("Description"),
                  ),
                ),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: _inputDecoration("Notes"),
                ),
              ],
            ),

            const SizedBox(height: 10),

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
                onPressed: _saveMesure,
                child: Text(
                  isEdit ? "Mettre à jour" : "Enregistrer",
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