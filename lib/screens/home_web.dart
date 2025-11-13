import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/admin_controller.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/users_view.dart';
import '../widgets/settings_view.dart';

class HomeWebScreen extends StatefulWidget {
  const HomeWebScreen({super.key});

  @override
  State<HomeWebScreen> createState() => _HomeWebScreenState();
}

class _HomeWebScreenState extends State<HomeWebScreen> {
  final AdminController _controller = AdminController();
  String selectedView = 'dashboard';

  @override
  Widget build(BuildContext context) {
    final user = _controller.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _controller.signOut();
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      drawer: _buildDrawer(user),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer(user) {
    return Drawer(
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
    );
  }

  Widget _buildBody() {
    switch (selectedView) {
      case 'dashboard':
        return DashboardView(controller: _controller);
      case 'usuarios':
        return UsersView(controller: _controller);
      case 'configuracoes':
        return SettingsView(controller: _controller);
      default:
        return DashboardView(controller: _controller);
    }
  }
}