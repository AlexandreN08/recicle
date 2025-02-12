import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class PontosColetaScreen extends StatefulWidget {
  @override
  _PontosColetaScreenState createState() => _PontosColetaScreenState();
}

class _PontosColetaScreenState extends State<PontosColetaScreen> {
  // Função para solicitar permissões de localização
  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      // Permissão concedida, podemos continuar
      print("Permissão de localização concedida!");
    } else {
      // Permissão negada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de localização negada')),
      );
    }
  }

  // Função para converter Base64 para imagem
  Image _convertBase64ToImage(String? base64Image) {
    if (base64Image != null && base64Image.isNotEmpty) {
      return Image.memory(
        base64Decode(base64Image),
        fit: BoxFit.cover,
        height: 200, // Altura ajustada para manter um layout melhor
        width: double.infinity,
      );
    } else {
      return Image.asset('assets/placeholder.png', fit: BoxFit.cover, height: 200, width: double.infinity);
    }
  }

  // Função para obter o endereço a partir da latitude e longitude
  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.subLocality}, ${place.locality} - ${place.administrativeArea}";
      }
    } catch (e) {
      print("Erro ao buscar endereço: $e");
    }
    return "Endereço não disponível";
  }

  // Função para abrir o Google Maps corrigida
  void _openGoogleMaps(double latitude, double longitude) async {
    String googleMapsUrl = "geo:$latitude,$longitude"; // Para Android e iOS
    String googleMapsWebUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude"; // Para Web

    // Tentando abrir no Google Maps
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

  @override
  Widget build(BuildContext context) {
    // Solicitar permissões de localização quando a tela for carregada
    requestLocationPermission();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pontos de Coleta'),
        backgroundColor: Colors.green,
      ),
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

              // Obtendo localização
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
                        // Exibir imagem do descarte
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: _convertBase64ToImage(imageBase64),
                        ),

                        // Conteúdo do cartão
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Materiais descartados
                              Text(
                                'Materiais: ${materials.join(', ')}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),

                              // Horário disponível
                              Text(
                                'Horário disponível: $time',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),

                              // Endereço do local
                              Text(
                                'Endereço: $address',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 8),

                              // Data de criação
                              Text(
                                'Criado em: ${createdAt != null ? '${createdAt.day}/${createdAt.month}/${createdAt.year} às ${createdAt.hour}:${createdAt.minute}' : 'Data não disponível'}',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 12),
                              // Botão para abrir no Google Maps
                              if (latitude != null && longitude != null)
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openGoogleMaps(latitude, longitude),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: Icon(Icons.map, color: Colors.white),
                                    label: Text(
                                      'Abrir no Google Maps',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
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
