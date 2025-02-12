import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
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
    return;
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
    {'title': 'Vidro', 'color': Colors.green, 'icon': Icons.wine_bar},
    {'title': 'Plástico', 'color': Colors.red, 'icon': Icons.recycling},
    {'title': 'Papelão', 'color': Colors.blue, 'icon': Icons.archive},
    {'title': 'Metal', 'color': Colors.yellow, 'icon': Icons.device_hub},
    {'title': 'Eletrônico', 'color': Colors.orange, 'icon': Icons.phone_iphone},
  ];

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ative a localização para continuar.')),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão de localização negada.')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de localização permanentemente negada.')),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

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
      // Obtém o UID do usuário autenticado
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você precisa estar logado para fazer um descarte.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      Position? position = await _getCurrentLocation();
      if (position == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final bytes = await selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      await FirebaseFirestore.instance.collection('descartes').add({
        'userId': user.uid,  // Adiciona o UID do usuário
        'materials': selectedMaterials,
        'time': '${selectedTime!.hour}:${selectedTime!.minute}',
        'imageBase64': base64Image,
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados salvos com sucesso!')),
      );

      setState(() {
        selectedMaterials = [];
        selectedImage = null;
        selectedTime = null;
      });
    } catch (error) {
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
                Text(
                  'Selecione os materiais:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor, 
                  ),
                  textAlign: TextAlign.center,
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
                          isSelected
                              ? selectedMaterials.remove(material['title'])
                              : selectedMaterials.add(material['title']);
                        });
                      },
                      child: Card(
                        color: isSelected ? material['color'].withOpacity(0.6) : material['color'],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(material['icon'], size: 40, color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                material['title'],
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Selecione uma imagem do material a ser descartado:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: _captureImage, child: Text('Tirar Foto')),
                    ElevatedButton(onPressed: _pickImage, child: Text('Selecionar Foto')),
                  ],
                ),
                if (selectedImage != null) Image.file(selectedImage!, height: 150, fit: BoxFit.cover),
                SizedBox(height: 16),
                Text(
                  'Selecione o Horário disponível para coleta:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
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
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: Text('Salvar Descarte', style: TextStyle(fontSize: 18)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
