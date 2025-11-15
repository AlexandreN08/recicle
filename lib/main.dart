import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recicle/screens/homescreen.dart';
import 'package:recicle/screens/home_web.dart';
import 'package:recicle/screens/login_screen.dart';
import 'package:recicle/screens/login_web.dart';
import 'package:recicle/screens/sobre.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recicle App',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true, 
      ),
      home: kIsWeb ? AuthWrapperWeb() : AuthWrapperMobile(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/homeWeb': (context) => HomeWebScreen(),
        '/sobre': (context) => SobrePage(),
        '/login': (context) => LoginScreen(),
        '/loginWeb': (context) => LoginWebScreen(),
      },
    );
  }
}
class AuthWrapperMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto verifica autenticação
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Carregando...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return LoginScreen();
        }

        return HomeScreen();
      },
    );
  }
}

class AuthWrapperWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Carregando...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return LoginWebScreen();
        }

        final user = snapshot.data!;

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('cadastros')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get(),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        'Verificando permissões...',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (adminSnapshot.hasError) {
              print('Erro ao verificar admin: ${adminSnapshot.error}');
              return HomeScreen();
            }

            if (!adminSnapshot.hasData || adminSnapshot.data!.docs.isEmpty) {
              print('Usuário ${user.email} não encontrado na coleção cadastros');
              return HomeScreen();
            }

            try {
              final userData = adminSnapshot.data!.docs.first.data() as Map<String, dynamic>;
              final isAdmin = userData['isAdmin'] == true;

              print('👤 Usuário: ${user.email}');
              print('🔑 É admin: $isAdmin');

              if (isAdmin) {
                print('Redirecionando para HomeWebScreen (Admin)');
                return HomeWebScreen();
              } else {
                print('Redirecionando para HomeScreen (Usuário)');
                return HomeScreen();
              }
            } catch (e) {
              print('Erro ao processar dados do usuário: $e');
              return HomeScreen();
            }
          },
        );
      },
    );
  }
}