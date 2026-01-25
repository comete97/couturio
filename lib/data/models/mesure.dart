class Mesure {
  final int? id;
  final int clientId;

  // Haut du corps
  final double? poitrine;
  final double? taille;
  final double? carrure;
  final double? longueurDos;
  final double? tourCou;
  final double? tourTailleHaute;
  

  // Bas du corps
  final double? hanches;
  final double? tourCuisse;
  final double? longueurPantalon;
  final double? tourTailleBasse;
  final double? tourGenou;
  final double? tourCheville;
  final double? entrejambe;


  // Bras
  final double? longueurBras;
  final double? tourBras;
  final double? poignet;
  final double? tourAvantBras;
  final double? longueurEpauleBras;
  final double? longueurDosBras;
  final double? longueurManche;
  final double? tousBiceps;
  final double? tousEpaules;
  final double? longueurAvanBras;

  // Champ libre / description
  final String? description;
  final String? notes;

  // Date de la mesure
  final DateTime date;

  Mesure({
    this.id,
    required this.clientId,
    this.poitrine,
    this.tourCou,
    this.tourTailleHaute,
    this.tourTailleBasse,
    this.tourGenou,
    this.tourCheville,
    this.entrejambe,
    this.longueurEpauleBras,
    this.longueurDosBras,
    this.longueurManche,
    this.tousBiceps,
    this.tousEpaules,
    this.longueurAvanBras,
    this.tourAvantBras,
    this.taille,
    this.carrure,
    this.longueurDos,
    this.hanches,
    this.tourCuisse,
    this.longueurPantalon,
    this.longueurBras,
    this.tourBras,
    this.poignet,
    this.description,
    this.notes,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  // Conversion en Map (pour SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'poitrine': poitrine,
      'tour_cou': tourCou,
      'tour_taille_haute': tourTailleHaute,
      'tour_taille_basse': tourTailleBasse,
      'tour_genou': tourGenou,
      'tour_cheville': tourCheville,
      'entrejambe': entrejambe,
      'longueur_epaule_bras': longueurEpauleBras,
      'longueur_dos_bras': longueurDosBras,
      'longueur_maniere': longueurManche,
      'tous_biceps': tousBiceps,
      'tous_epaules': tousEpaules,
      'longueur_avant_bras': longueurAvanBras,
      'tour_avant_bras': tourAvantBras,
      'taille': taille,
      'carrure': carrure,
      'longueur_dos': longueurDos,
      'hanches': hanches,
      'tour_cuisse': tourCuisse,
      'longueur_pantalon': longueurPantalon,
      'longueur_bras': longueurBras,
      'tour_bras': tourBras,
      'poignet': poignet,
      'description': description,
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }

  // Reconstruction à partir de Map (SQLite)
  factory Mesure.fromMap(Map<String, dynamic> map) {
    return Mesure(
      id: map['id'],
      clientId: map['client_id'],
      poitrine: map['poitrine'],
      tourCou: map['tour_cou'],
      tourTailleHaute: map['tour_taille_haute'],
      tourTailleBasse: map['tour_taille_basse'],
      tourGenou: map['tour_genou'],
      tourCheville: map['tour_cheville'],
      entrejambe: map['entrejambe'],
      longueurEpauleBras: map['longueur_epaule_bras'],
      longueurDosBras: map['longueur_dos_bras'],
      longueurManche: map['longueur_maniere'],
      tousBiceps: map['tous_biceps'],
      tousEpaules: map['tous_epaules'],
      longueurAvanBras: map['longueur_avant_bras'],
      tourAvantBras: map['tour_avant_bras'],
      taille: map['taille'],
      carrure: map['carrure'],
      longueurDos: map['longueur_dos'],
      hanches: map['hanches'],
      tourCuisse: map['tour_cuisse'],
      longueurPantalon: map['longueur_pantalon'],
      longueurBras: map['longueur_bras'],
      tourBras: map['tour_bras'],
      poignet: map['poignet'],
      description: map['description'],
      notes: map['notes'],
      date: DateTime.parse(map['date']),
    );
  }
}
