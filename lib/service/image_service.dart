import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

class ImageService {
  static Future<String> comprimirImagem(File imagem) async {
    final imageFile = img.decodeImage(imagem.readAsBytesSync());
    if (imageFile == null) throw Exception('Falha ao processar imagem.');
    final resized = img.copyResize(imageFile, width: 800);
    final compressed = File(imagem.path)..writeAsBytesSync(img.encodeJpg(resized));
    return base64Encode(compressed.readAsBytesSync());
  }
}
