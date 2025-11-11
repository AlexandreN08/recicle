import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeWebScreen extends StatefulWidget {
  const HomeWebScreen({super.key});

  @override
  State<HomeWebScreen> createState() => _HomeWebScreenState();
}

class _HomeWebScreenState extends State<HomeWebScreen> {
  String selectedView = 'dashboard'; // dashboard, usuarios, configuracoes

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh data
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "Administrador"),
              accountEmail: Text(user?.email ?? "sem email"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 32, color: Colors.green),
              ),
              decoration: const BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              selected: selectedView == 'dashboard',
              onTap: () {
                setState(() => selectedView = 'dashboard');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Gerenciar Usuários"),
              selected: selectedView == 'usuarios',
              onTap: () {
                setState(() => selectedView = 'usuarios');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configurações"),
              selected: selectedView == 'configuracoes',
              onTap: () {
                setState(() => selectedView = 'configuracoes');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (selectedView) {
      case 'dashboard':
        return _buildDashboard();
      case 'usuarios':
        return _buildUsuarios();
      case 'configuracoes':
        return _buildConfiguracoes();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard - Gestão de Descartes',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Cards de estatísticas
          _buildStatsCards(),
          
          const SizedBox(height: 30),
          
          // Gráfico de materiais mais descartados
          _buildMaterialsChart(),
          
          const SizedBox(height: 30),
          
          // Lista de descartes recentes
          _buildRecentDisposals(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('descartes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Text('Nenhum dado disponível');
        }

        final docs = snapshot.data!.docs;
        final totalDescartes = docs.length;
        
        // Contar materiais
        Map<String, int> materialCount = {};
        int totalMateriais = 0;
        
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final materials = data['materials'] as List<dynamic>? ?? [];
          totalMateriais += materials.length;
          
          for (var material in materials) {
            final materialName = material.toString();
            materialCount[materialName] = (materialCount[materialName] ?? 0) + 1;
          }
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total de Descartes',
                totalDescartes.toString(),
                Icons.recycling,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total de Materiais',
                totalMateriais.toString(),
                Icons.inventory,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Tipos de Material',
                materialCount.keys.length.toString(),
                Icons.category,
                Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Materiais Mais Descartados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('descartes').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Text('Nenhum dado disponível');
                }

                final docs = snapshot.data!.docs;
                Map<String, int> materialCount = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final materials = data['materials'] as List<dynamic>? ?? [];
                  
                  for (var material in materials) {
                    final materialName = material.toString();
                    materialCount[materialName] = (materialCount[materialName] ?? 0) + 1;
                  }
                }

                final sortedMaterials = materialCount.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  children: sortedMaterials.take(5).map((entry) {
                    final percentage = (entry.value / docs.length * 100);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: entry.value / (sortedMaterials.first.value),
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
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

  Widget _buildRecentDisposals() {
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
              stream: FirebaseFirestore.instance
                  .collection('descartes')
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
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
                            if (location != null)
                              Text('Localização: ${location['latitude']?.toStringAsFixed(4)}, ${location['longitude']?.toStringAsFixed(4)}'),
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
                              _deleteDisposal(doc.id);
                            } else if (value == 'details') {
                              _showDisposalDetails(data);
                            }
                          },
                        ),
                      ),
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

  Widget _buildUsuarios() {
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
                onPressed: () => _showAddUserDialog(),
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
          
          // Estatísticas de usuários
          _buildUserStats(),
          
          const SizedBox(height: 30),
          
          // Tabela de usuários
          _buildUsersTable(),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cadastros').snapshots(),
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
              child: _buildStatCard(
                'Total de Usuários',
                users.length.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Administradores',
                admins.toString(),
                Icons.admin_panel_settings,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Usuários Normais',
                normalUsers.toString(),
                Icons.person,
                Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsersTable() {
    return Card(
      elevation: 4,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cadastros')
            .orderBy('createdAt', descending: true)
            .snapshots(),
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
                            onPressed: () => _showEditUserDialog(doc.id, data),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: Icon(
                              isAdmin ? Icons.person : Icons.admin_panel_settings,
                              color: Colors.orange,
                            ),
                            onPressed: () => _toggleAdminStatus(doc.id, !isAdmin),
                            tooltip: isAdmin ? 'Remover Admin' : 'Tornar Admin',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(doc.id, data['nome_completo'] ?? 'Usuário'),
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

  void _showAddUserDialog() {
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

                await FirebaseFirestore.instance.collection('cadastros').add({
                  'nome_completo': nomeController.text,
                  'email': emailController.text,
                  'cpf': cpfController.text,
                  'telefone': telefoneController.text,
                  'endereco': enderecoController.text,
                  'isAdmin': isAdmin,
                  'createdAt': FieldValue.serverTimestamp(),
                });

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

  void _showEditUserDialog(String docId, Map<String, dynamic> data) {
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
              await FirebaseFirestore.instance
                  .collection('cadastros')
                  .doc(docId)
                  .update({
                'nome_completo': nomeController.text,
                'email': emailController.text,
                'cpf': cpfController.text,
                'telefone': telefoneController.text,
                'endereco': enderecoController.text,
              });

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

  void _toggleAdminStatus(String docId, bool newStatus) {
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
              await FirebaseFirestore.instance
                  .collection('cadastros')
                  .doc(docId)
                  .update({'isAdmin': newStatus});

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

  void _deleteUser(String docId, String userName) {
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
              await FirebaseFirestore.instance
                  .collection('cadastros')
                  .doc(docId)
                  .delete();

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

  Widget _buildConfiguracoes() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações do Sistema',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          
          // Seção: Informações do Sistema
          _buildConfigSection(
            'Informações do Sistema',
            Icons.info_outline,
            Colors.blue,
            [
              _buildInfoTile('Versão do App', '1.0.0'),
              _buildInfoTile('Última Atualização', '12/09/2025'),
              _buildInfoTile('Ambiente', 'Produção'),
              _buildInfoTile('Firebase Project', 'recicle-app'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Seção: Estatísticas Gerais
          _buildConfigSection(
            'Estatísticas Gerais',
            Icons.bar_chart,
            Colors.green,
            [
              _buildStreamStatTile('Total de Usuários', 'cadastros'),
              _buildStreamStatTile('Total de Descartes', 'descartes'),
              _buildStreamStatTile('Total de Empresas', 'empresas'),
              _buildStreamStatTile('Total de Notificações', 'notificacoes'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Seção: Gerenciamento de Dados
          _buildConfigSection(
            'Gerenciamento de Dados',
            Icons.storage,
            Colors.orange,
            [
              _buildActionTile(
                'Backup do Banco de Dados',
                'Exportar todos os dados do sistema',
                Icons.backup,
                Colors.blue,
                () => _exportData(),
              ),
              _buildActionTile(
                'Limpar Cache',
                'Remover dados temporários do sistema',
                Icons.cleaning_services,
                Colors.purple,
                () => _clearCache(),
              ),
              _buildActionTile(
                'Logs do Sistema',
                'Visualizar histórico de atividades',
                Icons.article,
                Colors.teal,
                () => _showLogs(),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Seção: Configurações de Notificações
          _buildConfigSection(
            'Notificações',
            Icons.notifications,
            Colors.purple,
            [
              _buildSwitchTile(
                'Notificações por Email',
                'Enviar notificações administrativas por email',
                true,
                (value) => _updateNotificationSetting('email', value),
              ),
              _buildSwitchTile(
                'Alertas de Novos Usuários',
                'Receber alerta quando um novo usuário se cadastrar',
                true,
                (value) => _updateNotificationSetting('newUsers', value),
              ),
              _buildSwitchTile(
                'Relatórios Semanais',
                'Receber relatório semanal de atividades',
                false,
                (value) => _updateNotificationSetting('weeklyReports', value),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Seção: Manutenção
          _buildConfigSection(
            'Manutenção',
            Icons.build,
            Colors.red,
            [
              _buildActionTile(
                'Modo Manutenção',
                'Ativar modo de manutenção do sistema',
                Icons.construction,
                Colors.orange,
                () => _toggleMaintenanceMode(),
              ),
              _buildActionTile(
                'Limpar Dados Antigos',
                'Remover registros com mais de 1 ano',
                Icons.delete_sweep,
                Colors.red,
                () => _cleanOldData(),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Seção: Sobre
          _buildConfigSection(
            'Sobre',
            Icons.help_outline,
            Colors.grey,
            [
              _buildInfoTile('Desenvolvido por', 'Recicle Team'),
              _buildInfoTile('Contato', 'contato@recicle.com'),
              _buildInfoTile('Website', 'www.recicle.com'),
              _buildActionTile(
                'Documentação',
                'Acessar documentação do sistema',
                Icons.menu_book,
                Colors.blue,
                () => _openDocumentation(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamStatTile(String label, String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _buildInfoTile(label, count.toString());
      },
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return SwitchListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(subtitle),
          value: value,
          onChanged: (newValue) {
            setState(() => value = newValue);
            onChanged(newValue);
          },
          activeColor: Colors.green,
        );
      },
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup, color: Colors.blue),
            SizedBox(width: 8),
            Text('Exportar Dados'),
          ],
        ),
        content: const Text(
          'Esta ação irá exportar todos os dados do sistema em formato JSON. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportação iniciada! Você receberá um email com o arquivo.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cleaning_services, color: Colors.purple),
            SizedBox(width: 8),
            Text('Limpar Cache'),
          ],
        ),
        content: const Text(
          'Esta ação irá remover todos os dados temporários. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache limpo com sucesso!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _showLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logs do Sistema'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: ListView(
            children: const [
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Sistema iniciado com sucesso'),
                subtitle: Text('12/09/2025 08:30:15'),
              ),
              ListTile(
                leading: Icon(Icons.person_add, color: Colors.blue),
                title: Text('Novo usuário cadastrado'),
                subtitle: Text('12/09/2025 10:45:22'),
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.orange),
                title: Text('Descarte registrado'),
                subtitle: Text('12/09/2025 14:20:30'),
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.orange),
                title: Text('Tentativa de login falhou'),
                subtitle: Text('12/09/2025 16:15:45'),
              ),
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

  void _toggleMaintenanceMode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.construction, color: Colors.orange),
            SizedBox(width: 8),
            Text('Modo Manutenção'),
          ],
        ),
        content: const Text(
          'Ativar o modo manutenção bloqueará o acesso de todos os usuários exceto administradores. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modo manutenção ativado'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
  }

  void _cleanOldData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_sweep, color: Colors.red),
            SizedBox(width: 8),
            Text('Limpar Dados Antigos'),
          ],
        ),
        content: const Text(
          'Esta ação irá remover permanentemente todos os registros com mais de 1 ano. Esta operação não pode ser desfeita. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dados antigos removidos com sucesso!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _updateNotificationSetting(String setting, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Notificação de $setting ativada'
              : 'Notificação de $setting desativada',
        ),
      ),
    );
  }

  void _openDocumentation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Documentação'),
        content: const Text(
          'A documentação completa está disponível em:\nhttps://docs.recicle.com\n\nDeseja abrir no navegador?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrindo documentação...')),
              );
            },
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _deleteDisposal(String docId) {
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
              await FirebaseFirestore.instance
                  .collection('descartes')
                  .doc(docId)
                  .delete();
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

  void _showDisposalDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Descarte'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Materiais: ${(data['materials'] as List<dynamic>?)?.join(", ") ?? "N/A"}'),
              const SizedBox(height: 8),
              Text('Usuário ID: ${data['userId'] ?? "N/A"}'),
              const SizedBox(height: 8),
              if (data['location'] != null)
                Text('Localização: ${data['location']['latitude']}, ${data['location']['longitude']}'),
              const SizedBox(height: 8),
              if (data['createdAt'] != null)
                Text('Data: ${_formatDate((data['createdAt'] as Timestamp).toDate())}'),
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