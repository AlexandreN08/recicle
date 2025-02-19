import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeusDescartesScreen extends StatefulWidget {
  @override
  _MeusDescartesScreenState createState() => _MeusDescartesScreenState();
}

class _MeusDescartesScreenState extends State<MeusDescartesScreen> {
  // Função para remover o descarte do Firestore
  Future<void> _removerDescarte(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('descartes').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Descarte removido com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao remover o descarte')));
    }
  }

  // Função para confirmar a coleta e mudar o status para 'Coletado'
  Future<void> _confirmarColeta(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('descartes').doc(docId).update({'status': 'Coletado'});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coleta confirmada!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao confirmar coleta')));
    }
  }

  // Função para converter a imagem de base64 para Image widget
  Image _convertBase64ToImage(String? base64Image) {
    if (base64Image != null && base64Image.isNotEmpty) {
      return Image.memory(base64Decode(base64Image), fit: BoxFit.cover, height: 200, width: double.infinity);
    } else {
      return Image.asset('assets/placeholder.png', fit: BoxFit.cover, height: 200, width: double.infinity);
    }
  }

  // Função para buscar o endereço completo a partir da latitude e longitude
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Descartes'),
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
                                  SizedBox(height: 8), // Espaçamento entre os botões
                                  ElevatedButton.icon(
                                    onPressed: () => _confirmarColeta(docId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green, // Cor verde
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
