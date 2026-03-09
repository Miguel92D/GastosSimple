import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> data;

  const ExpenseChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    final sections = data.entries.map((entry) {
      // Basic color palette for categories
      final List<Color> colors = [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.pink,
      ];
      final index = data.keys.toList().indexOf(entry.key);
      final color = colors[index % colors.length];

      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "Distribución de Gastos",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
      ],
    );
  }
}
