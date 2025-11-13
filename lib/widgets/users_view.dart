import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/admin_controller.dart';
import 'stat_card.dart';

class UsersView extends StatelessWidget {
  final AdminController controller;

  const UsersView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gerenciamento de Usuários',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Adicionar Usuário'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildUserStats(),
          const SizedBox(height: 30),
          _buildUsersTable(context),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getUsersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final users = snapshot.data!.docs;
        final admins = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isAdmin'] == true;
        }).length;
        final normalUsers = users.length - admins;

        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total de Usuários',
                value: users.length.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Administradores',
                value: admins.toString(),
                icon: Icons.admin_panel_settings,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Usuários Normais',
                value: normalUsers.toString(),
                icon: Icons.person,
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsersTable(BuildContext context) {
    return Card(
      elevation: 4,
      child: StreamBuilder<QuerySnapshot>(
        stream: controller.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(50.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(50.0),
              child: Center(
                child: Text(
                  'Nenhum usuário cadastrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.green[50]),
              columns: const [
                DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('CPF', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Telefone', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Endereço', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Admin', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Data Cadastro', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final isAdmin = data['isAdmin'] == true;
                final createdAt = data['createdAt'] as Timestamp?;

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isAdmin ? Colors.orange : Colors.green,
                            child: Text(
                              (data['nome_completo'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(data['nome_completo'] ?? 'N/A'),
                        ],
                      ),
                    ),
                    DataCell(Text(data['email'] ?? 'N/A')),
                    DataCell(Text(data['cpf'] ?? 'N/A')),
                    DataCell(Text(data['telefone'] ?? 'N/A')),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          data['endereco'] ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    DataCell(
                      Chip(
                        label: Text(
                          isAdmin ? 'Admin' : 'Usuário',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: isAdmin ? Colors.orange[100] : Colors.green[100],
                        avatar: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          size: 16,
                          color: isAdmin ? Colors.orange[800] : Colors.green[800],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        createdAt != null
                            ? _formatDate(createdAt.toDate())
                            : 'N/A',
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditUserDialog(context, doc.id, data),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: Icon(
                              isAdmin ? Icons.person : Icons.admin_panel_settings,
                              color: Colors.orange,
                            ),
                            onPressed: () => _toggleAdminStatus(context, doc.id, !isAdmin),
                            tooltip: isAdmin ? 'Remover Admin' : 'Tornar Admin',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(context, doc.id, data['nome_completo'] ?? 'Usuário'),
                            tooltip: 'Excluir',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAddUserDialog(BuildContext context) {
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final cpfController = TextEditingController();
    final telefoneController = TextEditingController();
    final enderecoController = TextEditingController();
    bool isAdmin = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar Novo Usuário'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cpfController,
                    decoration: const InputDecoration(
                      labelText: 'CPF',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: telefoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: enderecoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Administrador'),
                    value: isAdmin,
                    onChanged: (value) {
                      setDialogState(() {
                        isAdmin = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.isEmpty || emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nome e email são obrigatórios')),
                  );
                  return;
                }

                await controller.addUser(
                  nomeCompleto: nomeController.text,
                  email: emailController.text,
                  cpf: cpfController.text,
                  telefone: telefoneController.text,
                  endereco: enderecoController.text,
                  isAdmin: isAdmin,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuário adicionado com sucesso')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    final nomeController = TextEditingController(text: data['nome_completo']);
    final emailController = TextEditingController(text: data['email']);
    final cpfController = TextEditingController(text: data['cpf']);
    final telefoneController = TextEditingController(text: data['telefone']);
    final enderecoController = TextEditingController(text: data['endereco']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuário'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cpfController,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: enderecoController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.updateUser(
                docId: docId,
                nomeCompleto: nomeController.text,
                email: emailController.text,
                cpf: cpfController.text,
                telefone: telefoneController.text,
                endereco: enderecoController.text,
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuário atualizado com sucesso')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _toggleAdminStatus(BuildContext context, String docId, bool newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? 'Tornar Administrador' : 'Remover Administrador'),
        content: Text(
          newStatus
              ? 'Tem certeza que deseja tornar este usuário administrador?'
              : 'Tem certeza que deseja remover privilégios de administrador?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.toggleAdminStatus(docId, newStatus);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    newStatus
                        ? 'Usuário promovido a administrador'
                        : 'Privilégios de admin removidos',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(BuildContext context, String docId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o usuário "$userName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteUser(docId);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuário excluído com sucesso')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}