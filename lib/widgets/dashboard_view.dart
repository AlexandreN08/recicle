import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recicle/widgets/materials_chart.dart';
import 'package:recicle/widgets/recent_disposals.dart';
import 'package:recicle/widgets/stat_card.dart';
import '../controllers/admin_controller.dart';


class DashboardView extends StatelessWidget {
  final AdminController controller;

  const DashboardView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard - Gestão de Descartes',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildStatsCards(),
          const SizedBox(height: 30),
          MaterialsChart(controller: controller),
          const SizedBox(height: 30),
          RecentDisposals(controller: controller),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getDisposalsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Text('Nenhum dado disponível');
        }

        final docs = snapshot.data!.docs;
        final totalDescartes = docs.length;

        Map<String, int> materialCount = {};
        int totalMateriais = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final materials = data['materials'] as List<dynamic>? ?? [];
          totalMateriais += materials.length;

          for (var material in materials) {
            final materialName = material.toString();
            materialCount[materialName] = (materialCount[materialName] ?? 0) + 1;
          }
        }

        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total de Descartes',
                value: totalDescartes.toString(),
                icon: Icons.recycling,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Total de Materiais',
                value: totalMateriais.toString(),
                icon: Icons.inventory,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Tipos de Material',
                value: materialCount.keys.length.toString(),
                icon: Icons.category,
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }
}