import 'package:flutter/material.dart';
import '../../../core/ui/glass_card.dart';
import '../../../core/ui/design/app_colors.dart';
import '../../../core/controllers/action_controller.dart';
import '../../../core/controllers/app_action.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Comida',
        'icon': Icons.restaurant_rounded,
        'color': Colors.orange,
      },
      {
        'name': 'Transporte',
        'icon': Icons.directions_bus_rounded,
        'color': Colors.blue,
      },
      {
        'name': 'Ocio',
        'icon': Icons.sports_esports_rounded,
        'color': Colors.purple,
      },
      {
        'name': 'Salud',
        'icon': Icons.local_hospital_rounded,
        'color': Colors.red,
      },
      {
        'name': 'Educación',
        'icon': Icons.school_rounded,
        'color': Colors.indigo,
      },
      {
        'name': 'Salario',
        'icon': Icons.payments_rounded,
        'color': Colors.green,
      },
      {
        'name': 'Inversión',
        'icon': Icons.trending_up_rounded,
        'color': Colors.teal,
      },
      {
        'name': 'Regalo',
        'icon': Icons.card_giftcard_rounded,
        'color': Colors.pink,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Categorías"), elevation: 0),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              borderRadius: 20,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cat['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cat['color'].withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(cat['icon'], color: cat['color'], size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    cat['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.primaryStart,
                    ),
                    onPressed: () {
                      ActionController.execute(
                        context,
                        AppAction.addExpense,
                        arguments: {'category': cat['name']},
                      );
                    },
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
