import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/empresa_controller.dart';
import '../models/empresa_model.dart';
import 'cadastro_empresa_screen.dart';

class LocaisDescarteScreen extends StatelessWidget {
  final EmpresaController _controller = EmpresaController();

  LocaisDescarteScreen({super.key});

  void _openMaps(String endereco) async {
    final url = Uri.encodeFull('https://www.google.com/maps/search/?api=1&query=$endereco');
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Não foi possível abrir o Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locais de Descarte'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Empresa>>(
        stream: _controller.getEmpresasStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final empresas = snapshot.data!;
          if (empresas.isEmpty) return const Center(child: Text('Nenhuma empresa cadastrada.'));

          return ListView.builder(
            itemCount: empresas.length,
            itemBuilder: (context, index) {
              final e = empresas[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: e.logoBase64.isNotEmpty
                      ? CircleAvatar(backgroundImage: MemoryImage(base64Decode(e.logoBase64)))
                      : const CircleAvatar(child: Icon(Icons.business)),
                  title: Text(e.nomeFantasia),
                  subtitle: Text(e.enderecoCompleto),
                  trailing: IconButton(
                    icon: const Icon(Icons.directions),
                    onPressed: () => _openMaps(e.enderecoCompleto),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CadastroEmpresaScreen()),
          );
        },
        icon: const Icon(Icons.add_business),
        label: const Text('Cadastrar Empresa'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
