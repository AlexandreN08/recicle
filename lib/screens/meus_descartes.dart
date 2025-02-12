import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';  // Para decodificar a base64 da imagem
import 'package:geocoding/geocoding.dart';  // Para geolocalização (caso queira buscar o endereço pela latitude e longitude)

class MeusDescartesScreen extends StatefulWidget {
  @override
  _MeusDescartesScreenState createState() => _MeusDescartesScreenState();
}

class _MeusDescartesScreenState extends State<MeusDescartesScreen> {
  // Função para deletar o descarte
  Future<void> _deleteDescarte(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('descartes').doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Descarte deletado com sucesso!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar: $error')),
      );
    }
  }

  // Função para converter base64 para imagem
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

  @override
  Widget build(BuildContext context) {
    // Pegando o UID do usuário autenticado
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Meus Descartes'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Text('Você precisa estar logado para ver seus descartes.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Descartes'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('descartes')
              .where('userId', isEqualTo: user.uid)  // Filtra pelos descartes do usuário logado
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
                final materials = List<String>.from(doc['materials']);
                final time = doc['time'] ?? 'Sem horário';
                final createdAt = doc['createdAt']?.toDate();
                final documentId = doc.id;
                final imageBase64 = doc['imageBase64'];
                final latitude = doc['location']['latitude'];
                final longitude = doc['location']['longitude'];

                // A variável para armazenar o endereço
                String address = "Carregando endereço...";

                // Usar um FutureBuilder para carregar o endereço e evitar o flickering
                if (latitude != null && longitude != null) {
                  // Chama a função para obter o endereço de forma assíncrona
                  return FutureBuilder<String>(
                    future: _getAddressFromLatLng(latitude, longitude), // Função para buscar o endereço
                    builder: (context, addressSnapshot) {
                      // Verifica o estado do carregamento do endereço
                      if (addressSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (addressSnapshot.hasError) {
                        return Text('Erro ao carregar o endereço');
                      }

                      address = addressSnapshot.data ?? "Endereço não disponível"; // Atualiza o endereço

                      return Card(
                        margin: EdgeInsets.all(10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Exibir a imagem
                              _convertBase64ToImage(imageBase64),
                              SizedBox(height: 10),

                              // Exibir os materiais descartados
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

                              // Data de criação
                              Text(
                                'Criado em: ${createdAt != null ? '${createdAt.day}/${createdAt.month}/${createdAt.year} às ${createdAt.hour}:${createdAt.minute}' : 'Data não disponível'}',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 12),

                              // Endereço do local
                              Text(
                                'Endereço: $address',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 12),

                              // Botão de excluir
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => _deleteDescarte(documentId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  label: Text('Excluir Descarte', style: TextStyle(fontSize: 16, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('Localização não disponível'));
                }
              },
            );
          },
        ),
      ),
    );
  }
}
