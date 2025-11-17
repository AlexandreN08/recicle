import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/pontos_coleta_controller.dart';
import '../models/ponto_coleta_model.dart';

class PontosColetaScreen extends StatefulWidget {
  const PontosColetaScreen({super.key});

  @override
  State<PontosColetaScreen> createState() => _PontosColetaScreenState();
}

class _PontosColetaScreenState extends State<PontosColetaScreen> {
  final PontosColetaController _controller = PontosColetaController();

  @override
  void initState() {
    super.initState();
    _controller.initNotifications();
    _controller.requestLocationPermission(context);
  }


  DateTime? parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    try {
      if (time.contains('-')) {
        return DateTime.parse(time);
      } else if (time.contains(':')) {
        final parts = time.split(':');
        return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String formatDateTime(DateTime? dt) {
    if (dt == null) return 'Horário não definido';
    final formatter = DateFormat('dd/MM/yyyy – HH:mm');
    return formatter.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pontos de Coleta'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<PontoColeta>>(
        stream: _controller.getPontosColeta(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os dados'));
          }

          final pontos = snapshot.data ?? [];
          if (pontos.isEmpty) {
            return const Center(child: Text('Nenhum ponto de coleta encontrado.'));
          }

          return ListView.builder(
            itemCount: pontos.length,
            itemBuilder: (context, index) {
              final ponto = pontos[index];

              return FutureBuilder<String>(
                future: (ponto.latitude != null && ponto.longitude != null)
                    ? _controller.getAddressFromLatLng(ponto.latitude!, ponto.longitude!)
                    : Future.value("Endereço não disponível"),
                builder: (context, addressSnapshot) {
                  final address = addressSnapshot.data ?? "Carregando endereço...";

                  final timeDt = parseTime(ponto.time);

                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ponto.imageBase64 != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: _controller.convertBase64ToImage(ponto.imageBase64!),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Materiais: ${ponto.materials.join(', ')}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Horário disponível: ${formatDateTime(timeDt)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Endereço: $address',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Criado em: ${formatDateTime(ponto.createdAt)}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                    showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmar Coleta'),
        content: const Text('Tem certeza que deseja confirmar a coleta deste descarte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 

              // Chama o método que confirma no Firestore
              await _controller.confirmColeta(ponto.id, ponto.userId);

              setState(() {});
            },
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
},

                                    child: const Text('Confirmar Coleta'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _controller.openGoogleMaps(
                                      ponto.latitude ?? 0,
                                      ponto.longitude ?? 0,
                                      context,
                                    ),
                                    child: const Text('Ver no Mapa'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
