import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String nomeCompleto;
  final String email;
  final String? cpf;
  final String? telefone;
  final String? endereco;
  final bool isAdmin;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.nomeCompleto,
    required this.email,
    this.cpf,
    this.telefone,
    this.endereco,
    this.isAdmin = false,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      nomeCompleto: data['nome_completo'] ?? '',
      email: data['email'] ?? '',
      cpf: data['cpf'],
      telefone: data['telefone'],
      endereco: data['endereco'],
      isAdmin: data['isAdmin'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome_completo': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'endereco': endereco,
      'isAdmin': isAdmin,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class DisposalModel {
  final String? id;
  final List<String> materials;
  final String? userId;
  final Map<String, dynamic>? location;
  final DateTime? createdAt;
  final String? imageBase64;

  DisposalModel({
    this.id,
    required this.materials,
    this.userId,
    this.location,
    this.createdAt,
    this.imageBase64,
  });

  factory DisposalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DisposalModel(
      id: doc.id,
      materials: List<String>.from(data['materials'] ?? []),
      userId: data['userId'],
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      imageBase64: data['imageBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materials': materials,
      'userId': userId,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
      if (imageBase64 != null) 'imageBase64': imageBase64,
    };
  }
}