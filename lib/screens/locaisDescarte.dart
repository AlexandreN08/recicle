import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class LocaisDescarteScreen extends StatefulWidget {
  const LocaisDescarteScreen({super.key});

  @override
  _LocaisDescarteScreenState createState() => _LocaisDescarteScreenState();
}

class _LocaisDescarteScreenState extends State<LocaisDescarteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para abrir o Google Maps com a rota para o local
  void _openMaps(String endereco) async {
    String url = 'https://www.google.com/maps/search/?api=1&query=$endereco';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locais de Descarte'),
        backgroundColor: Colors.green,
        titleTextStyle: TextStyle(
          color: Colors.white, // Cor do título do AppBar
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('empresas').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var empresas = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: empresas.length,
                    itemBuilder: (context, index) {
                      var empresa = empresas[index].data() as Map<String, dynamic>;
                      String nomeFantasia = empresa['nomeFantasia'] ?? 'Nome não disponível';
                      String enderecoCompleto = empresa['enderecoCompleto'] ?? 'Endereço não disponível';
                      String logoBase64 = empresa['logoBase64'] ?? '';

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: logoBase64.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(base64Decode(logoBase64)),
                                )
                              : CircleAvatar(
                                  child: Icon(Icons.business),
                                ),
                          title: Text(nomeFantasia),
                          subtitle: Text(enderecoCompleto),
                          trailing: IconButton(
                            icon: Icon(Icons.directions),
                            onPressed: () => _openMaps(enderecoCompleto),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CadastroEmpresaScreen()),
                  );
                },
                child: Text('Cadastrar Empresa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white, // Cor do texto do botão
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CadastroEmpresaScreen extends StatefulWidget {
  const CadastroEmpresaScreen({super.key});

  @override
  _CadastroEmpresaScreenState createState() => _CadastroEmpresaScreenState();
}

class _CadastroEmpresaScreenState extends State<CadastroEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _razaoSocialController = TextEditingController();
  final _nomeFantasiaController = TextEditingController();
  final _enderecoCompletoController = TextEditingController();
  final _cnpjController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _imagemLogo;
  final ImagePicker _picker = ImagePicker();

  // Função para selecionar uma imagem
  Future<void> _selecionarImagem() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagemLogo = File(pickedFile.path);
      });
    }
  }

  // Função para verificar se o CNPJ já está cadastrado
  Future<bool> _verificarCNPJ(String cnpj) async {
    final query = await _firestore.collection('empresas').where('cnpj', isEqualTo: cnpj).get();
    return query.docs.isNotEmpty;
  }

  // Função para validar o CNPJ localmente (algoritmo de dígitos verificadores)
  bool _validarCNPJ(String cnpj) {
    // Remove caracteres não numéricos
    cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica se o CNPJ tem 14 dígitos
    if (cnpj.length != 14) return false;

    // Verifica se todos os dígitos são iguais (ex: 00000000000000)
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;

    // Cálculo do primeiro dígito verificador
    int soma = 0;
    int peso = 5;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(cnpj[i]) * peso;
      peso = (peso == 2) ? 9 : peso - 1;
    }
    int digito1 = (soma % 11 < 2) ? 0 : 11 - (soma % 11);

    // Cálculo do segundo dígito verificador
    soma = 0;
    peso = 6;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(cnpj[i]) * peso;
      peso = (peso == 2) ? 9 : peso - 1;
    }
    int digito2 = (soma % 11 < 2) ? 0 : 11 - (soma % 11);

    // Verifica se os dígitos calculados são iguais aos informados
    return (int.parse(cnpj[12]) == digito1 && int.parse(cnpj[13]) == digito2);
  }

  // Função para consultar a API da Receita WS e verificar se o CNPJ é válido
  Future<bool> _validarCNPJNaReceita(String cnpj) async {
    final url = Uri.parse('https://receitaws.com.br/v1/cnpj/$cnpj');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['situacao'] == 'ATIVA'; // Verifica se o CNPJ está ativo
    } else {
      return false;
    }
  }

  void _cadastrarEmpresa() async {
    if (_formKey.currentState!.validate()) {
      String razaoSocial = _razaoSocialController.text.trim();
      String nomeFantasia = _nomeFantasiaController.text.trim();
      String enderecoCompleto = _enderecoCompletoController.text.trim();
      String cnpj = _cnpjController.text.trim();

      // Verifica se o CNPJ é válido localmente
      if (!_validarCNPJ(cnpj)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CNPJ inválido!')),
        );
        return;
      }

      // Verifica se o CNPJ é válido na Receita Federal
      bool cnpjValidoNaReceita = await _validarCNPJNaReceita(cnpj);
      if (!cnpjValidoNaReceita) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CNPJ não encontrado na Receita Federal!')),
        );
        return;
      }

      // Verifica se o CNPJ já está cadastrado
      bool cnpjExiste = await _verificarCNPJ(cnpj);
      if (cnpjExiste) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CNPJ já cadastrado!')),
        );
        return;
      }

      // Converte a imagem para Base64
      String logoBase64 = '';
      if (_imagemLogo != null) {
        final bytes = await _imagemLogo!.readAsBytes();
        logoBase64 = base64Encode(bytes);
      }

      // Cadastra a empresa no Firestore
      await _firestore.collection('empresas').add({
        'razaoSocial': razaoSocial,
        'nomeFantasia': nomeFantasia,
        'enderecoCompleto': enderecoCompleto,
        'cnpj': cnpj,
        'logoBase64': logoBase64,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Empresa cadastrada com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _razaoSocialController.dispose();
    _nomeFantasiaController.dispose();
    _enderecoCompletoController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Empresa'),
        backgroundColor: Colors.green,
        titleTextStyle: TextStyle(
          color: Colors.white, // Cor do título do AppBar
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Campo para carregar a imagem
                  GestureDetector(
                    onTap: _selecionarImagem,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imagemLogo != null ? FileImage(_imagemLogo!) : null,
                      child: _imagemLogo == null ? Icon(Icons.camera_alt, size: 40) : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _razaoSocialController,
                    decoration: InputDecoration(labelText: 'Razão Social'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a razão social.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _nomeFantasiaController,
                    decoration: InputDecoration(labelText: 'Nome Fantasia'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome fantasia.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _enderecoCompletoController,
                    decoration: InputDecoration(labelText: 'Endereço Completo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o endereço completo.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _cnpjController,
                    decoration: InputDecoration(labelText: 'CNPJ'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o CNPJ.';
                      }
                      if (value.length != 14) {
                        return 'CNPJ deve ter 14 dígitos.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _cadastrarEmpresa,
                    child: Text('Cadastrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white, // Cor do texto do botão
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}