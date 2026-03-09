import 'package:flutter/material.dart';
import '../../../core/flow/transaction_flow_service.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../goals/models/goal.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? movimientoToEdit;
  final bool isFromQuickEntry;
  final String? initialTipo;
  final bool isVault;

  const AddTransactionScreen({
    super.key,
    this.movimientoToEdit,
    this.isFromQuickEntry = false,
    this.initialTipo,
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
    'Ocio',
    'Salud',
    'Educación',
    'Otros',
  ];

  List<String> _categoriasIngreso = [
    'Salario',
    'Venta',
    'Regalo',
    'Inversión',
    'Otros',
  ];

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
      if (widget.initialTipo != null) {
        _tipo = widget.initialTipo!;
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
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.income,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.expense,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSubmitted: (_) => _saveMovement(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _tipo == 'gasto' ? Colors.red : Colors.green,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  prefixText: CurrencyHelper.getSymbol(context),
                  border: InputBorder.none,
                  hintText: '0.00',
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.note,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveMovement,
                child: Text(AppLocalizations.of(context)!.save.toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
