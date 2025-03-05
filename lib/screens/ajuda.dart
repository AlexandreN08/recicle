import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class AjudaPage extends StatefulWidget {
  @override
  _AjudaPageState createState() => _AjudaPageState();
}

class _AjudaPageState extends State<AjudaPage> {
  TextEditingController _textController = TextEditingController();

  // Função para enviar o e-mail
  void _sendEmail() async {
    final Email email = Email(
      body: _textController.text, // O conteúdo da dúvida do usuário
      subject: 'Dúvida de Suporte',
      recipients: ['alexandrenecher@gmail.com'], // E-mail de suporte
      isHTML: false,
    );

    try {
      // Envia o e-mail
      await FlutterEmailSender.send(email);

      // Exibe mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sua dúvida foi enviada com sucesso!')),
      );

      // Limpa o campo de texto após envio
      _textController.clear();
    } catch (e) {
      // Exibe mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao enviar a dúvida. Erro: $e')),
      );
      print('Erro ao enviar e-mail: $e'); // Log do erro no console
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajuda'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Caso tenha alguma dúvida, escreva abaixo e envie para o suporte.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escreva sua dúvida aqui...',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendEmail,
              child: Text('Enviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}