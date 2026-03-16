import 'package:flutter/material.dart';
import 'package:couturio/data/models/livraison.dart';

extension StatutLivraisonExtension on StatutLivraison {

  String get label {
    switch (this) {
      case StatutLivraison.enAttente:
        return "En attente";
      case StatutLivraison.enCours:
        return "En cours";
      case StatutLivraison.livree:
        return "Livrée";
      case StatutLivraison.annulee:
        return "Annulée";
      case StatutLivraison.echec:
        return "Échec";
    }
  }

  Color get color {
    switch (this) {
      case StatutLivraison.enAttente:
        return Colors.blueGrey;
      case StatutLivraison.enCours:
        return Colors.orange;
      case StatutLivraison.livree:
        return Colors.green;
      case StatutLivraison.annulee:
        return Colors.red;
      case StatutLivraison.echec:
        return Colors.deepOrange;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case StatutLivraison.enAttente:
        return Colors.blueGrey.withOpacity(0.15);
      case StatutLivraison.enCours:
        return Colors.orange.withOpacity(0.15);
      case StatutLivraison.livree:
        return Colors.green.withOpacity(0.15);
      case StatutLivraison.annulee:
        return Colors.red.withOpacity(0.15);
      case StatutLivraison.echec:
        return Colors.deepOrange.withOpacity(0.15);
    }
  }

  IconData get icon {
    switch (this) {
      case StatutLivraison.enAttente:
        return Icons.schedule;
      case StatutLivraison.enCours:
        return Icons.local_shipping;
      case StatutLivraison.livree:
        return Icons.check_circle;
      case StatutLivraison.annulee:
        return Icons.cancel;
      case StatutLivraison.echec:
        return Icons.error;
    }
  }
}