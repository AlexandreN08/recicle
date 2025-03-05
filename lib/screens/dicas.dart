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
      body: SafeArea( // Envolvendo o corpo com SafeArea
        child: SingleChildScrollView(
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
                  // Primeira Dica
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Decoração de Jardim com Garrafas PET',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Image.asset(
                          'assets/dica.jpg', // Caminho da imagem
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Reutilize garrafas PET para criar peças únicas de decoração para o seu jardim. Você pode pintá-las, cortá-las ou usá-las de várias formas criativas.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // Segunda Dica
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enfeite de Mesa com Tampinhas',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Image.asset(
                          'assets/tampinha.jpg', // Caminho da imagem
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Guarde tampinhas de garrafas PET e use-as para criar um lindo enfeite de mesa. Elas podem ser organizadas de diversas maneiras para formar padrões interessantes.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // Terceira Dica
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vaso de Flores com Garrafa PET',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Image.asset(
                          'assets/vasoBoneca.jpg', // Caminho da imagem
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Transforme uma garrafa PET em um vaso criativo para flores. Corte, pinte e adicione seu toque pessoal para um resultado único e sustentável.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // Quarta Dica
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Decoração com Garrafas de Vidro',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Image.asset(
                          'assets/guarrafa.jpg', // Caminho da imagem
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Garrafas de vidro podem ser decoradas com desenhos, pinturas ou até tecidos. Elas são perfeitas para se tornarem peças de decoração elegantes para qualquer ambiente.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
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
                  Image.asset(
                    'assets/curiosidade.png',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '- A reciclagem de uma única lata de alumínio economiza energia suficiente para manter uma TV ligada por 3 horas.\n'
                    '- O Brasil recicla apenas 3% do lixo plástico produzido.\n'
                    '- O papel reciclado pode ser reutilizado de 5 a 7 vezes sem perder qualidade.\n'
                    '- Cada tonelada de papel reciclado economiza cerca de 17 árvores e 7.000 galões de água.',
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
                  Image.asset(
                    'assets/beneficios.jpeg',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '- Reduz a poluição do ar e da água.\n'
                    '- Economiza recursos naturais.\n'
                    '- Diminui a quantidade de lixo em aterros sanitários.\n'
                    '- Gera emprego e renda em diversas áreas, como coleta seletiva e processamento de materiais recicláveis.\n'
                    '- Contribui para a redução da emissão de gases de efeito estufa, ajudando no combate às mudanças climáticas.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
