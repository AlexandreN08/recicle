class DescarteModel {
  final String userId;
  final List<String> materials;
  final String imageBase64;
  final DateTime dateTime;
  final double latitude;
  final double longitude;
  final String? userToken;

  DescarteModel({
    required this.userId,
    required this.materials,
    required this.imageBase64,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    this.userToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'materials': materials,
      'time': dateTime.toIso8601String(),
      'imageBase64': imageBase64,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'userToken': userToken,
      'createdAt': DateTime.now(),
    };
  }
}
