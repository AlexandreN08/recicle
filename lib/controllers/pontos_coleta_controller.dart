import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/ponto_coleta_model.dart';

class PontosColetaController {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
  }

  Future<void> requestLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de localização negada')),
      );
    }
  }

  Image convertBase64ToImage(String? base64Image) {
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(base64Image),
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        );
      } catch (_) {}
    }
    return Image.asset('assets/placeholder.png',
        fit: BoxFit.cover, height: 200, width: double.infinity);
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks.first;
        return "${p.thoroughfare}, ${p.subLocality}, ${p.locality}";
      }
    } catch (_) {}
    return "Endereço não disponível";
  }

  Future<void> openGoogleMaps(
      double latitude, double longitude, BuildContext context) async {
    String googleMapsUrl = "google.navigation:q=$latitude,$longitude";
    String googleMapsWebUrl =
        "https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else if (await canLaunch(googleMapsWebUrl)) {
      await launch(googleMapsWebUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o Google Maps')),
      );
    }
  }

  Future<void> sendNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'Canal de notificações',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, body, details);
  }

  Future<void> confirmColeta(String docId, String userId) async {
    await FirebaseFirestore.instance.collection('descartes').doc(docId).update({
      'status': 'coletado',
      'coletadoPor': userId,
      'dataColeta': FieldValue.serverTimestamp(),
    });

    await sendNotification(
      'Coleta Confirmada!',
      'O ponto de coleta foi confirmado e removido da lista de pendentes.',
    );
  }

Stream<List<PontoColeta>> getPontosColeta() {
  return FirebaseFirestore.instance
      .collection('descartes')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .where((doc) {
              final data = doc.data();
              final status = data['status'];

              return status == null || status == 'pendente';
            })
            .map((doc) => PontoColeta.fromFirestore(doc))
            .toList();
      });
}
}
