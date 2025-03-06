import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AjudaPage extends StatefulWidget {
  @override
  _AjudaPageState createState() => _AjudaPageState();
}

class _AjudaPageState extends State<AjudaPage> {
  TextEditingController _textController = TextEditingController();

  // Função para abrir o Gmail com o e-mail do suporte
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'alexandrenecher@gmail.com', // Substitua pelo e-mail de suporte
      queryParameters: {
        'subject': 'Dúvida de Suporte',
        'body': _textController.text,
      },
    );

    // Abre diretamente o aplicativo de e-mail
    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  }

  // Função para abrir o WhatsApp com o número de suporte
  Future<void> _launchWhatsApp() async {
    final String phoneNumber = '5546999185491'; // Substitua pelo número de suporte
    final String message = 'Olá, tenho uma dúvida: ${_textController.text}';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}',
    );

    // Abre diretamente o WhatsApp
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajuda',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Centraliza o título
        backgroundColor: Colors.green, // Cor de fundo do AppBar
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 66.0,
          bottom: 80.0, // Adiciona padding na parte inferior
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precisa de Ajuda?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 36),
            Text(
              'Caso tenha alguma dúvida ou precise de ajuda, escolha uma opção nos envie uma mensagem para o suporte.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 40),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchEmail,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Enviar E-mail', style: TextStyle(color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Cor do botão de e-mail
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _launchWhatsApp,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/whatsapp.png', // Caminho da imagem do WhatsApp
                    width: 24, // Largura da imagem
                    height: 24, // Altura da imagem
                  ),
                  SizedBox(width: 10),
                  Text('Enviar WhatsApp', style: TextStyle(color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Cor do botão do WhatsApp
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}