import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recicle/screens/homescreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:recicle/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Tente autenticar o usuário anonimamente no Firebase Auth
  try {
    await FirebaseAuth.instance.signInAnonymously();
    print('Usuário autenticado anonimamente com sucesso: ${FirebaseAuth.instance.currentUser?.uid}');
  } catch (e) {
    print('Erro ao autenticar anonimamente: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recicle App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
