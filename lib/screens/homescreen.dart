import 'package:flutter/material.dart';
import 'package:recicle/controllers/home_controller.dart';
import 'package:recicle/screens/ajuda.dart';
import 'package:recicle/screens/comoReciclar.dart';
import 'package:recicle/screens/descarte_screen.dart';
import 'package:recicle/screens/dicas.dart';
import 'package:recicle/screens/meu_perfil.dart';
import 'package:recicle/screens/pontosColeta.dart';
import 'package:recicle/screens/meus_descartes.dart';
import 'package:recicle/screens/sobre.dart';
import 'package:recicle/screens/locais_descarte_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController _controller = HomeController();

  final List<Color> cardColors = [
    Colors.green,    // 1 - Verde
    Colors.blue,     // 2 - Azul
    Colors.red,      // 3 - Vermelho
    Colors.yellow,   // 4 - Amarelo
    Colors.orange,   // 5 - Laranja
    Colors.brown,    // 6 - Marrom
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tela Principal', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
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
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MeuPerfilScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Meus Descartes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MeusDescartesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ajuda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AjudaPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => SobrePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context);
                _controller.logout(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final List<Map<String, dynamic>> cardsData = [
              {'title': 'Descartar Reciclável', 'icon': Icons.recycling, 'screen': DescarteScreen()},
              {'title': 'Pontos de Coleta', 'icon': Icons.location_on, 'screen': PontosColetaScreen()},
              {'title': 'Como Reciclar', 'icon': Icons.help_outline, 'screen': ComoReciclarScreen()},
              {'title': 'Dicas', 'icon': Icons.lightbulb_outline, 'screen': DicasScreen()},
              {'title': 'Locais de Descarte', 'icon': Icons.delete_forever, 'screen': LocaisDescarteScreen()},
              {'title': 'Horários Coleta Prefeitura', 'icon': Icons.access_time, 'screen': null},
            ];

            return GestureDetector(
              onTap: () {
                final card = cardsData[index];
                if (card['screen'] != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => card['screen']));
                } else if (card['title'] == 'Horários Coleta Prefeitura') {
                  _controller.launchPrefeituraSite(context);
                }
              },
              child: Card(
                color: cardColors[index],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cardsData[index]['icon'], color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      cardsData[index]['title'],
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
