enum ModePaiement {
  especes,
  mobileMoney,
  virement,
}

class Paiement {
  final int? id;
  final int commandeId;
  final double montant;
  final DateTime datePaiement;
  final String? notes;
  final ModePaiement modePaiement;

  Paiement({
    this.id,
    required this.commandeId,
    required this.montant,
    DateTime? datePaiement,
    this.notes,
    this.modePaiement = ModePaiement.especes,
  }) : datePaiement = datePaiement ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commande_id': commandeId,
      'montant': montant,
      'date_paiement': datePaiement.toIso8601String(),
      'notes': notes,
      'mode_paiement': modePaiement.name,
    };
  }

  factory Paiement.fromMap(Map<String, dynamic> map) {
    return Paiement(
      id: map['id'],
      commandeId: map['commande_id'],
      montant: (map['montant'] as num).toDouble(),
      datePaiement: DateTime.parse(map['date_paiement']),
      notes: map['notes'],
      modePaiement: map['mode_paiement'] != null
          ? ModePaiement.values.firstWhere(
            (e) => e.name == map['mode_paiement'],
      )
          : ModePaiement.especes,
    );
  }
}