import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa o Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meus Descartes',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MeusDescartesScreen(),
    );
  }
}

class MeusDescartesScreen extends StatefulWidget {
  @override
  _MeusDescartesScreenState createState() => _MeusDescartesScreenState();
}

class _MeusDescartesScreenState extends State<MeusDescartesScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenToFirestoreChanges();
    _saveFCMToken(); // Salva o token FCM do usuário atual
  }

  // Inicializa as notificações e solicita permissão
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtém o token FCM do dispositivo
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // Escuta mensagens recebidas enquanto o app está em primeiro plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida: ${message.notification?.title}, ${message.notification?.body}');
    });

    // Escuta quando o usuário abre o app a partir de uma notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Aplicativo aberto a partir de uma notificação: ${message.notification?.title}');
    });
  }

  // Salva o token FCM no Firestore
  Future<void> _saveFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
      print("Token FCM salvo: $token");
    }
  }

  // Envia uma notificação push via FCM
  Future<void> sendPushNotification(String userToken) async {
    try {
      var credentials = ServiceAccountCredentials.fromJson(
        File('lib/config/reciclar-23c9f-dcd0a2b18c9a.json').readAsStringSync(),
      );

      var url = Uri.parse('https://fcm.googleapis.com/v1/projects/reciclar-23c9f/messages:send');

      var authClient = await clientViaServiceAccount(credentials, ['https://www.googleapis.com/auth/firebase.messaging']);
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authClient.credentials.accessToken.data}',
      };

      var body = json.encode({
        "message": {
          "token": userToken,
          "notification": {
            "title": "Coleta Confirmada!",
            "body": "Seu descarte foi coletado com sucesso!",
          },
        },
      });

      print("Enviando notificação para o token: $userToken");
      var response = await http.post(url, headers: headers, body: body);
      print('Status da resposta: ${response.statusCode}');
      print('Resposta: ${response.body}');
    } catch (e) {
      print("Erro ao enviar a notificação: $e");
    }
  }

  // Remove um descarte do Firestore
  Future<void> _removerDescarte(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('descartes').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Descarte removido com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao remover o descarte')));
    }
  }

  // Confirma a coleta e atualiza o status no Firestore
  Future<void> _confirmarColeta(String docId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Obtém o documento de descarte
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('descartes').doc(docId).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        String userToken = data['userToken'] ?? ''; // Obtém o userToken do documento

        // Atualiza o status para 'Coletado'
        await FirebaseFirestore.instance.collection('descartes').doc(docId).update({
          'status': 'Coletado',
          'coletadoPor': userId,
          'dataColeta': FieldValue.serverTimestamp(),
        });

        // Envia a notificação para o userToken
        if (userToken.isNotEmpty) {
          print("Enviando notificação para o token: $userToken");
          sendPushNotification(userToken);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coleta confirmada!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao confirmar coleta')));
    }
  }

  // Converte uma imagem em base64 para um widget Image
  Image _convertBase64ToImage(String? base64Image) {
    if (base64Image != null && base64Image.isNotEmpty) {
      return Image.memory(base64Decode(base64Image), fit: BoxFit.cover, height: 200, width: double.infinity);
    } else {
      return Image.asset('assets/placeholder.png', fit: BoxFit.cover, height: 200, width: double.infinity);
    }
  }

  // Obtém o endereço a partir de coordenadas de latitude e longitude
  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        return "Endereço não encontrado";
      }
    } catch (e) {
      print("Erro ao obter o endereço: $e");
      return "Erro ao buscar endereço";
    }
  }

  // Escuta mudanças no Firestore e envia notificações
  void _listenToFirestoreChanges() {
    FirebaseFirestore.instance
        .collection('descartes')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        var data = doc.data();
        var status = data['status'];
        var userToken = data['userToken'] ?? '';

        print("Documento ID: ${doc.id}, Status: $status, UserToken: $userToken");

        if (status == 'Coletado' && userToken.isNotEmpty) {
          print("Enviando notificação para o token: $userToken");
          sendPushNotification(userToken); // Envia a notificação via FCM
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Descartes'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('descartes')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os dados'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum descarte encontrado.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>?;

              if (data == null) {
                return Center(child: Text('Erro ao carregar os dados do descarte.'));
              }

              final status = data.containsKey('status') ? data['status'] : 'sem status';
              final latitude = data['location'] != null ? data['location']['latitude'] : null;
              final longitude = data['location'] != null ? data['location']['longitude'] : null;
              final imageBase64 = data['imageBase64'];
              final docId = doc.id;

              return FutureBuilder<String>(
                future: (latitude != null && longitude != null)
                    ? _getAddressFromCoordinates(latitude, longitude)
                    : Future.value("Endereço não disponível"),
                builder: (context, addressSnapshot) {
                  if (addressSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final address = addressSnapshot.data ?? "Endereço não disponível";

                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: _convertBase64ToImage(imageBase64),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: $status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Endereço: $address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _removerDescarte(docId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: Icon(Icons.delete, color: Colors.white),
                                    label: Text('Remover Descarte', style: TextStyle(fontSize: 16, color: Colors.white)),
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _confirmarColeta(docId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: Icon(Icons.check, color: Colors.white),
                                    label: Text('Confirmar Coleta', style: TextStyle(fontSize: 16, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}