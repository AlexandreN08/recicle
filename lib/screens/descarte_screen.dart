import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/descarte_controller.dart';

class DescarteScreen extends StatefulWidget {
  const DescarteScreen({super.key});

  @override
  State<DescarteScreen> createState() => _DescarteScreenState();
}

class _DescarteScreenState extends State<DescarteScreen> {
  final DescarteController _controller = DescarteController();
  final List<String> _materiaisSelecionados = [];
  File? _imagemSelecionada;
  DateTime? _dataHora;
  bool _loading = false;

  final List<Map<String, dynamic>> _materiais = [
    {'title': 'Vidro', 'color': Colors.green, 'icon': Icons.wine_bar},
    {'title': 'Plástico', 'color': Colors.red, 'icon': Icons.recycling},
    {'title': 'Papelão', 'color': Colors.blue, 'icon': Icons.archive},
    {'title': 'Metal', 'color': Colors.yellow, 'icon': Icons.device_hub},
    {'title': 'Eletrônico', 'color': Colors.orange, 'icon': Icons.phone_iphone},
  ];

  Future<void> _selecionarImagem({bool camera = false}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked != null) setState(() => _imagemSelecionada = File(picked.path));
  }

  Future<void> _selecionarDataHora() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora == null) return;

    setState(() {
      _dataHora =
          DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
    });
  }

  Future<void> _salvar() async {
    if (_materiaisSelecionados.isEmpty ||
        _imagemSelecionada == null ||
        _dataHora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => _loading = true);
    await _controller.salvarDescarte(
      materiais: _materiaisSelecionados,
      imagem: _imagemSelecionada!,
      dataHora: _dataHora!,
      context: context,
    );
    setState(() {
      _loading = false;
      _materiaisSelecionados.clear();
      _imagemSelecionada = null;
      _dataHora = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Descartar Reciclável'),
          backgroundColor: Colors.green),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecione os materiais:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                itemCount: _materiais.length,
                itemBuilder: (_, i) {
                  final m = _materiais[i];
                  final selecionado =
                      _materiaisSelecionados.contains(m['title']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selecionado
                            ? _materiaisSelecionados.remove(m['title'])
                            : _materiaisSelecionados.add(m['title']);
                      });
                    },
                    child: Card(
                      color: selecionado
                          ? m['color'].withOpacity(0.6)
                          : m['color'],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(m['icon'], color: Colors.white, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              m['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Text(
                'Carregue uma imagem dos materiais a serem descartados:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _selecionarImagem(camera: true),
                    child: const Text('Tirar Foto'),
                  ),
                  ElevatedButton(
                    onPressed: _selecionarImagem,
                    child: const Text('Selecionar Foto'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _imagemSelecionada != null
                  ? Image.file(_imagemSelecionada!, width: 200, height: 200)
                  : const Text('Nenhuma imagem selecionada'),

              const SizedBox(height: 20),

              Text(
                'Selecione um Horario disponível para coleta:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Center(
                child: ElevatedButton(
                  onPressed: _selecionarDataHora,
                  child: Text(
                    _dataHora != null
                        ? 'Selecionado: ${_dataHora!.toLocal()}'
                        : 'Escolher Data e Hora',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: ElevatedButton(
                        onPressed: _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                        ),
                        child: const Text('Salvar'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
