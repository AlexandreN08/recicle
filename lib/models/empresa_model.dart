class Empresa {
  final String id;
  final String razaoSocial;
  final String nomeFantasia;
  final String enderecoCompleto;
  final String cnpj;
  final String logoBase64;

  Empresa({
    required this.id,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.enderecoCompleto,
    required this.cnpj,
    required this.logoBase64,
  });

  factory Empresa.fromMap(String id, Map<String, dynamic> data) {
    return Empresa(
      id: id,
      razaoSocial: data['razaoSocial'] ?? '',
      nomeFantasia: data['nomeFantasia'] ?? '',
      enderecoCompleto: data['enderecoCompleto'] ?? '',
      cnpj: data['cnpj'] ?? '',
      logoBase64: data['logoBase64'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'razaoSocial': razaoSocial,
      'nomeFantasia': nomeFantasia,
      'enderecoCompleto': enderecoCompleto,
      'cnpj': cnpj,
      'logoBase64': logoBase64,
    };
  }
}
