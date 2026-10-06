import 'package:flutter/material.dart';

import '../../core/ui/app_colors.dart';
import '../../core/ui/app_icons.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_text_styles.dart';
import '../../core/ui/category_icons.dart';
import '../../core/ui/glass_card.dart';
import '../../core/ui/layout/app_scaffold.dart';
import '../../core/ui/widgets/app_action_button.dart';
import '../../core/ui/widgets/app_amount.dart';
import '../../core/ui/widgets/app_empty_state.dart';
import '../../core/ui/widgets/app_icon_box.dart';
import '../../core/ui/widgets/app_list_row.dart';
import '../../core/ui/widgets/app_logo.dart';
import '../../core/ui/widgets/app_pill.dart';
import '../../core/ui/widgets/app_progress_bar.dart';
import '../../core/ui/widgets/app_round_button.dart';
import '../../core/ui/widgets/app_secondary_button.dart';
import '../../core/ui/widgets/app_section_title.dart';
import '../../core/ui/widgets/app_segmented.dart';
import '../../core/ui/widgets/app_sheet.dart';
import '../../core/ui/widgets/glass_input.dart';
import '../../core/ui/widgets/gradient_button.dart';
import '../../core/ui/widgets/pro_badge.dart';
import '../../core/ui/widgets/pro_benefit_list.dart';

/// Catálogo visual (chat 08, paso 7): todos los módulos de `lib/core/ui`
/// en una sola pantalla, para ver un cambio de diseño de un vistazo.
/// Solo se abre en modo desarrollo (Ajustes → DEV); no está en el router.
class DesignCatalogScreen extends StatefulWidget {
  const DesignCatalogScreen({super.key});

  @override
  State<DesignCatalogScreen> createState() => _DesignCatalogScreenState();
}

class _DesignCatalogScreenState extends State<DesignCatalogScreen> {
  String _period = 'day';
  String _type = 'gasto';
  bool _switch = true;
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Catálogo',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxl * 2,
        ),
        children: [
          const AppSectionTitle('Logo y Pro', spaceAbove: false),
          const Row(
            children: [
              AppLogo(),
              SizedBox(width: AppSpacing.md),
              ProBadge(),
            ],
          ),

          const AppSectionTitle('Botones'),
          GradientButton(text: 'Botón principal', onPressed: () {}),
          const SizedBox(height: AppSpacing.sm),
          AppSecondaryButton(
            text: 'Botón secundario',
            icon: AppIcons.importFile,
            expand: true,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AppRoundButton(
                icon: AppIcons.add,
                color: AppColors.incomeGreen,
                onTap: () {},
              ),
              const SizedBox(width: AppSpacing.md),
              AppRoundButton(icon: AppIcons.menu, onTap: () {}),
              const SizedBox(width: AppSpacing.md),
              AppActionButton(
                icon: AppIcons.pay,
                color: AppColors.incomeGreen,
                onTap: () {},
              ),
              const SizedBox(width: AppSpacing.sm),
              AppActionButton(
                icon: AppIcons.edit,
                color: AppColors.primaryPurple,
                onTap: () {},
              ),
              const SizedBox(width: AppSpacing.sm),
              AppActionButton(
                icon: AppIcons.delete,
                color: AppColors.expenseRed,
                onTap: () {},
              ),
            ],
          ),

          const AppSectionTitle('Selector y pills'),
          AppSegmented<String>(
            expand: true,
            selected: _period,
            onChanged: (v) => setState(() => _period = v),
            segments: const [
              AppSegment(value: 'day', label: 'Día', icon: AppIcons.day),
              AppSegment(value: 'month', label: 'Mes', icon: AppIcons.month),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: AppSegmented<String>(
              selected: _type,
              onChanged: (v) => setState(() => _type = v),
              segments: const [
                AppSegment(
                  value: 'ingreso',
                  label: 'Ingreso',
                  color: AppColors.incomeGreen,
                ),
                AppSegment(
                  value: 'gasto',
                  label: 'Gasto',
                  color: AppColors.expenseRed,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const AppPill(label: 'Informativa'),
              AppPill(label: 'Elegida', selected: true, onTap: () {}),
              AppPill(label: 'Sin elegir', selected: false, onTap: () {}),
            ],
          ),

          const AppSectionTitle('Filas y montos'),
          AppListRow(
            icon: CategoryIcons.of('cat_food'),
            iconColor: AppColors.expenseRed,
            title: 'Comida',
            subtitle: '5 oct, 2026',
            trailing: const AppAmount.list(
              value: 3500,
              prefix: '-',
              color: AppColors.expenseRed,
              hidden: false,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppListRow(
            icon: AppIcons.recurring,
            iconColor: AppColors.incomeGreen,
            title: 'Monto gigante',
            subtitle: 'La fila mide lo mismo',
            trailing: const AppAmount.list(
              value: 609099096909.60,
              prefix: '+',
              color: AppColors.incomeGreen,
              hidden: false,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                AppListRow.setting(
                  icon: AppIcons.language,
                  title: 'Fila de Ajustes',
                  subtitle: 'Con flecha',
                  onTap: () {},
                ),
                AppListRow.setting(
                  icon: AppIcons.reminder,
                  title: 'Con interruptor',
                  trailing: Switch(
                    value: _switch,
                    onChanged: (v) => setState(() => _switch = v),
                  ),
                  onTap: () => setState(() => _switch = !_switch),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              AppIconBox(icon: AppIcons.debts, color: AppColors.textPrimary),
              SizedBox(width: AppSpacing.sm),
              AppIconBox(icon: AppIcons.goals, color: AppColors.primaryPurple),
            ],
          ),

          const AppSectionTitle('Barra de progreso'),
          const AppProgressBar(value: 0.6),
          const SizedBox(height: AppSpacing.sm),
          const AppProgressBar(value: 0.3, color: AppColors.orange),

          const AppSectionTitle('Campo de texto'),
          GlassInput(controller: _input, label: 'Nombre', icon: AppIcons.name),

          const AppSectionTitle('Panel y diálogo'),
          AppSecondaryButton(
            text: 'Abrir panel',
            expand: true,
            onPressed: () => AppSheet.show<void>(
              context,
              horizontalPadding: 0,
              builder: (ctx) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppSheetTitle('Título del panel'),
                  AppSheetOption(
                    icon: AppIcons.edit,
                    label: 'Editar',
                    onTap: () => Navigator.pop(ctx),
                  ),
                  AppSheetOption(
                    icon: AppIcons.delete,
                    color: AppColors.expenseRed,
                    label: 'Borrar',
                    onTap: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSecondaryButton(
            text: 'Abrir diálogo',
            expand: true,
            onPressed: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Título del diálogo'),
                content: const Text('Texto del diálogo.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.expenseRed,
                    ),
                    child: const Text('Borrar'),
                  ),
                ],
              ),
            ),
          ),

          const AppSectionTitle('Beneficios Pro'),
          const ProBenefitList(),

          const AppSectionTitle('Estado vacío'),
          AppEmptyState(
            icon: AppIcons.debts,
            text: 'Sin deudas',
            subtitle: 'Texto chico opcional',
            actionText: 'Botón opcional',
            onAction: () {},
          ),

          const AppSectionTitle('Letras'),
          Text('screenTitle 24', style: AppTextStyles.screenTitle),
          Text('titleMain 20', style: AppTextStyles.titleMain),
          Text('titleSmall 18', style: AppTextStyles.titleSmall),
          Text('cardTitle 16', style: AppTextStyles.cardTitle),
          Text('amountList 15', style: AppTextStyles.amountList),
          Text('rowTitle 14', style: AppTextStyles.rowTitle),
          Text('bodyMain 14', style: AppTextStyles.bodyMain),
          Text('SUBLABEL 12', style: AppTextStyles.subLabel),
          Text('LABELSMALL 11', style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
