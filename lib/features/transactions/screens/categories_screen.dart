import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
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
    final l10n = context.watch<AppLocaleController>();
    
    final List<Map<String, dynamic>> categories = [
      {
        'name': l10n.text('cat_food'),
        'id': 'cat_food',
        'icon': Icons.restaurant_rounded,
        'color': AppColors.orange,
      },
      {
        'name': l10n.text('cat_transport'),
        'id': 'cat_transport',
        'icon': Icons.directions_bus_rounded,
        'color': AppColors.blue,
      },
      {
        'name': l10n.text('cat_leisure'),
        'id': 'cat_leisure',
        'icon': Icons.sports_esports_rounded,
        'color': AppColors.purple,
      },
      {
        'name': l10n.text('cat_health'),
        'id': 'cat_health',
        'icon': Icons.local_hospital_rounded,
        'color': AppColors.expenseRed,
      },
      {
        'name': l10n.text('cat_education'),
        'id': 'cat_education',
        'icon': Icons.school_rounded,
        'color': AppColors.indigo,
      },
      {
        'name': l10n.text('cat_salary'),
        'id': 'cat_salary',
        'icon': Icons.payments_rounded,
        'color': AppColors.incomeGreen,
      },
      {
        'name': l10n.text('cat_investment'),
        'id': 'cat_investment',
        'icon': Icons.trending_up_rounded,
        'color': AppColors.teal,
      },
      {
        'name': l10n.text('cat_gift'),
        'id': 'cat_gift',
        'icon': Icons.card_giftcard_rounded,
        'color': AppColors.pink,
      },
    ];

    return AppScaffold(
      title: l10n.text('categories'),
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
                arguments: {'category': cat['id']}, // Enviamos la llave ID para guardar en DB de forma neutra
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
