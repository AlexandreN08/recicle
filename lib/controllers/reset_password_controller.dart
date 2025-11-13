import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordController {
  final TextEditingController emailController = TextEditingController();

  // Função para enviar o e-mail de recuperação de senha
  Future<void> resetPassword(BuildContext context) async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, digite seu e-mail.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail de recuperação enviado!')),
      );
      Navigator.pop(context); // Volta para a tela de login
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Não há um usuário cadastrado com esse e-mail.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'E-mail inválido. Verifique o formato.';
      } else {
        errorMessage = 'Erro ao enviar e-mail de recuperação: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
