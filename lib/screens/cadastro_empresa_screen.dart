import 'dart:io';
import 'package:flutter/material.dart';
import '../controllers/empresa_controller.dart';
import '../models/empresa_model.dart';

class CadastroEmpresaScreen extends StatefulWidget {
  const CadastroEmpresaScreen({super.key});

  @override
  _CadastroEmpresaScreenState createState() => _CadastroEmpresaScreenState();
}

class _CadastroEmpresaScreenState extends State<CadastroEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = EmpresaController();

  final _razaoController = TextEditingController();
  final _fantasiaController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cnpjController = TextEditingController();

  File? _imagemLogo;

  void _selecionarImagem() async {
    final imagem = await _controller.selecionarImagem();
    if (imagem != null) setState(() => _imagemLogo = imagem);
  }

  void _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    String cnpj = _cnpjController.text.trim();
    if (!_controller.validarCNPJ(cnpj)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CNPJ inválido!')));
      return;
    }

    if (!await _controller.validarCNPJNaReceita(cnpj)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CNPJ inativo na Receita Federal!')));
      return;
    }

    if (await _controller.verificarCNPJ(cnpj)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CNPJ já cadastrado!')));
      return;
    }

    final logoBase64 = await _controller.converterImagemParaBase64(_imagemLogo);

    final empresa = Empresa(
      id: '',
      razaoSocial: _razaoController.text.trim(),
      nomeFantasia: _fantasiaController.text.trim(),
      enderecoCompleto: _enderecoController.text.trim(),
      cnpj: cnpj,
      logoBase64: logoBase64,
    );

    await _controller.cadastrarEmpresa(empresa);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empresa cadastrada com sucesso!')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _razaoController.dispose();
    _fantasiaController.dispose();
    _enderecoController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Empresa'), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _selecionarImagem,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imagemLogo != null ? FileImage(_imagemLogo!) : null,
                  child: _imagemLogo == null ? const Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _razaoController,
                decoration: const InputDecoration(labelText: 'Razão Social'),
                validator: (v) => v!.isEmpty ? 'Informe a razão social' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fantasiaController,
                decoration: const InputDecoration(labelText: 'Nome Fantasia'),
                validator: (v) => v!.isEmpty ? 'Informe o nome fantasia' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço Completo'),
                validator: (v) => v!.isEmpty ? 'Informe o endereço completo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cnpjController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'CNPJ'),
                validator: (v) => v!.isEmpty ? 'Informe o CNPJ' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cadastrar,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
                child: const Text('Cadastrar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
