import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

class AdminController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= USUÁRIOS =================
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore
        .collection('cadastros')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addUser({
    required String nomeCompleto,
    required String email,
    String? cpf,
    String? telefone,
    String? endereco,
    bool isAdmin = false,
  }) async {
    await _firestore.collection('cadastros').add({
      'nome_completo': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'endereco': endereco,
      'isAdmin': isAdmin,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser({
    required String docId,
    required String nomeCompleto,
    required String email,
    String? cpf,
    String? telefone,
    String? endereco,
  }) async {
    await _firestore.collection('cadastros').doc(docId).update({
      'nome_completo': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'endereco': endereco,
    });
  }

  Future<void> toggleAdminStatus(String docId, bool newStatus) async {
    await _firestore
        .collection('cadastros')
        .doc(docId)
        .update({'isAdmin': newStatus});
  }

  Future<void> deleteUser(String docId) async {
    await _firestore.collection('cadastros').doc(docId).delete();
  }

  // ================= DESCARTES =================
  Stream<QuerySnapshot> getDisposalsStream({int? limit}) {
    Query query = _firestore
        .collection('descartes')
        .orderBy('createdAt', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query.snapshots();
  }

  Future<void> deleteDisposal(String docId) async {
    await _firestore.collection('descartes').doc(docId).delete();
  }

  // ================= ESTATÍSTICAS =================
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  Future<Map<String, int>> getMaterialsCount() async {
    final snapshot = await _firestore.collection('descartes').get();
    Map<String, int> materialCount = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final materials = data['materials'] as List<dynamic>? ?? [];

      for (var material in materials) {
        final materialName = material.toString();
        materialCount[materialName] = (materialCount[materialName] ?? 0) + 1;
      }
    }

    return materialCount;
  }

  Future<int> getTotalMaterials() async {
    final snapshot = await _firestore.collection('descartes').get();
    int total = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final materials = data['materials'] as List<dynamic>? ?? [];
      total += materials.length;
    }

    return total;
  }

  // ================= AUTENTICAÇÃO =================
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ================= GEOCODING REVERSO =================
  Future<String> getAddressFromLatLng(dynamic lat, dynamic lng) async {
    try {
      if (lat == null || lng == null) return 'Endereço não disponível';

      // Garantir que sejam double
      final latitude = lat is double ? lat : double.tryParse(lat.toString());
      final longitude = lng is double ? lng : double.tryParse(lng.toString());

      if (latitude == null || longitude == null) return 'Endereço não disponível';

      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return 'Endereço não disponível';

      final place = placemarks.first;
      return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}';
    } catch (e) {
      print('Erro ao converter coordenadas em endereço: $e');
      return 'Endereço não disponível';
    }
  }
}
