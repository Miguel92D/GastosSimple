import 'package:flutter/material.dart';
import '../../../core/ui/widgets/glass_card.dart';
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
      appBar: AppBar(title: const Text("Categorías")),
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
            padding: const EdgeInsets.all(16),
            borderRadius: 28,
            glowColor: color.withOpacity(0.05),
            child: InkWell(
              onTap: () => ActionController.execute(
                context,
                AppAction.addExpense,
                arguments: {'category': cat['name']},
              ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.white.withOpacity(0.2),
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
