// fonction d'aide à la navigation dans le menu de bas de page

import 'package:flutter/material.dart';
import 'package:couturio/ui/dashboard/pages/dashboard_page.dart';
import 'package:couturio/ui/clients/pages/client_list_page.dart';
import 'package:couturio/ui/commandes/pages/commande_list_page.dart';
import 'package:couturio/ui/livraisons/pages/livraison_list_page.dart';

void handleBottomNav(BuildContext context, int currentIndex, int newIndex) {
  if (currentIndex == newIndex) return;

  Widget page;

  switch (newIndex) {
    case 0:
      page = const DashboardPage();
      break;
    case 1:
      page = const CommandeListPage();
      break;
    case 2:
      page = const ClientListPage();
      break;
    case 3:
      page = const LivraisonListPage();
      break;
    default:
      page = const DashboardPage();
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => page),
  );
}