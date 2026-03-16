import 'package:flutter/material.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';

class DashboardHeroCard extends StatelessWidget {
  final VoidCallback onAddCommande;
  final VoidCallback onAddClient;

  const DashboardHeroCard({
    super.key,
    required this.onAddCommande,
    required this.onAddClient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          /// Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Natitingou",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Meilleur gestion des commande et des retard de votre atelier",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    _ActionButton(
                      label: "Ajouter une commande",
                      onTap: onAddCommande,
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      label: "Ajouter un client",
                      onTap: onAddClient,
                    ),
                  ],
                )
              ],
            ),
          ),

          /// Illustration
          const SizedBox(width: 10),

          Icon(
            Icons.checkroom,
            size: 80,
            color: Colors.white.withOpacity(0.9),
          )
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }
}