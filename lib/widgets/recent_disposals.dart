import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/admin_controller.dart';

class RecentDisposals extends StatelessWidget {
  final AdminController controller;

  const RecentDisposals({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descartes Recentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: controller.getDisposalsStream(limit: 10),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('Nenhum descarte encontrado');
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final materials = data['materials'] as List<dynamic>? ?? [];
                    final createdAt = data['createdAt'] as Timestamp?;
                    final location = data['location'] as Map<String, dynamic>?;

                    return FutureBuilder<String>(
                      future: controller.getAddressFromLatLng(
                        location?['latitude'],
                        location?['longitude'],
                      ),
                      builder: (context, addressSnapshot) {
                        final address =
                            addressSnapshot.data ?? 'Carregando endereço...';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            title: Text(
                              'Materiais: ${materials.join(", ")}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (createdAt != null)
                                  Text('Data: ${_formatDate(createdAt.toDate())}'),
                                Text('Endereço: $address'),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'details',
                                  child: Text('Ver Detalhes'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Excluir'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteDisposal(context, doc.id);
                                } else if (value == 'details') {
                                  _showDisposalDetails(context, data, address);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _deleteDisposal(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este descarte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteDisposal(docId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Descarte excluído com sucesso')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showDisposalDetails(
      BuildContext context, Map<String, dynamic> data, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Descarte'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Materiais: ${(data['materials'] as List<dynamic>?)?.join(", ") ?? "N/A"}'),
              const SizedBox(height: 8),
              Text('Usuário ID: ${data['userId'] ?? "N/A"}'),
              const SizedBox(height: 8),
              Text('Endereço: $address'),
              const SizedBox(height: 8),
              if (data['createdAt'] != null)
                Text(
                    'Data: ${_formatDate((data['createdAt'] as Timestamp).toDate())}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
