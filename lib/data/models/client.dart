enum Sexe { homme, femme }

class Client {
  final int? id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? email;
  final String? adresse;
  final Sexe? sexe;

  final String? photo;
  final String? notes;

  final bool isVip;
  final bool actif;

  final DateTime createdAt;
  final DateTime? lastCommandeAt;

  Client({
    this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.email,
    this.adresse,
    this.sexe,
    this.photo,
    this.notes,
    this.isVip = false,
    this.actif = true,
    DateTime? createdAt,
    this.lastCommandeAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'sexe': sexe?.name,
      'photo': photo,
      'notes': notes,
      'is_vip': isVip ? 1 : 0,
      'actif': actif ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_commande_at': lastCommandeAt?.toIso8601String(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      telephone: map['telephone'],
      email: map['email'],
      adresse: map['adresse'],
      sexe: map['sexe'] != null
          ? Sexe.values.firstWhere((e) => e.name == map['sexe'])
          : null,
      photo: map['photo'],
      notes: map['notes'],
      isVip: map['is_vip'] == 1,
      actif: map['actif'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      lastCommandeAt: map['last_commande_at'] != null
          ? DateTime.parse(map['last_commande_at'])
          : null,
    );
  }
}
