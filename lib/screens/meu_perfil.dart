import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importando Firestore
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MeuPerfilScreen extends StatefulWidget {
  const MeuPerfilScreen({super.key});

  @override
  _MeuPerfilScreenState createState() => _MeuPerfilScreenState();
}

class _MeuPerfilScreenState extends State<MeuPerfilScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController(); // Controlador para o nome completo
  final TextEditingController cpfController = TextEditingController(); // Controlador para CPF
  final TextEditingController addressController = TextEditingController(); // Controlador para endereço
  final TextEditingController phoneController = TextEditingController(); // Controlador para telefone
  final TextEditingController passwordController = TextEditingController(); // Controlador para a nova senha

  // Função para carregar os dados do usuário no Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Carregar dados do Firestore
      final docSnapshot = await FirebaseFirestore.instance.collection('cadastros').doc(user.uid).get();
      if (docSnapshot.exists) {
        setState(() {
          emailController.text = docSnapshot['email'];
          fullNameController.text = docSnapshot['nome_completo'];
          cpfController.text = docSnapshot['cpf'];
          addressController.text = docSnapshot['endereco'];
          phoneController.text = docSnapshot['telefone'];
        });
      }
    }
  }

  // Função para atualizar os dados
  Future<void> _updateProfile(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Atualizar os dados no Firestore
        await FirebaseFirestore.instance.collection('cadastros').doc(user.uid).update({
          'nome_completo': fullNameController.text,
          'email': emailController.text,
          'cpf': cpfController.text,
          'endereco': addressController.text,
          'telefone': phoneController.text,
        });

        // Se a senha foi preenchida, atualiza a senha no Firebase Auth
        if (passwordController.text.isNotEmpty) {
          await user.updatePassword(passwordController.text);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar dados: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carregar os dados do usuário quando a tela for exibida
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Campo para nome completo
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo para e-mail
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Campo para CPF
                TextField(
                  controller: cpfController,
                  decoration: InputDecoration(
                    labelText: 'CPF',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),

                // Campo para Endereço
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Endereço',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo para Telefone
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),

                // Botão para salvar as alterações
                ElevatedButton(
                  onPressed: () => _updateProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: const Text(
                    'Atualizar Dados',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                // Botão para voltar à tela anterior
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Voltar',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}