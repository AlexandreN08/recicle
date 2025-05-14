import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recicle/screens/homescreen.dart';
import 'package:recicle/screens/login_screen.dart';
import 'package:recicle/screens/sobre.dart';
import 'package:recicle/service/hash_generator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await signInAndSaveHashOnce();
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

  final docRef = FirebaseFirestore.instance.collection('registrations').doc(user.uid);
  final docSnapshot = await docRef.get();

  if (!docSnapshot.exists) {
    String contentToHash = "RecicleApp-${user.uid}-${DateTime.now().millisecondsSinceEpoch}";
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
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/sobre': (context) => SobrePage(),
      },
    );
  }
}
