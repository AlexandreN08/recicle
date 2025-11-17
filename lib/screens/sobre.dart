import 'package:flutter/material.dart';

class SobrePage extends StatefulWidget {
  @override
  _SobrePageState createState() => _SobrePageState();
}

class _SobrePageState extends State<SobrePage> {
  final String appName = "Recycling";
  final String appVersion = "1.0.0";



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sobre o Aplicativo'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Aplicativo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),

            _buildInfoRow('Nome do Aplicativo:', appName),
            _buildInfoRow('Versão do Aplicativo:', appVersion),

            Divider(height: 32),

            Text(
              'Objetivo do Aplicativo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),

            Text(
              'Este aplicativo tem como objetivo principal facilitar o descarte e a coleta eficiente de materiais recicláveis, utilizando a tecnologia dos smartphones para promover boas práticas ambientais.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),

            SizedBox(height: 16),

            Text(
              'Funcionalidades Principais',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),

            ListTile(
              leading: Icon(Icons.recycling, color: Colors.green),
              title: Text('Dicas de Reciclagem'),
              subtitle: Text('Aprenda como reciclar diferentes tipos de materiais.'),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.green),
              title: Text('Locais de Coleta'),
              subtitle: Text('Encontre os pontos de coleta mais próximos de você.'),
            ),
            ListTile(
              leading: Icon(Icons.thumb_up, color: Colors.green),
              title: Text('Descarte Correto'),
              subtitle: Text('Saiba como descartar materiais de forma adequada.'),
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.green),
              title: Text('Apoio aos Recicladores'),
              subtitle: Text('Facilite o trabalho dos coletores de materiais recicláveis.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
