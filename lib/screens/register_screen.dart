import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController _controller = RegisterController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isPrivacyPolicyAccepted = false;


  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Política de Privacidade"),
          content: SizedBox(
            height: 350,
            child: SingleChildScrollView(
              child: const Text(
                """
Política de Privacidade

Esta Política de Privacidade descreve como coletamos, utilizamos e protegemos suas informações ao utilizar nosso aplicativo.

1. Coleta de Informações
Coletamos informações fornecidas por você, como:
- Nome completo
- E-mail
- CPF
- Endereço
- Telefone
- Senha
- Informações de localização (quando autorizado)
- Dados sobre descartes realizados no app

Também coletamos automaticamente dados técnicos como:
- Modelo do dispositivo
- Sistema operacional
- Horário de uso do app

2. Uso das Informações
Utilizamos seus dados para:
- Criar e gerenciar sua conta
- Registrar descartes e exibir o histórico
- Melhorar a experiência no app
- Enviar notificações
- Garantir segurança e prevenção de fraudes

3. Compartilhamento
Não vendemos ou compartilhamos seus dados, exceto:
- Quando exigido por lei
- Para funcionamento do serviço (ex: Firebase)

4. Segurança
Seus dados são protegidos por criptografia e políticas de segurança.

5. Direitos do Usuário
Você pode solicitar:
- Acesso aos seus dados
- Correção
- Exclusão da conta
- Informações sobre o tratamento dos dados

6. Exclusão da Conta
Ao excluir sua conta, apagamos seus dados pessoais permanentemente.

7. Atualizações
Podemos atualizar esta política e avisaremos pelo app.

8. Consentimento
Ao marcar que aceita, você declara estar de acordo com todas as regras acima.
                """,
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Fechar"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  void _submit() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showMessage('As senhas não coincidem!');
      return;
    }

    if (!_controller.isCpfValid(cpfController.text)) {
      _showMessage('CPF inválido!');
      return;
    }

    if (!_isPrivacyPolicyAccepted) {
      _showMessage('Você precisa aceitar os termos da Política de Privacidade.');
      return;
    }

    bool cpfExists = await _controller.isCpfRegistered(cpfController.text);
    if (cpfExists) {
      _showMessage('CPF já cadastrado!');
      return;
    }

    try {
      await _controller.register(
        nomeCompleto: fullNameController.text,
        email: emailController.text,
        cpf: cpfController.text,
        endereco: addressController.text,
        telefone: phoneController.text,
        senha: passwordController.text,
      );

      _showMessage('Cadastro realizado com sucesso!', isError: false);
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'weak-password') msg = 'A senha é muito fraca.';
      else if (e.code == 'email-already-in-use') msg = 'Este e-mail já está em uso.';
      else msg = 'Erro ao cadastrar: ${e.message}';
      _showMessage(msg);

    } catch (e) {
      _showMessage('Erro desconhecido: $e');
    }
  }

  void _showMessage(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Text(
              'Crie sua conta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            _buildTextField(fullNameController, 'Nome Completo', icon: Icons.person),
            const SizedBox(height: 20),

            _buildTextField(emailController, 'E-mail',
                icon: Icons.email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),

            _buildTextField(cpfController, 'CPF',
                icon: Icons.credit_card, keyboardType: TextInputType.number, onlyDigits: true),
            const SizedBox(height: 20),

            _buildTextField(passwordController, 'Senha',
                icon: Icons.lock, obscureText: true),
            const SizedBox(height: 20),

            _buildTextField(confirmPasswordController, 'Confirmar Senha',
                icon: Icons.lock, obscureText: true),
            const SizedBox(height: 20),

            _buildTextField(addressController, 'Endereço', icon: Icons.home),
            const SizedBox(height: 20),

            _buildTextField(phoneController, 'Telefone',
                icon: Icons.phone, keyboardType: TextInputType.phone, onlyDigits: true),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _isPrivacyPolicyAccepted,
                  onChanged: (value) {
                    setState(() => _isPrivacyPolicyAccepted = value!);
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _showPrivacyPolicy,
                    child: const Text.rich(
                      TextSpan(
                        text: 'Aceito os termos da ',
                        children: [
                          TextSpan(
                            text: 'Política de Privacidade',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'Cadastrar',
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Já tenho uma conta',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? icon,
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
        suffixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }
}
