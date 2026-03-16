enum StatutLivraison { enCours, livree, annulee, echec, enAttente }
enum TypeLivraison { standard, express, retraitAtelier }

class Livraison {
  final int? id;
  final int commandeId;
  final DateTime? dateLivraisonEffectuee;
  final StatutLivraison statut;
  final String? livreur;
  final TypeLivraison type;
  final bool rappelEnvoye;
  final bool confirmeParClient;
  final String? instructions;
  final String? notes;

  Livraison({
    this.id,
    required this.commandeId,
    this.dateLivraisonEffectuee,
    this.statut = StatutLivraison.enCours,
    this.livreur,
    this.type = TypeLivraison.standard,
    this.rappelEnvoye = false,
    this.confirmeParClient = false,
    this.instructions,
    this.notes,
  });

  // Sérialisation pour SQLite/JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commande_id': commandeId,
      'date_livraison_effectuee': dateLivraisonEffectuee?.toIso8601String(),
      'statut': statut.name,
      'livreur': livreur,
      'type': type.name,
      'rappel_envoye': rappelEnvoye ? 1 : 0,
      'confirme_par_client': confirmeParClient ? 1 : 0,
      'instructions': instructions,
      'notes': notes,
    };
  }

  factory Livraison.fromMap(Map<String, dynamic> map) {
    return Livraison(
      id: map['id'],
      commandeId: map['commande_id'],
      dateLivraisonEffectuee: map['date_livraison_effectuee'] != null
          ? DateTime.parse(map['date_livraison_effectuee'])
          : null,
      statut: map['statut'] != null
          ? StatutLivraison.values.firstWhere((e) => e.name == map['statut'])
          : StatutLivraison.enCours,
      livreur: map['livreur'],
      type: map['type'] != null
          ? TypeLivraison.values.firstWhere((e) => e.name == map['type'])
          : TypeLivraison.standard,
      rappelEnvoye: map['rappel_envoye'] == 1,
      confirmeParClient: map['confirme_par_client'] == 1,
      instructions: map['instructions'],
      notes: map['notes'],
    );
  }

}
