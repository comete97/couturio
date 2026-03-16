import 'package:couturio/data/repositories/client_repository.dart';
import 'package:couturio/data/repositories/commande_repository.dart';
import 'package:couturio/shared/services/client_service.dart';

import 'package:couturio/shared/services/mesure_service.dart';
import 'package:couturio/data/repositories/mesure_repository.dart';

import 'package:couturio/shared/services/commande_service.dart';
import 'package:couturio/shared/services/livraison_service.dart';
import 'package:couturio/data/repositories/livraison_repository.dart';

import 'package:couturio/data/repositories/dashboard_repository.dart';
import 'package:couturio/shared/services/dashboard_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  /// Repositories
  late final ClientRepository clientRepository;
  late final CommandeRepository commandeRepository;
  late final MesureRepository mesureRepository;
  late final LivraisonRepository livraisonRepository;
  late final DashboardRepository dashboardRepository;

  /// Services
  late final ClientService clientService;
  late final MesureService mesureService;
  late final CommandeService commandeService;
  late final LivraisonService livraisonService;
  late final DashboardService dashboardService;

  /// Initialisation globale
  void init() {
    // Repositories
    clientRepository = ClientRepository();
    commandeRepository = CommandeRepository();
    mesureRepository = MesureRepository();
    livraisonRepository = LivraisonRepository();
    dashboardRepository = DashboardRepository();

    // Services sans dépendance circulaire
    mesureService = MesureService(mesureRepository);

    clientService = ClientService(
      clientRepository,
      commandeRepository,
    );

    commandeService = CommandeService(
      commandeRepository,
    );

    livraisonService = LivraisonService(
      livraisonRepository,
      commandeService,
    );

    dashboardService = DashboardService(dashboardRepository);
  }
}