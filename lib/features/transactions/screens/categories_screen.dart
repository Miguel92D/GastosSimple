import 'package:flutter/material.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/controllers/action_controller.dart';
import '../../../core/controllers/app_action.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Comida',
        'icon': Icons.restaurant_rounded,
        'color': AppColors.orange,
      },
      {
        'name': 'Transporte',
        'icon': Icons.directions_bus_rounded,
        'color': AppColors.blue,
      },
      {
        'name': 'Ocio',
        'icon': Icons.sports_esports_rounded,
        'color': AppColors.purple,
      },
      {
        'name': 'Salud',
        'icon': Icons.local_hospital_rounded,
        'color': AppColors.expenseRed,
      },
      {
        'name': 'Educación',
        'icon': Icons.school_rounded,
        'color': AppColors.indigo,
      },
      {
        'name': 'Salario',
        'icon': Icons.payments_rounded,
        'color': AppColors.incomeGreen,
      },
      {
        'name': 'Inversión',
        'icon': Icons.trending_up_rounded,
        'color': AppColors.teal,
      },
      {
        'name': 'Regalo',
        'icon': Icons.card_giftcard_rounded,
        'color': AppColors.pink,
      },
    ];

    return AppScaffold(
      title: "Categorías",
      drawer: const AppDrawer(),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final color = cat['color'] as Color;

          return GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 30,
            glowColor: color.withOpacity(0.05),
            child: InkWell(
              onTap: () => ActionController.execute(
                context,
                AppAction.addExpense,
                arguments: {'category': cat['name']},
              ),
              borderRadius: BorderRadius.circular(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(cat['icon'], color: color, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cat['name'],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.softText.withOpacity(0.15),
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
