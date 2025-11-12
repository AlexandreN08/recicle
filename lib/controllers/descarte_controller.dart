import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recicle/service/firebase_service.dart';
import 'package:recicle/service/image_service.dart';
import 'package:recicle/service/location_service.dart';
import '../models/descarte_model.dart';

class DescarteController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> salvarDescarte({
    required List<String> materiais,
    required File imagem,
    required DateTime dataHora,
    required BuildContext context,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      final posicao = await LocationService.obterLocalizacao(context);
      if (posicao == null) throw Exception("Localização não disponível.");

      final imagemBase64 = await ImageService.comprimirImagem(imagem);
      final token = await FirebaseService.obterTokenFCM();

      final descarte = DescarteModel(
        userId: user.uid,
        materials: materiais,
        imageBase64: imagemBase64,
        dateTime: dataHora,
        latitude: posicao.latitude,
        longitude: posicao.longitude,
        userToken: token,
      );

      await FirebaseFirestore.instance
          .collection('descartes')
          .add(descarte.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descarte salvo com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar descarte: $e')),
      );
    }
  }
}
