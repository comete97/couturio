import 'package:flutter/material.dart';
import 'package:couturio/data/models/commande.dart';
import 'package:couturio/core/utils/statut_commande_extension.dart';

class StatutCommandeBadge extends StatelessWidget {
  final StatutCommande statut;

  const StatutCommandeBadge({
    super.key,
    required this.statut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statut.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statut.icon,
            size: 16,
            color: statut.color,
          ),
          const SizedBox(width: 6),
          Text(
            statut.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: statut.color,
            ),
          ),
        ],
      ),
    );
  }
}