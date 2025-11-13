import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/empresa_model.dart';

class EmpresaController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Stream<List<Empresa>> getEmpresasStream() {
    return _firestore.collection('empresas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Empresa.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<File?> selecionarImagem() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<bool> verificarCNPJ(String cnpj) async {
    final query = await _firestore.collection('empresas').where('cnpj', isEqualTo: cnpj).get();
    return query.docs.isNotEmpty;
  }

  bool validarCNPJ(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    if (cnpj.length != 14) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;

    int soma = 0;
    int peso = 5;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(cnpj[i]) * peso;
      peso = (peso == 2) ? 9 : peso - 1;
    }
    int digito1 = (soma % 11 < 2) ? 0 : 11 - (soma % 11);

    soma = 0;
    peso = 6;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(cnpj[i]) * peso;
      peso = (peso == 2) ? 9 : peso - 1;
    }
    int digito2 = (soma % 11 < 2) ? 0 : 11 - (soma % 11);

    return (int.parse(cnpj[12]) == digito1 && int.parse(cnpj[13]) == digito2);
  }

  Future<bool> validarCNPJNaReceita(String cnpj) async {
    final url = Uri.parse('https://receitaws.com.br/v1/cnpj/$cnpj');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['situacao'] == 'ATIVA';
    }
    return false;
  }

  Future<void> cadastrarEmpresa(Empresa empresa) async {
    await _firestore.collection('empresas').add(empresa.toMap());
  }

  Future<String> converterImagemParaBase64(File? imagem) async {
    if (imagem == null) return '';
    final bytes = await imagem.readAsBytes();
    return base64Encode(bytes);
  }
}
