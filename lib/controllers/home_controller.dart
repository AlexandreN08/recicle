import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController {
  /// Faz o logout do usuário autenticado.
  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')), 
      );
    }
  }

  /// Abre o site da prefeitura no navegador.
  Future<void> launchPrefeituraSite(BuildContext context) async {
    final Uri url = Uri.parse(
        'https://pmp.pr.gov.br/website/views/horarioColetaLixo.php');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir o site: $e')),
      );
    }
  }
}
