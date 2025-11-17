import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeuPerfilController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docSnapshot = await _firestore.collection('cadastros').doc(user.uid).get();
    if (docSnapshot.exists) {
      return docSnapshot.data();
    }
    return null;
  }

  /// Atualiza os dados do usuário no Firestore e senha no Auth
  Future<void> updateUserData({
    required String nomeCompleto,
    required String email,
    required String cpf,
    required String endereco,
    required String telefone,
    String? senha,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Atualiza Firestore
    await _firestore.collection('cadastros').doc(user.uid).update({
      'nome_completo': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'endereco': endereco,
      'telefone': telefone,
    });

    // Atualiza senha se fornecida
    if (senha != null && senha.isNotEmpty) {
      await user.updatePassword(senha);
    }
  }
}
