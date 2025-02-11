import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'register_screen.dart';
import 'package:geolocator/geolocator.dart'; // Importando o pacote de geolocalização

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  // Função para pegar a localização atual
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // O serviço de localização não está habilitado, retornar
      return;
    }

    // Verificar permissão de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // O usuário negou a permissão
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // O usuário bloqueou a permissão, vamos retornar
      return;
    }

    // Obter a localização atual
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('Localização atual: Latitude: ${position.latitude}, Longitude: ${position.longitude}');
  }

  // Método para realizar login com Firebase
  Future<void> _login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Obter localização após login
      await _getCurrentLocation();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado com sucesso!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta.';
      } else {
        errorMessage = 'Erro: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // Método para realizar login com o Google
  Future<void> _loginWithGoogle(BuildContext context) async {
    try {
      // Iniciar autenticação com Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // Usuário cancelou a autenticação
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login com Google cancelado pelo usuário.')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Credenciais do Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login com Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Obter localização após login
      await _getCurrentLocation();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login com Google realizado com sucesso!')),
      );

      // Após login, navegar para a tela principal
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar login com Google: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4CAF50), // Fundo verde
      appBar: AppBar(
        title: Text('LOGIN', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bem-vindo!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text('LOGIN', style: TextStyle(color: Colors.green)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _loginWithGoogle(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6, // Largura ajustada
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/google_logo.png', width: 24, height: 24),
                      SizedBox(width: 10),
                      Text('Login com Google', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('Criar uma conta', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
