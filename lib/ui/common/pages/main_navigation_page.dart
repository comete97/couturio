import 'package:flutter/material.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';
import 'package:couturio/ui/common/widgets/app_bottom_nav.dart';
import 'package:couturio/ui/dashboard/pages/dashboard_page.dart';
import 'package:couturio/ui/clients/pages/client_list_page.dart';
import 'package:couturio/ui/commandes/pages/commande_list_page.dart';
import 'package:couturio/ui/livraisons/pages/livraison_list_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;

  const MainNavigationPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _pages = const [
      DashboardPage(showBottomNav: false),
      CommandeListPage(showBottomNav: false),
      ClientListPage(showBottomNav: false),
      LivraisonListPage(showBottomNav: false),
    ];
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}