import 'package:flutter/material.dart';
import 'package:couturio/shared/services/service_locator.dart';
import 'package:couturio/shared/services/client_service.dart';
import 'package:couturio/data/models/client.dart';
import 'package:couturio/ui/common/utils/app_colors.dart';

class SelectClientForCommandePage extends StatefulWidget {
  const SelectClientForCommandePage({super.key});

  @override
  State<SelectClientForCommandePage> createState() =>
      _SelectClientForCommandePageState();
}

class _SelectClientForCommandePageState
    extends State<SelectClientForCommandePage> {
  late ClientService _clientService;
  late Future<List<Client>> _clientsFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _clientService = ServiceLocator().clientService;
    _clientsFuture = _clientService.getAllClients();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  List<Client> _filterClients(List<Client> clients) {
    if (_searchQuery.isEmpty) return clients;

    return clients.where((client) {
      final nom = client.nom.toLowerCase();
      final prenom = client.prenom.toLowerCase();
      final telephone = client.telephone.toLowerCase();

      return nom.contains(_searchQuery) ||
          prenom.contains(_searchQuery) ||
          telephone.contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Choisir un client"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un client",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                floatingLabelStyle: const TextStyle(color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryDark,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Client>>(
                future: _clientsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erreur lors du chargement des clients"),
                    );
                  }

                  final clients = _filterClients(snapshot.data ?? []);

                  if (clients.isEmpty) {
                    return const Center(
                      child: Text("Aucun client trouvé"),
                    );
                  }

                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text("${client.prenom} ${client.nom}"),
                          subtitle: Text(client.telephone),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(context, client);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}