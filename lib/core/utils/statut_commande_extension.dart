import 'package:flutter/material.dart';
import 'package:couturio/data/models/commande.dart';

extension StatutCommandeExtension on StatutCommande {
  String get label {
    switch (this) {
      case StatutCommande.enAttente:
        return "En attente";
      case StatutCommande.enCours:
        return "En cours";
      case StatutCommande.termine:
        return "Terminé";
      case StatutCommande.livre:
        return "Livré";
      case StatutCommande.annulee:
        return "Annulée";
    }
  }

  Color get color {
    switch (this) {
      case StatutCommande.enAttente:
        return Colors.orange;
      case StatutCommande.enCours:
        return Colors.blue;
      case StatutCommande.termine:
        return Colors.green;
      case StatutCommande.livre:
        return Colors.teal;
      case StatutCommande.annulee:
        return Colors.red;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case StatutCommande.enAttente:
        return Colors.orange.withOpacity(0.15);
      case StatutCommande.enCours:
        return Colors.blue.withOpacity(0.15);
      case StatutCommande.termine:
        return Colors.green.withOpacity(0.15);
      case StatutCommande.livre:
        return Colors.teal.withOpacity(0.15);
      case StatutCommande.annulee:
        return Colors.red.withOpacity(0.15);
    }
  }

  IconData get icon {
    switch (this) {
      case StatutCommande.enAttente:
        return Icons.hourglass_empty;
      case StatutCommande.enCours:
        return Icons.sync;
      case StatutCommande.termine:
        return Icons.check_circle;
      case StatutCommande.livre:
        return Icons.local_shipping;
      case StatutCommande.annulee:
        return Icons.cancel;
    }
  }
}