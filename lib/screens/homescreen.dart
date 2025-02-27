import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recicle/screens/descarte_screen.dart';  // Importe a tela de descarte
import 'package:recicle/screens/locaisDescarte.dart';
import 'package:recicle/screens/pontosColeta.dart';   // Importe a tela de pontos de coleta
import 'package:recicle/screens/meus_descartes.dart'; // Importe a tela correta de Meus Descartes

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Função para fazer logout
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/'); // Retorna à tela de login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tela Principal', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Ação ao clicar no ícone de notificações (você pode adicionar a lógica aqui)
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Tela Principal'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sair'),
              onTap: () {
                _logout(context); // Faz o logoff
              },
            ),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text('Meus Descartes'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MeusDescartesScreen()), // Direcionando para a tela de Meus Descartes
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 colunas
            crossAxisSpacing: 16.0, // Espaço entre colunas
            mainAxisSpacing: 16.0, // Espaço entre linhas
          ),
          itemCount: 6, // 6 cards
          itemBuilder: (context, index) {
            List<Map<String, dynamic>> cardsData = [
              {'title': 'Descartar Reciclável', 'icon': Icons.recycling, 'screen': DescarteScreen()},
              {'title': 'Pontos de Coleta', 'icon': Icons.location_on, 'screen': PontosColetaScreen()},
              {'title': 'Como Reciclar', 'icon': Icons.help_outline},
              {'title': 'Dicas', 'icon': Icons.lightbulb_outline},
              {'title': 'Locais de Descarte', 'icon': Icons.delete_forever, 'screen': LocaisDescarteScreen()},
              {'title': 'Horários', 'icon': Icons.access_time},
            ];

            return GestureDetector(
              onTap: () {
                // Verificar se o card tem uma tela associada
                if (cardsData[index]['screen'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => cardsData[index]['screen']),
                  );
                }
              },
              child: Card(
                color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cardsData[index]['icon'],
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      cardsData[index]['title']!,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Center(
        child: Text('Aqui estão os detalhes do perfil do usuário.'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurações')),
      body: Center(
        child: Text('Aqui estão as configurações do aplicativo.'),
      ),
    );
  }
}
