import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // Importe o url_launcher
import 'package:recicle/screens/ajuda.dart';
import 'package:recicle/screens/comoReciclar.dart';
import 'package:recicle/screens/descarte_screen.dart';
import 'package:recicle/screens/dicas.dart';
import 'package:recicle/screens/locaisDescarte.dart';
import 'package:recicle/screens/meu_perfil.dart';
import 'package:recicle/screens/pontosColeta.dart';
import 'package:recicle/screens/meus_descartes.dart';
import 'package:recicle/screens/sobre.dart';

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

  // Função para abrir o site da prefeitura (testando com o Google)
  Future<void> _launchPrefeituraSite(BuildContext context) async {
    final Uri url = Uri.parse('https://pmp.pr.gov.br/website/views/horarioColetaLixo.php'); // Usando o Google para teste

    try {
      print('Tentando abrir o site: $url');
      // Tenta abrir o link diretamente
      await launchUrl(url, mode: LaunchMode.externalApplication); // Abre o Google no navegador
    } catch (e) {
      print('Erro ao abrir o site: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir o site: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tela Principal', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MeuPerfilScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text('Meus Descartes'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MeusDescartesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Ajuda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AjudaPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Sobre'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SobrePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                _logout(context); // Faz o logoff
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
              {'title': 'Como Reciclar', 'icon': Icons.help_outline, 'screen': ComoReciclarScreen()},
              {'title': 'Dicas', 'icon': Icons.lightbulb_outline, 'screen': DicasScreen()},
              {'title': 'Locais de Descarte', 'icon': Icons.delete_forever, 'screen': LocaisDescarteScreen()},
              {'title': 'Horários Coleta Prefeitura', 'icon': Icons.access_time, 'screen': null}, // Nenhuma tela associada
            ];

            return GestureDetector(
              onTap: () {
                // Verificar se o card tem uma tela associada
                if (cardsData[index]['screen'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => cardsData[index]['screen']),
                  );
                } else if (cardsData[index]['title'] == 'Horários Coleta Prefeitura') {
                  // Abrir o site da prefeitura (agora testando com o Google)
                  _launchPrefeituraSite(context); // Passa o context como parâmetro
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
