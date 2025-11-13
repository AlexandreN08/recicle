import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/admin_controller.dart';

class SettingsView extends StatelessWidget {
  final AdminController controller;

  const SettingsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações do Sistema',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _buildConfigSection(
            'Informações do Sistema',
            Icons.info_outline,
            Colors.blue,
            [
              _buildInfoTile('Versão do App', '1.0.0'),
              _buildInfoTile('Última Atualização', '12/09/2025'),
              _buildInfoTile('Ambiente', 'Produção'),
              _buildInfoTile('Firebase Project', 'recicle-app'),
            ],
          ),
          const SizedBox(height: 24),
          _buildConfigSection(
            'Estatísticas Gerais',
            Icons.bar_chart,
            Colors.green,
            [
              _buildStreamStatTile('Total de Usuários', 'cadastros'),
              _buildStreamStatTile('Total de Descartes', 'descartes'),
              _buildStreamStatTile('Total de Empresas', 'empresas'),
              _buildStreamStatTile('Total de Notificações', 'notificacoes'),
            ],
          ),
          const SizedBox(height: 24),
          _buildConfigSection(
            'Gerenciamento de Dados',
            Icons.storage,
            Colors.orange,
            [
              _buildActionTile(
                context,
                'Backup do Banco de Dados',
                'Exportar todos os dados do sistema',
                Icons.backup,
                Colors.blue,
                () => _exportData(context),
              ),
              _buildActionTile(
                context,
                'Limpar Cache',
                'Remover dados temporários do sistema',
                Icons.cleaning_services,
                Colors.purple,
                () => _clearCache(context),
              ),
              _buildActionTile(
                context,
                'Logs do Sistema',
                'Visualizar histórico de atividades',
                Icons.article,
                Colors.teal,
                () => _showLogs(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildConfigSection(
            'Notificações',
            Icons.notifications,
            Colors.purple,
            [
              _buildSwitchTile(
                context,
                'Notificações por Email',
                'Enviar notificações administrativas por email',
                true,
                (value) => _updateNotificationSetting(context, 'email', value),
              ),
              _buildSwitchTile(
                context,
                'Alertas de Novos Usuários',
                'Receber alerta quando um novo usuário se cadastrar',
                true,
                (value) => _updateNotificationSetting(context, 'newUsers', value),
              ),
              _buildSwitchTile(
                context,
                'Relatórios Semanais',
                'Receber relatório semanal de atividades',
                false,
                (value) => _updateNotificationSetting(context, 'weeklyReports', value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildConfigSection(
            'Manutenção',
            Icons.build,
            Colors.red,
            [
              _buildActionTile(
                context,
                'Modo Manutenção',
                'Ativar modo de manutenção do sistema',
                Icons.construction,
                Colors.orange,
                () => _toggleMaintenanceMode(context),
              ),
              _buildActionTile(
                context,
                'Limpar Dados Antigos',
                'Remover registros com mais de 1 ano',
                Icons.delete_sweep,
                Colors.red,
                () => _cleanOldData(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildConfigSection(
            'Sobre',
            Icons.help_outline,
            Colors.grey,
            [
              _buildInfoTile('Desenvolvido por', 'Recicle Team'),
              _buildInfoTile('Contato', 'contato@recicle.com'),
              _buildInfoTile('Website', 'www.recicle.com'),
              _buildActionTile(
                context,
                'Documentação',
                'Acessar documentação do sistema',
                Icons.menu_book,
                Colors.blue,
                () => _openDocumentation(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamStatTile(String label, String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getCollectionStream(collection),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _buildInfoTile(label, count.toString());
      },
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return SwitchListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle),
          value: value,
          onChanged: (newValue) {
            setState(() => value = newValue);
            onChanged(newValue);
          },
          activeColor: Colors.green,
        );
      },
    );
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup, color: Colors.blue),
            SizedBox(width: 8),
            Text('Exportar Dados'),
          ],
        ),
        content: const Text('Esta ação irá exportar todos os dados do sistema em formato JSON. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportação iniciada! Você receberá um email com o arquivo.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cleaning_services, color: Colors.purple),
            SizedBox(width: 8),
            Text('Limpar Cache'),
          ],
        ),
        content: const Text('Esta ação irá remover todos os dados temporários. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache limpo com sucesso!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _showLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logs do Sistema'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: ListView(
            children: const [
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Sistema iniciado com sucesso'),
                subtitle: Text('12/09/2025 08:30:15'),
              ),
              ListTile(
                leading: Icon(Icons.person_add, color: Colors.blue),
                title: Text('Novo usuário cadastrado'),
                subtitle: Text('12/09/2025 10:45:22'),
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.orange),
                title: Text('Descarte registrado'),
                subtitle: Text('12/09/2025 14:20:30'),
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.orange),
                title: Text('Tentativa de login falhou'),
                subtitle: Text('12/09/2025 16:15:45'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _toggleMaintenanceMode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.construction, color: Colors.orange),
            SizedBox(width: 8),
            Text('Modo Manutenção'),
          ],
        ),
        content: const Text('Ativar o modo manutenção bloqueará o acesso de todos os usuários exceto administradores. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modo manutenção ativado'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
  }

  void _cleanOldData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_sweep, color: Colors.red),
            SizedBox(width: 8),
            Text('Limpar Dados Antigos'),
          ],
        ),
        content: const Text('Esta ação irá remover permanentemente todos os registros com mais de 1 ano. Esta operação não pode ser desfeita. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dados antigos removidos com sucesso!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _updateNotificationSetting(BuildContext context, String setting, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Notificação de $setting ativada' : 'Notificação de $setting desativada',
        ),
      ),
    );
  }

  void _openDocumentation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Documentação'),
        content: const Text('A documentação completa está disponível em:\nhttps://docs.recicle.com\n\nDeseja abrir no navegador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrindo documentação...')),
              );
            },
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }
}