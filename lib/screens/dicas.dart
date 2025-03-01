import 'package:flutter/material.dart';

class DicasScreen extends StatelessWidget {
  const DicasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dicas'),
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
            ExpansionTile(
              title: Text(
                'Dicas para Reduzir o Plástico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Image.asset(
  'assets/nao_plastico.png', // Caminho da imagem
  height: 300,
  width: double.infinity,
  fit: BoxFit.cover,
),
                SizedBox(height: 10),
                Text(
                  '- Use sacolas reutilizáveis.\n'
                  '- Evite canudos e copos descartáveis.\n'
                  '- Prefira produtos com embalagens recicláveis.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'Dicas de Reutilização',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Image.asset(
  'assets/dica.jpg', // Caminho da imagem
  height: 300,
  width: double.infinity,
  fit: BoxFit.cover,
),
                SizedBox(height: 10),
                Text(
                  'Mesmo que o passado me lembre de todas as lutas que enfrentei e as que ainda enfrento, escolho não desistir, \n'
                  'porque cada passo dado é a prova de que sou capaz de seguir em frente e conquistar o que mereço',
                  style: TextStyle(fontSize: 16),
                ),
                Image.asset(
  'assets/tampinha.jpg', // Caminho da imagem
  height: 300,
  width: double.infinity,
  fit: BoxFit.cover,
),
              ],
            ),
            ExpansionTile(
              title: Text(
                'Curiosidades sobre Reciclagem',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Placeholder(
                  fallbackHeight: 150, // Espaço para imagem
                ),
                SizedBox(height: 10),
                Text(
                  '- A reciclagem de uma única lata de alumínio economiza energia suficiente para manter uma TV ligada por 3 horas.\n'
                  '- O Brasil recicla apenas 3% do lixo plástico produzido.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'Benefícios da Reciclagem',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Placeholder(
                  fallbackHeight: 150, // Espaço para imagem
                ),
                SizedBox(height: 10),
                Text(
                  '- Reduz a poluição do ar e da água.\n'
                  '- Economiza recursos naturais.\n'
                  '- Diminui a quantidade de lixo em aterros sanitários.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}