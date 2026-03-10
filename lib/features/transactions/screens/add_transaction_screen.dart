import 'package:flutter/material.dart';
import '../../../core/flow/transaction_flow_service.dart';
import '../../../core/ui/design/app_colors.dart';
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

      // Call centralized flow service - Navigation is handled inside the service
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
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.type == null)
                Center(
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(12),
                    isSelected: [_tipo == 'ingreso', _tipo == 'gasto'],
                    onPressed: (index) {
                      setState(() {
                        _tipo = index == 0 ? 'ingreso' : 'gasto';

                        _selectedCategory = _tipo == 'gasto'
                            ? _categoriasGasto.first
                            : _categoriasIngreso.first;
                      });
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_upward, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.income,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_downward, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.expense,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              const SizedBox(height: 24),

              GlassInput(
                controller: _amountController,
                focusNode: _amountFocusNode,
                isCenter: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSubmitted: _saveMovement,
                label: '',
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: _tipo == 'gasto'
                      ? AppColors.expense
                      : AppColors.income,
                  letterSpacing: -1,
                ),
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    CurrencyHelper.getSymbol(context),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          (_tipo == 'gasto'
                                  ? AppColors.expense
                                  : AppColors.income)
                              .withOpacity(0.5),
                    ),
                  ),
                ),
                hintText: '0.00',
              ),

              const SizedBox(height: 24),

              Text(
                'CATEGORÍA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tipo == 'gasto'
                      ? _categoriasGasto.length
                      : _categoriasIngreso.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = _tipo == 'gasto'
                        ? _categoriasGasto[index]
                        : _categoriasIngreso[index];
                    final isSelected = _selectedCategory == category;
                    final icon =
                        _categoryIcons[category] ?? Icons.category_rounded;
                    final color = _tipo == 'gasto'
                        ? AppColors.expense
                        : AppColors.income;

                    return ChoiceChip(
                      label: Row(
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: isSelected ? Colors.white : color,
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
                      backgroundColor: color.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.white24
                              : color.withOpacity(0.3),
                        ),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              GlassInput(
                controller: _noteController,
                label: AppLocalizations.of(context)!.note.toUpperCase(),
                icon: Icons.note_rounded,
                hintText: 'Ej: Cena con amigos...',
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: AppLocalizations.of(context)!.save.toUpperCase(),
                  onPressed: _saveMovement,
                  borderRadius: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
