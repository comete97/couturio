import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../widgets/app_bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final VoidCallback? onAddPressed;
  final Function(int) onNavTap;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    required this.onNavTap,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(title),
        actions: const [
          Icon(Icons.person),
          SizedBox(width: 12),
          Icon(Icons.more_vert),
          SizedBox(width: 8),
        ],
      ),
      body: body,
      floatingActionButton: onAddPressed != null
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: onAddPressed,
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: onNavTap,
      ),
    );
  }
}
