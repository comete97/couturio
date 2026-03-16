import 'package:couturio/data/models/mesure.dart';
import 'package:couturio/data/repositories/mesure_repository.dart';

class MesureService {
  final MesureRepository _repo = MesureRepository();

  MesureService(MesureRepository mesureRepository);

  // ----------------------- AJOUTER OU METTRE À JOUR -----------------------
  /// Si le client a déjà une mesure, elle est mise à jour sinon une nouvelle est créée
  Future<int> saveMesure(Mesure mesure) async {
    if (mesure.id != null) {
      return await _repo.updateMesure(mesure);
    } else {
      return await _repo.insertMesure(mesure);
    }
  }

  // ----------------------- OBTENIR MESURE PAR ID -----------------------
  Future<Mesure?> getMesureById(int id) async {
    return await _repo.getMesureById(id);
  }

  // ----------------------- OBTENIR LA DERNIÈRE MESURE D’UN CLIENT -----------------------
  Future<Mesure?> getLastMesureByClient(int clientId) async {
    return await _repo.getLastMesureByClient(clientId);
  }

  // ----------------------- OBTENIR TOUTES LES MESURES D’UN CLIENT -----------------------
  Future<List<Mesure>> getMesuresByClient(int clientId) async {
    return await _repo.getMesuresByClient(clientId);
  }

  // ----------------------- SUPPRIMER UNE MESURE -----------------------
  Future<int> deleteMesure(int id) async {
    return await _repo.deleteMesure(id);
  }

  // ----------------------- FILTRAGE TEMPOREL -----------------------
  /// Récupérer toutes les mesures prises dans une période donnée
  Future<List<Mesure>> getMesuresBetween(DateTime start, DateTime end) async {
    final allMesures = await _repo.getAllMesures();
    return allMesures
        .where((m) => m.date.isAfter(start) && m.date.isBefore(end))
        .toList();
  }

  // ----------------------- STATISTIQUES SUR LES MESURES -----------------------
  /// Par exemple, calculer la moyenne de la taille des clients
  Future<double> averageTaille() async {
    final allMesures = await _repo.getAllMesures();
    final tailles = allMesures.where((m) => m.taille != null).map((m) => m.taille!);
    if (tailles.isEmpty) return 0;
    final sum = tailles.reduce((a, b) => a + b);
    return sum / tailles.length;
  }

  // ----------------------- VALIDATION -----------------------
  /// Vérifie que les mesures sont cohérentes (ex: pas de valeurs négatives)
  bool validateMesure(Mesure mesure) {
    if (mesure.taille != null && mesure.taille! <= 0) return false;
    if (mesure.poitrine != null && mesure.poitrine! <= 0) return false;
    if (mesure.hanches != null && mesure.hanches! <= 0) return false;
    // Ajouter d’autres validations si nécessaire
    return true;
  }

  // ----------------------- RECHERCHE -----------------------
  Future<List<Mesure>> searchMesures(String query) async {
    return await _repo.searchMesures(query);
  }
}
