class Paiement {
  final int? id;
  final int commandeId;

  final double montant;
  final DateTime datePaiement;
  final String? notes;

  Paiement({
    this.id,
    required this.commandeId,
    required this.montant,
    DateTime? datePaiement,
    this.notes,
  }) : datePaiement = datePaiement ?? DateTime.now();

  // Conversion en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commande_id': commandeId,
      'montant': montant,
      'date_paiement': datePaiement.toIso8601String(),
      'notes': notes,
    };
  }

  // Reconstruction depuis Map
  factory Paiement.fromMap(Map<String, dynamic> map) {
    return Paiement(
      id: map['id'],
      commandeId: map['commande_id'],
      montant: map['montant'],
      datePaiement: DateTime.parse(map['date_paiement']),
      notes: map['notes'],
    );
  }
}
