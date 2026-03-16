import 'package:flutter/material.dart';
import '../common/utils/app_colors.dart';
import '../common/pages/main_navigation_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _navigateToApp();
  }

  void _navigateToApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Couturio',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontFamily: 'Italianno',
                fontSize: 48,
                color: AppColors.textDark,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "L’élégance n’est pas un luxe",
              style: TextStyle(
                color: AppColors.textDark.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}