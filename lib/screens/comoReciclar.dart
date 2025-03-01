import 'package:flutter/material.dart';

class ComoReciclarScreen extends StatelessWidget {
  const ComoReciclarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Como Reciclar'),
        backgroundColor: Colors.green,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Passo a Passo da Reciclagem',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Image.asset(
  'assets/lixeiras.jpeg', // Caminho da imagem
  height: 150,
  width: double.infinity,
  fit: BoxFit.cover,
),
            SizedBox(height: 10),
            Text(
              '1. Separe os resíduos em categorias: plástico, vidro, metal, papel e orgânico.\n'
              '2. Limpe os materiais antes de descartá-los.\n'
              '3. Descarte cada material no local correto.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'O que pode ser reciclado?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
Image.asset(
  'assets/material.jpg', // Caminho da imagem
  height: 150,
  width: double.infinity,
  fit: BoxFit.cover,
),
            SizedBox(height: 10),
            Text(
              '- Plástico: garrafas, embalagens, sacolas.\n'
              '- Vidro: garrafas, potes, frascos.\n'
              '- Metal: latas, tampas, arames.\n'
              '- Papel: jornais, revistas, caixas.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}