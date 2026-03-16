import 'package:couturio/data/models/paiement.dart';

enum StatutCommande { enAttente, enCours, termine, livre, annulee }

class Commande {
  final int? id;
  final int clientId;
  final int? mesureId;
  final List<Paiement> paiements;
  final String? modele;
  final String? description;
  final String? photoModele;
  final StatutCommande statut;
  final DateTime dateCreation;
  final DateTime? dateLivraisonPrevue;
  final DateTime? dateLivraison;
  final double prixTotal;
  final String? notes;

  Commande({
    this.id,
    required this.clientId,
    this.mesureId,
    this.modele,
    this.description,
    this.photoModele,
    this.statut = StatutCommande.enAttente,
    DateTime? dateCreation,
    this.dateLivraisonPrevue,
    this.dateLivraison,
    required this.prixTotal,
    this.notes,
    List<Paiement>? paiements,
  })  : dateCreation = dateCreation ?? DateTime.now(),
        paiements = paiements ?? [];

  double get resteAPayer {
    final totalPayes = paiements.fold<double>(
      0.0,
          (sum, Paiement p) => sum + p.montant,
    );
    return prixTotal - totalPayes;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'mesure_id': mesureId,
      'modele': modele,
      'description': description,
      'photo_modele': photoModele,
      'statut': statut.name,
      'date_creation': dateCreation.toIso8601String(),
      'date_livraison_prevue': dateLivraisonPrevue?.toIso8601String(),
      'date_livraison': dateLivraison?.toIso8601String(),
      'prix_total': prixTotal,
      'notes': notes,
    };
  }

  factory Commande.fromMap(Map<String, dynamic> map) {
    return Commande(
      id: map['id'],
      clientId: map['client_id'],
      mesureId: map['mesure_id'],
      modele: map['modele'],
      description: map['description'],
      photoModele: map['photo_modele'],
      statut: map['statut'] != null
          ? StatutCommande.values.firstWhere((e) => e.name == map['statut'])
          : StatutCommande.enAttente,
      dateCreation: DateTime.parse(map['date_creation']),
      dateLivraisonPrevue: map['date_livraison_prevue'] != null
          ? DateTime.parse(map['date_livraison_prevue'])
          : null,
      dateLivraison: map['date_livraison'] != null
          ? DateTime.parse(map['date_livraison'])
          : null,
      prixTotal: map['prix_total'] ?? 0,
      notes: map['notes'],
      paiements: [],
    );
  }
}