import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/admin_controller.dart';

class MaterialsChart extends StatelessWidget {
  final AdminController controller;

  const MaterialsChart({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Materiais Mais Descartados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: controller.getDisposalsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Text('Nenhum dado disponível');
                }

                final docs = snapshot.data!.docs;
                Map<String, int> materialCount = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final materials = data['materials'] as List<dynamic>? ?? [];

                  for (var material in materials) {
                    final materialName = material.toString();
                    materialCount[materialName] = (materialCount[materialName] ?? 0) + 1;
                  }
                }

                final sortedMaterials = materialCount.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                if (sortedMaterials.isEmpty) {
                  return const Text('Nenhum material descartado ainda');
                }

                return Column(
                  children: sortedMaterials.take(5).map((entry) {
                    final percentage = (entry.value / docs.length * 100);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: entry.value / (sortedMaterials.first.value),
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}