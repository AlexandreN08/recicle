import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sobre o Aplicativo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Centraliza o título
        backgroundColor: Colors.green, // Cor de fundo do AppBar
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 80.0, // Adiciona padding na parte inferior
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: 16),
            Text(
              'Fase de Desenvolvimento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'O aplicativo foi desenvolvido com o objetivo de oferecer uma solução completa e acessível para a comunidade, promovendo a sustentabilidade e a conscientização ambiental.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}