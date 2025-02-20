import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart'; // Para inicializar o Firebase
import 'package:geolocator/geolocator.dart'; // Importando o pacote de geolocalização
import 'register_screen.dart';
import 'reset_password_screen.dart'; // Importa a tela de recuperação de senha

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  LoginScreen({super.key});

  // Função para inicializar o Firebase
  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Função para pegar a localização atual
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Verificar permissão de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
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
        errorMessage = 'Usuário não encontrado. Verifique o e-mail.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta. Tente novamente.';
      } else {
        errorMessage = 'Verifique e-mail e senha. Tente novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // Método para login com Google
  Future<void> _loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login com Google cancelado pelo usuário.')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await _getCurrentLocation();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login com Google realizado com sucesso!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar login com Google. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Color(0xFF4CAF50), // Fundo verde
          appBar: AppBar(
            title: Text('LOGIN', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: Color(0xFF4CAF50),
          ),
          body: SingleChildScrollView( // Envolvendo o corpo com SingleChildScrollView
            child: Center( // Centraliza os componentes dentro do SingleChildScrollView
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center, // Centraliza os itens horizontalmente
                  children: [
                    // Adicionando o logo do aplicativo
                    Image.asset(
                      'assets/logo.png',  // Caminho do logo
                      height: 150,  // Ajuste a altura conforme necessário
                    ),
                    SizedBox(height: 20),
                    Text(
                      'RECYCLING',
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/google_logo.png', width: 24, height: 24),
                          SizedBox(width: 10),
                          Text('Login com Google', style: TextStyle(color: Colors.red)),
                        ],
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
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                        );
                      },
                      child: Text('Esqueci minha senha', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
