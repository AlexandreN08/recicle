import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recicle/screens/homescreen.dart';
import 'package:recicle/screens/home_web.dart'; // 🔹 Import da Home Web
import 'package:recicle/screens/login_screen.dart';
import 'package:recicle/screens/login_web.dart'; // Tela específica para web
import 'package:recicle/screens/sobre.dart';
import 'package:recicle/service/hash_generator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do Firebase para todas as plataformas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Só executa no mobile/desktop, não no Web
  if (!kIsWeb) {
    await signInAndSaveHashOnce();
  }

  runApp(MyApp());
}

Future<void> signInAndSaveHashOnce() async {
  final auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user == null) {
    UserCredential cred = await auth.signInAnonymously();
    user = cred.user;
  }

  if (user == null) {
    print('Erro ao autenticar usuário.');
    return;
  }

  final docRef =
      FirebaseFirestore.instance.collection('registrations').doc(user.uid);
  final docSnapshot = await docRef.get();

  if (!docSnapshot.exists) {
    String contentToHash =
        "RecicleApp-${user.uid}-${DateTime.now().millisecondsSinceEpoch}";
    String hash = generateHashFromContent(contentToHash);

    await docRef.set({
      'appName': 'Recicle App',
      'appVersion': '1.0.0',
      'hash': hash,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('Registro salvo no Firestore.');
  } else {
    print('Registro já existe.');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recicle App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: kIsWeb ? AuthWrapperWeb() : LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/homeWeb': (context) => HomeWebScreen(),
        '/sobre': (context) => SobrePage(),
      },
    );
  }
}

/// 🔹 Verifica se usuário é admin no Firestore
class AuthWrapperWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se ainda está carregando a autenticação
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se não há usuário logado
        if (!snapshot.hasData || snapshot.data == null) {
          return LoginWebScreen();
        }

        final user = snapshot.data!;
        
        // Verificar se é admin
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('cadastros')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get(),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Verificando permissões...'),
                    ],
                  ),
                ),
              );
            }

            // Se houve erro na consulta
            if (adminSnapshot.hasError) {
              print('Erro ao verificar admin: ${adminSnapshot.error}');
              return HomeScreen(); // Direciona para tela normal em caso de erro
            }

            // Se não encontrou documentos ou está vazio
            if (!adminSnapshot.hasData || adminSnapshot.data!.docs.isEmpty) {
              print('Usuário ${user.email} não encontrado na coleção cadastros');
              return HomeScreen(); // Usuário normal
            }

            // Verificar se é admin
            try {
              final userData = adminSnapshot.data!.docs.first.data() as Map<String, dynamic>;
              final isAdmin = userData['isAdmin'] == true;
              
              print('Usuário: ${user.email}');
              print('É admin: $isAdmin');
              print('Dados do usuário: $userData');

              if (isAdmin) {
                return HomeWebScreen(); // Admin vai para HomeWeb
              } else {
                return HomeScreen(); // Usuário normal vai para Home
              }
            } catch (e) {
              print('Erro ao processar dados do usuário: $e');
              return HomeScreen(); // Em caso de erro, direciona para tela normal
            }
          },
        );
      },
    );
  }
}