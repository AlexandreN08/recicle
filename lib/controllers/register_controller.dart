import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Valida CPF (com dígitos verificadores)
  bool isCpfValid(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

    int sum = 0;
    for (int i = 0; i < 9; i++) sum += int.parse(cpf[i]) * (10 - i);
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;

    sum = 0;
    for (int i = 0; i < 10; i++) sum += int.parse(cpf[i]) * (11 - i);
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;

    return cpf[9] == firstDigit.toString() && cpf[10] == secondDigit.toString();
  }

  /// Verifica se o CPF já está cadastrado no Firestore
  Future<bool> isCpfRegistered(String cpf) async {
    final QuerySnapshot result = await _firestore
        .collection('cadastros')
        .where('cpf', isEqualTo: cpf)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  /// Registra um novo usuário
  Future<void> register({
    required String nomeCompleto,
    required String email,
    required String cpf,
    required String endereco,
    required String telefone,
    required String senha,
  }) async {
    // Criação do usuário no Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    // Salva informações adicionais no Firestore
    await _firestore.collection('cadastros').doc(userCredential.user!.uid).set({
      'nome_completo': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'endereco': endereco,
      'telefone': telefone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
