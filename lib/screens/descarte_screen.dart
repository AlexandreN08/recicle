import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase inicializado com sucesso!');
  } catch (e) {
    print('Erro ao inicializar o Firebase: $e');
    return; // Se o Firebase falhar na inicialização, impede a execução do app
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recicle App',
      home: DescarteScreen(),
    );
  }
}

class DescarteScreen extends StatefulWidget {
  @override
  _DescarteScreenState createState() => _DescarteScreenState();
}

class _DescarteScreenState extends State<DescarteScreen> {
  List<String> selectedMaterials = [];
  File? selectedImage;
  TimeOfDay? selectedTime;
  bool isLoading = false;

  final List<Map<String, dynamic>> materials = [
    {'title': 'Vidro', 'color': Colors.green},
    {'title': 'Plástico', 'color': Colors.red},
    {'title': 'Papelão', 'color': Colors.orange},
    {'title': 'Metal', 'color': Colors.yellow},
    {'title': 'Eletrônico', 'color': Colors.blue},
  ];

  // Função para selecionar o horário
  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  // Função para selecionar a imagem da galeria
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhuma imagem foi selecionada.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir a galeria: $e')),
      );
    }
  }

  // Função para tirar uma foto
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhuma foto foi capturada.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao acessar a câmera: $e')),
      );
    }
  }

  // Função para salvar os dados no Firestore
  Future<void> _saveToFirestore() async {
    if (selectedMaterials.isEmpty || selectedImage == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos antes de salvar!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('Preparando para salvar no Firestore...'); // Log de depuração

      // Converter a imagem para Base64
      final bytes = await selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      print('Imagem convertida para Base64.'); // Log de depuração

      // Salvar os dados no Firestore
      final docRef = await FirebaseFirestore.instance.collection('descartes').add({
        'materials': selectedMaterials,
        'time': '${selectedTime!.hour}:${selectedTime!.minute}',
        'imageBase64': base64Image, // Salvar a imagem como Base64
        'createdAt': FieldValue.serverTimestamp(), // Timestamp gerado pelo Firestore
      });

      print('Documento criado com ID: ${docRef.id}'); // Log de depuração
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados salvos com sucesso!')),
      );

      setState(() {
        selectedMaterials = [];
        selectedImage = null;
        selectedTime = null;
      });
    } catch (error) {
      print('Erro ao salvar no Firestore: $error'); // Log de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Descartar Reciclável'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Selecione os materiais a serem descartados:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final material = materials[index];
                    final isSelected = selectedMaterials.contains(material['title']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedMaterials.remove(material['title']);
                          } else {
                            selectedMaterials.add(material['title']);
                          }
                        });
                      },
                      child: Card(
                        color: isSelected
                            ? material['color'].withOpacity(0.6)
                            : material['color'],
                        elevation: isSelected ? 8 : 2,
                        shadowColor: isSelected ? Colors.black : null,
                        child: Center(
                          child: Text(
                            material['title'],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Selecione ou tire uma foto dos materiais:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _captureImage,
                      child: Text('Tirar Foto'),
                    ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Selecionar Foto'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (selectedImage != null)
                  Image.file(selectedImage!, height: 150, fit: BoxFit.cover),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Selecione o horário disponível para coleta:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectTime,
                  child: Text(selectedTime == null
                      ? 'Selecionar Horário'
                      : 'Horário: ${selectedTime!.format(context)}'),
                ),
                SizedBox(height: 16),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveToFirestore,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: Text('Salvar Descarte'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
