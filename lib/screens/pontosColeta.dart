import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class PontosColetaScreen extends StatefulWidget {
  @override
  _PontosColetaScreenState createState() => _PontosColetaScreenState();
}

class _PontosColetaScreenState extends State<PontosColetaScreen> {
  // Função para converter Base64 de volta para imagem
  Image _convertBase64ToImage(String? base64Image) {
    // Verifica se a string Base64 não é nula ou vazia
    if (base64Image != null && base64Image.isNotEmpty) {
      return Image.memory(
        base64Decode(base64Image),
        fit: BoxFit.cover,
      );
    } else {
      // Se não houver imagem, retorna uma imagem placeholder
      return Image.asset('assets/placeholder.png', fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              final imageBase64 = doc['imageBase64'];  // Agora sem o "?? ''"
              final createdAt = doc['createdAt']?.toDate();

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(
                    'Materiais: ${materials.join(', ')}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    // Exibindo a imagem (se existir)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _convertBase64ToImage(imageBase64),  // Passando o valor do Base64
                    ),
                    SizedBox(height: 8),

                    // Exibindo o horário
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Horário: $time',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Exibindo a data de criação
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Criado em: ${createdAt != null ? '${createdAt.day}/${createdAt.month}/${createdAt.year} às ${createdAt.hour}:${createdAt.minute}' : 'Data não disponível'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
