import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/meu_perfil_controller.dart';

class MeuPerfilScreen extends StatefulWidget {
  const MeuPerfilScreen({super.key});

  @override
  _MeuPerfilScreenState createState() => _MeuPerfilScreenState();
}

class _MeuPerfilScreenState extends State<MeuPerfilScreen> {
  final MeuPerfilController _controller = MeuPerfilController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _controller.loadUserData();
    if (data != null) {
      setState(() {
        emailController.text = data['email'] ?? '';
        fullNameController.text = data['nome_completo'] ?? '';
        cpfController.text = data['cpf'] ?? '';
        addressController.text = data['endereco'] ?? '';
        phoneController.text = data['telefone'] ?? '';
      });
    }
  }

  void _updateData() async {
    try {
      await _controller.updateUserData(
        nomeCompleto: fullNameController.text,
        email: emailController.text,
        cpf: cpfController.text,
        endereco: addressController.text,
        telefone: phoneController.text,
        senha: passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar dados: $e')),
      );
    }
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
                _buildTextField(fullNameController, 'Nome Completo'),
                const SizedBox(height: 20),
                _buildTextField(emailController, 'E-mail', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildTextField(cpfController, 'CPF', keyboardType: TextInputType.number, onlyDigits: true),
                const SizedBox(height: 20),
                _buildTextField(addressController, 'Endereço'),
                const SizedBox(height: 20),
                _buildTextField(phoneController, 'Telefone', keyboardType: TextInputType.phone, onlyDigits: true),
                const SizedBox(height: 20),
                _buildTextField(passwordController, 'Nova Senha', obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: const Text('Atualizar Dados', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool onlyDigits = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: onlyDigits ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
        labelStyle: const TextStyle(color: Colors.black),
      ),
    );
  }
}
