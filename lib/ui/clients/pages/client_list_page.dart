import 'package:flutter/material.dart';
import '../../common/utils/app_colors.dart';
import '../../../shared/services/client_service.dart';
import '../../../shared/services/service_locator.dart';
import '../../../data/models/client.dart';
import 'client_form_page.dart';
import 'client_detail_page.dart';
import '../../common/widgets/app_bottom_nav.dart';
import 'package:couturio/ui/common/utils/bottom_nav_helper.dart';

class ClientListPage extends StatefulWidget {
  final bool showBottomNav;

  const ClientListPage({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {

  late ClientService _clientService;
  late Future<List<Client>> _clientsFuture;

  @override
  void initState() {
    super.initState();

    _clientService = ServiceLocator().clientService;

    _loadClients();
  }

  void _loadClients() {
    _clientsFuture = _clientService.getAllClients();
  }

  void _refreshClients() {
    setState(() {
      _loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Clients"),
        backgroundColor: AppColors.primary,
      ),

      bottomNavigationBar: widget.showBottomNav
          ? AppBottomNav(
        currentIndex: 2,
        onTap: (index) => handleBottomNav(context, 2, index),
      )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ClientFormPage(),
            ),
          );

          if (result == true) {
            _refreshClients();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// 🔍 Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un client",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📋 Liste des clients
            Expanded(
              child: FutureBuilder<List<Client>>(

                future: _clientsFuture,

                builder: (context, snapshot) {

                  /// Chargement
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  /// Erreur
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Erreur lors du chargement des clients",
                      ),
                    );
                  }

                  final clients = snapshot.data ?? [];

                  /// Aucun client
                  if (clients.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucun client enregistré",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  /// Liste
                  return RefreshIndicator(

                    onRefresh: () async {
                      _refreshClients();
                    },

                    child: ListView.builder(

                      itemCount: clients.length,

                      itemBuilder: (context, index) {

                        final client = clients[index];

                        return Card(
                          color: Colors.white,
                          elevation: 2,

                          margin: const EdgeInsets.only(bottom: 12),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),

                            leading: CircleAvatar(
                              backgroundColor:
                              AppColors.primary.withOpacity(0.15),

                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),

                            title: Text(
                              "${client.prenom} ${client.nom}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),

                            subtitle: Text(
                              client.telephone,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),

                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),

                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClientDetailPage(client: client),
                                ),
                              );

                              if (result == true) {
                                _refreshClients();
                              }
                            },
                          ),
                        );
                      },
                    ),
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