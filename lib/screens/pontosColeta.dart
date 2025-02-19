import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PontosColetaScreen extends StatefulWidget {
  @override
  _PontosColetaScreenState createState() => _PontosColetaScreenState();
}

class _PontosColetaScreenState extends State<PontosColetaScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    requestLocationPermission();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      print("Permissão de localização concedida!");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permissão de localização negada')));
    }
  }

  Image _convertBase64ToImage(String? base64Image) {
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        return Image.memory(base64Decode(base64Image), fit: BoxFit.cover, height: 200, width: double.infinity);
      } catch (e) {
        return Image.asset('assets/placeholder.png', fit: BoxFit.cover, height: 200, width: double.infinity);
      }
    }
    return Image.asset('assets/placeholder.png', fit: BoxFit.cover, height: 200, width: double.infinity);
  }

  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.name}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality} - ${place.administrativeArea}";
      }
    } catch (e) {
      print("Erro ao buscar endereço: $e");
    }
    return "Endereço não disponível";
  }

  void _openGoogleMaps(double latitude, double longitude) async {
    String googleMapsUrl = "google.navigation:q=$latitude,$longitude";
    String googleMapsWebUrl = "https://www.google.com/maps/dir/?api=1&origin=${latitude},${longitude}&destination=${latitude},${longitude}";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else if (await canLaunch(googleMapsWebUrl)) {
      await launch(googleMapsWebUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível abrir o Google Maps')));
    }
  }

  Future<void> _sendNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'Canal de notificações',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }

  Future<void> _confirmColeta(String docId, String userId) async {
    await FirebaseFirestore.instance.collection('descartes').doc(docId).update({
      'status': 'coletado',
      'coletadoPor': userId,
      'dataColeta': FieldValue.serverTimestamp(),
    });
    _sendNotification('Coleta Confirmada!', 'O ponto de coleta foi confirmado e está pronto para ser coletado.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pontos de Coleta'), backgroundColor: Colors.green),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('descartes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os dados'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum ponto de coleta encontrado.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final materials = List<String>.from(doc['materials']);
              final time = doc['time'] ?? 'Sem horário';
              final imageBase64 = doc['imageBase64'];
              final createdAt = doc['createdAt']?.toDate();
              final docId = doc.id;
              final userId = doc['userId'];
              final location = doc['location'];
              final latitude = location?['latitude'];
              final longitude = location?['longitude'];

              return FutureBuilder(
                future: latitude != null && longitude != null
                    ? _getAddressFromLatLng(latitude, longitude)
                    : Future.value("Endereço não disponível"),
                builder: (context, AsyncSnapshot<String> addressSnapshot) {
                  final address = addressSnapshot.data ?? "Carregando endereço...";

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
                              Text('Materiais: ${materials.join(', ')}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Horário disponível: $time', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Endereço: $address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
                              Text('Criado em: ${createdAt != null ? '${createdAt.day}/${createdAt.month}/${createdAt.year} às ${createdAt.hour}:${createdAt.minute}' : 'Data não disponível'}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _confirmColeta(docId, userId),
                                    child: Text('Confirmar Coleta'),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _openGoogleMaps(latitude ?? 0, longitude ?? 0),
                                    child: Text('Ver no Mapa'),
                                  ),
                                ],
                              )
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
