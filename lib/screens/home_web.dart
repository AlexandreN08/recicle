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
    return const Center(
      child: Text(
        'Gerenciamento de Usuários\n(Em desenvolvimento)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildConfiguracoes() {
    return const Center(
      child: Text(
        'Configurações do Sistema\n(Em desenvolvimento)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
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