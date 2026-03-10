/**
 * This project uses a centralized design system.
 * Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
 * All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
 */
import 'package:flutter/material.dart';
import '../../../core/flow/transaction_flow_service.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_gradients.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../goals/models/goal.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction.dart';
import '../../../core/ui/widgets/glass_input.dart';
import '../../../core/ui/widgets/gradient_button.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? movimientoToEdit;
  final bool isFromQuickEntry;
  final String? type; // "income" or "expense"
  final bool isVault;

  const AddTransactionScreen({
    super.key,
    this.movimientoToEdit,
    this.isFromQuickEntry = false,
    this.type,
    this.isVault = false,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _noteController = TextEditingController();
  final _goalAmountController = TextEditingController();

  String _tipo = 'gasto';
  String _selectedCategory = 'Comida';
  final bool _isRecurring = false;
  final String _frequency = 'monthly';

  Goal? _selectedGoal;

  List<String> _categoriasGasto = [
    'Comida',
    'Transporte',
    'Salud',
    'Ocio',
    'Compras',
    'Suscripciones',
    'Servicios',
    'Tarjeta de Crédito',
    'Préstamos',
    'Regalos',
    'Otros',
  ];

  List<String> _categoriasIngreso = [
    'Salario',
    'Inversiones',
    'Ventas',
    'Regalos',
    'Préstamos',
    'Bonos',
    'Otros',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Comida': Icons.restaurant_rounded,
    'Transporte': Icons.directions_bus_rounded,
    'Salud': Icons.local_hospital_rounded,
    'Ocio': Icons.sports_esports_rounded,
    'Compras': Icons.shopping_bag_rounded,
    'Suscripciones': Icons.subscriptions_rounded,
    'Servicios': Icons.receipt_long_rounded,
    'Tarjeta de Crédito': Icons.credit_card_rounded,
    'Préstamos': Icons.handshake_rounded,
    'Regalos': Icons.card_giftcard_rounded,
    'Otros': Icons.more_horiz_rounded,
    'Salario': Icons.payments_rounded,
    'Inversiones': Icons.trending_up_rounded,
    'Ventas': Icons.sell_rounded,
    'Bonos': Icons.redeem_rounded,
  };

  @override
  void initState() {
    super.initState();
    _loadSmartCategories();

    if (widget.movimientoToEdit != null) {
      final mov = widget.movimientoToEdit!;

      _amountController.text = mov.amount.toString();
      _tipo = mov.type;
      _selectedCategory = mov.category;
      _noteController.text = mov.note ?? '';
    } else {
      if (widget.type != null) {
        final String normalizedType = widget.type!.toLowerCase();
        if (normalizedType == 'income' || normalizedType == 'ingreso') {
          _tipo = 'ingreso';
        } else {
          _tipo = 'gasto';
        }

        _selectedCategory = _tipo == 'gasto'
            ? _categoriasGasto.first
            : _categoriasIngreso.first;
      }

      Future.delayed(Duration.zero, () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_amountFocusNode);
        }
      });
    }
  }

  Future<void> _loadSmartCategories() async {
    final sortedGasto = await TransactionController.getCategoriasOrdenadas(
      'gasto',
    );
    final sortedIngreso = await TransactionController.getCategoriasOrdenadas(
      'ingreso',
    );

    if (mounted) {
      setState(() {
        if (sortedGasto.isNotEmpty) {
          final uniqueCategorias = sortedGasto.toSet().toList();

          uniqueCategorias.addAll(
            _categoriasGasto.where((c) => !uniqueCategorias.contains(c)),
          );

          _categoriasGasto = uniqueCategorias;
        }

        if (sortedIngreso.isNotEmpty) {
          final uniqueCategorias = sortedIngreso.toSet().toList();

          uniqueCategorias.addAll(
            _categoriasIngreso.where((c) => !uniqueCategorias.contains(c)),
          );

          _categoriasIngreso = uniqueCategorias;
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _noteController.dispose();
    _goalAmountController.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  void _saveMovement() async {
    if (_isSaving) return;

    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.amount_error)),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newMovement = Transaction(
        id: widget.movimientoToEdit?.id,
        amount: amount,
        category: _selectedCategory,
        type: _tipo,
        date: widget.movimientoToEdit?.date ?? DateTime.now(),
        isSecret: widget.isVault ? 1 : 0,
        isRecurring: _isRecurring,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        goalId: _selectedGoal?.id,
        goalAmount: double.tryParse(_goalAmountController.text),
      );

      await TransactionFlowService.instance.saveTransaction(
        context,
        newMovement,
        isRecurring: _isRecurring,
        frequency: _frequency,
        goal: _selectedGoal,
        goalAmount: double.tryParse(_goalAmountController.text) ?? 0,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movimientoToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? AppLocalizations.of(context)!.edit_movement
              : AppLocalizations.of(context)!.new_movement,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.type == null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.glassSurface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToggleOption(
                          label: AppLocalizations.of(context)!.income,
                          isSelected: _tipo == 'ingreso',
                          color: AppColors.incomeGreen,
                          onTap: () => setState(() {
                            _tipo = 'ingreso';
                            _selectedCategory = _categoriasIngreso.first;
                          }),
                        ),
                        const SizedBox(width: 4),
                        _ToggleOption(
                          label: AppLocalizations.of(context)!.expense,
                          isSelected: _tipo == 'gasto',
                          color: AppColors.expenseRed,
                          onTap: () => setState(() {
                            _tipo = 'gasto';
                            _selectedCategory = _categoriasGasto.first;
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.md),

              GlassInput(
                controller: _amountController,
                focusNode: _amountFocusNode,
                isCenter: true,
                height: 85,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSubmitted: _saveMovement,
                label: '',
                style: AppTextStyles.balanceAmount.copyWith(
                  fontSize: 42,
                  color: _tipo == 'gasto'
                      ? AppColors.expenseRed
                      : AppColors.incomeGreen,
                ),
                hintText: 'Monto',
                hintStyle: AppTextStyles.balanceAmount.copyWith(
                  fontSize: 32,
                  color: AppColors.softText.withOpacity(0.1),
                ),
                prefix: Baseline(
                  baseline: 30,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    CurrencyHelper.getSymbol(context),
                    style: AppTextStyles.bodyMain.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          (_tipo == 'gasto'
                                  ? AppColors.expenseRed
                                  : AppColors.incomeGreen)
                              .withOpacity(0.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text('CATEGORÍA', style: AppTextStyles.subLabel),

              const SizedBox(height: AppSpacing.md),

              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tipo == 'gasto'
                      ? _categoriasGasto.length
                      : _categoriasIngreso.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final category = _tipo == 'gasto'
                        ? _categoriasGasto[index]
                        : _categoriasIngreso[index];
                    final isSelected = _selectedCategory == category;
                    final icon =
                        _categoryIcons[category] ?? Icons.category_rounded;
                    final color = _tipo == 'gasto'
                        ? AppColors.expenseRed
                        : AppColors.incomeGreen;

                    return ChoiceChip(
                      label: Row(
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: isSelected ? AppColors.textPrimary : color,
                          ),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: color,
                      backgroundColor: color.withOpacity(0.08),
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.softText,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.cardBorder
                              : color.withOpacity(0.15),
                        ),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              GlassInput(
                controller: _noteController,
                label: AppLocalizations.of(context)!.note.toUpperCase(),
                icon: Icons.note_rounded,
                hintText: 'Ej: Cena con amigos...',
              ),

              const SizedBox(height: AppSpacing.xxl),

              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: AppLocalizations.of(context)!.save.toUpperCase(),
                  onPressed: _saveMovement,
                  borderRadius: AppRadius.lg,
                  gradientColors: AppGradients.primaryGradient.colors,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.softText,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
