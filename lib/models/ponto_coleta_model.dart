import 'package:cloud_firestore/cloud_firestore.dart';

class PontoColeta {
  final String id;
  final List<String> materials;
  final String? time;
  final String? imageBase64;
  final DateTime? createdAt;
  final String userId;
  final double? latitude;
  final double? longitude;

  PontoColeta({
    required this.id,
    required this.materials,
    this.time,
    this.imageBase64,
    this.createdAt,
    required this.userId,
    this.latitude,
    this.longitude,
  });

  factory PontoColeta.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PontoColeta(
      id: doc.id,
      materials: List<String>.from(data['materials'] ?? []),
      time: data['time'],
      imageBase64: data['imageBase64'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      userId: data['userId'] ?? '',
      latitude: data['location']?['latitude'],
      longitude: data['location']?['longitude'],
    );
  }
}
