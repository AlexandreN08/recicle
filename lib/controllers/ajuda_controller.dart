import 'package:url_launcher/url_launcher.dart';

class AjudaController {
  final String suporteEmail = 'alexandrenecher@gmail.com';
  final String suporteWhatsApp = '5546999185491';

  /// Envia e-mail com o corpo da mensagem
  Future<void> enviarEmail(String mensagem) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: suporteEmail,
      queryParameters: {
        'subject': 'Dúvida de Suporte',
        'body': mensagem,
      },
    );
    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  }

  /// Abre WhatsApp com mensagem
  Future<void> enviarWhatsApp(String mensagem) async {
    final String text = 'Olá, tenho uma dúvida: $mensagem';
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$suporteWhatsApp?text=${Uri.encodeFull(text)}',
    );
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }
}
