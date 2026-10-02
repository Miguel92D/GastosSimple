import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
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
        // Colores de categoría (no se usan verde/rojo: son de ingreso/gasto)
        AppColors.blue,
        AppColors.pink,
        AppColors.teal,
        AppColors.amber,
        AppColors.orange,
        AppColors.purple,
        AppColors.indigo,
        AppColors.sky,
      ];
      final index = data.keys.toList().indexOf(entry.key);
      final color = colors[index % colors.length];

      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        color: color,
        radius: 60,
        titleStyle: AppTextStyles.subtitle.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.darkBackground,
        ),
      );
    }).toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "Distribución de Gastos",
            style: AppTextStyles.cardTitle,
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
