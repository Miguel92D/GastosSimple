import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
/**
 * This project uses a centralized design system.
 * Direct usage of Color(), LinearGradient(), TextStyle(), BorderRadius.circular(), or hardcoded spacing values is not allowed.
 * All UI styling must use AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadius, AppShadows, and GlassCard.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/flow/transaction_flow_service.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/category_icons.dart';
import '../../../core/ui/widgets/app_pill.dart';
import '../../../core/ui/app_gradients.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../../core/utils/installment_plan.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/card_schedule.dart';
import '../../../services/credit_card_service.dart';

import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/app_drawer.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction.dart';
import '../../../core/ui/widgets/glass_input.dart';
import '../../../core/ui/widgets/gradient_button.dart';
import '../../../core/utils/l10n_helper.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';
import 'package:gastos_simple/core/ui/widgets/app_section_title.dart';
import 'package:gastos_simple/core/ui/widgets/app_segmented.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? movimientoToEdit;
  final bool isFromQuickEntry;
  final String? type; // "income" or "expense"
  final bool isVault;
  final String? initialCategory;

  const AddTransactionScreen({
    super.key,
    this.movimientoToEdit,
    this.isFromQuickEntry = false,
    this.type,
    this.isVault = false,
    this.initialCategory,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _noteController = TextEditingController();

  String _tipo = 'gasto';
  String _selectedCategory = 'Comida';
  bool _isRecurring = false;
  String _frequency = 'monthly';

  /// Compra en cuotas (solo gastos nuevos). null = un solo pago.
  int? _installments;

  /// true: el monto ingresado es el valor de UNA cuota (compras con
  /// recargo/interés); false: es el total de la compra.
  bool _amountIsPerInstallment = false;
  List<CreditCard> _cards = [];
  String? _cardId;

  /// Día del movimiento (la hora se resuelve al guardar, ver [_resolveDate]).
  DateTime _selectedDate = DateTime.now();

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

  @override
  void initState() {
    super.initState();
    // Actualiza la vista previa "6 cuotas de $X" mientras se escribe.
    _amountController.addListener(() {
      if (_installments != null && mounted) setState(() {});
    });
    _loadSmartCategories();
    _loadCards();

    if (widget.movimientoToEdit != null) {
      final mov = widget.movimientoToEdit!;

      _amountController.text = CurrencyHelper.formatAmountForInput(mov.amount);
      _tipo = mov.type;
      _selectedCategory = mov.category;
      _noteController.text = mov.note ?? '';
      _selectedDate = mov.date;
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

      if (widget.initialCategory != null &&
          widget.initialCategory!.isNotEmpty) {
        _selectedCategory = widget.initialCategory!;
        final categorias = _tipo == 'gasto'
            ? _categoriasGasto
            : _categoriasIngreso;
        if (!categorias.contains(_selectedCategory)) {
          categorias.insert(0, _selectedCategory);
        }
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

        // La categoría seleccionada (p. ej. al venir desde Categorías o al
        // editar un movimiento antiguo) debe seguir visible en el carrusel.
        final categorias = _tipo == 'gasto'
            ? _categoriasGasto
            : _categoriasIngreso;
        if (!categorias.contains(_selectedCategory)) {
          categorias.insert(0, _selectedCategory);
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  void _saveMovement() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();

    final amount = CurrencyHelper.parseAmount(_amountController.text);

    // En centavos: "0,001" no es un monto válido (D-005).
    if (amount == null || Money.toCents(amount) <= 0) {
      if (mounted) {
        final l10n = context.read<AppLocaleController>();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.text('amount_error'))));
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final original = widget.movimientoToEdit;
      final newMovement = Transaction(
        id: original?.id,
        // En cuotas con "valor de cuota", el movimiento lleva el total.
        amount: _isInstallmentPurchase ? _installmentsTotal(amount) : amount,
        category: _selectedCategory,
        type: _tipo,
        date: _resolveDate(),
        // Al editar se preserva el flag original: un movimiento de la Bóveda
        // nunca debe filtrarse al historial normal (Especificación §7.7).
        isSecret: original?.isSecret ?? (widget.isVault ? 1 : 0),
        // Al editar tampoco se pierde la marca de "generado por un pago
        // fijo" ni el vínculo con una meta (esta pantalla no los muestra).
        isRecurring: original?.isRecurring ?? _isRecurring,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        goalId: original?.goalId,
        goalAmount: original?.goalAmount,
      );

      await TransactionFlowService.instance.saveTransaction(
        context,
        newMovement,
        isRecurring: _isRecurring,
        frequency: _frequency,
        isFromQuickEntry: widget.isFromQuickEntry,
        installments: _isInstallmentPurchase ? _installments : null,
        installmentsFirstDate: _isInstallmentPurchase
            ? _installmentsFirstDate()
            : null,
        installmentsAnchorDay: _isInstallmentPurchase
            ? _selectedCard?.dueDay
            : null,
      );
      // saveTransaction atrapa sus propios errores (muestra un SnackBar) y no
      // relanza: sin esto, tras un error el botón Guardar quedaba bloqueado.
      if (mounted) setState(() => _isSaving = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Fecha y hora final del movimiento:
  /// - Editando sin cambiar el día: se conserva la fecha/hora original.
  /// - Hoy (nuevo): el momento actual.
  /// - Otro día: ese día con la hora actual, para que el orden dentro del
  ///   día sea natural y nunca quede en el futuro.
  DateTime _resolveDate() {
    final original = widget.movimientoToEdit?.date;
    if (original != null && _isSameDay(original, _selectedDate)) {
      return original;
    }
    final now = DateTime.now();
    if (_isSameDay(_selectedDate, now)) return now;
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );
  }

  void _setDate(DateTime day) {
    HapticFeedback.selectionClick();
    setState(() => _selectedDate = day);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(now) ? now : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null && mounted) _setDate(picked);
  }

  Widget _buildDateSelector(AppLocaleController l10n) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final isToday = _isSameDay(_selectedDate, now);
    final isYesterday = _isSameDay(_selectedDate, yesterday);
    final isOther = !isToday && !isYesterday;
    final color = _tipo == 'gasto'
        ? AppColors.expenseRed
        : AppColors.incomeGreen;

    return Row(
      children: [
        Expanded(
          child: _DateChip(
            label: l10n.text('today'),
            isSelected: isToday,
            color: color,
            onTap: () => _setDate(now),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DateChip(
            label: l10n.text('yesterday'),
            isSelected: isYesterday,
            color: color,
            onTap: () => _setDate(yesterday),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DateChip(
            label: isOther
                ? DateFormat('d MMM', l10n.locale).format(_selectedDate)
                : l10n.text('other_date'),
            icon: AppIcons.pickDate,
            isSelected: isOther,
            color: color,
            onTap: _pickDate,
          ),
        ),
      ],
    );
  }

  // ---- Cuotas: modo de monto, tarjeta y fecha de la primera cuota ----

  bool get _isInstallmentPurchase => _tipo == 'gasto' && _installments != null;

  CreditCard? get _selectedCard {
    for (final c in _cards) {
      if (c.id == _cardId) return c;
    }
    return null;
  }

  /// Total a pagar del plan (si se ingresó el valor de la cuota, cuota × n).
  double _installmentsTotal(double entered) => _amountIsPerInstallment
      ? Money.fromCents(Money.toCents(entered) * (_installments ?? 1))
      : entered;

  double _installmentsPer(double entered) => _amountIsPerInstallment
      ? entered
      : InstallmentPlan.perInstallment(entered, _installments ?? 1);

  DateTime _installmentsFirstDate() {
    final purchase = _resolveDate();
    final card = _selectedCard;
    return card == null ? purchase : CardSchedule.firstDueDate(purchase, card);
  }

  Future<void> _loadCards() async {
    final cards = await CreditCardService.getCards();
    final lastId = await CreditCardService.getLastUsedId();
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _cardId = cards.any((c) => c.id == lastId) ? lastId : null;
    });
  }

  void _selectCard(String? id) {
    HapticFeedback.selectionClick();
    setState(() => _cardId = id);
    CreditCardService.setLastUsedId(id);
  }

  Future<void> _addCard(AppLocaleController l10n) async {
    final name = TextEditingController();
    final closing = TextEditingController();
    final due = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.text('card_add_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.text('card_name')),
            ),
            TextField(
              controller: closing,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.text('card_closing_day'),
                hintText: '1 - 31',
              ),
            ),
            TextField(
              controller: due,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.text('card_due_day'),
                hintText: '1 - 31',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.text('cancel')),
          ),
          TextButton(
            onPressed: () {
              final c = int.tryParse(closing.text);
              final d = int.tryParse(due.text);
              final valid =
                  name.text.trim().isNotEmpty &&
                  c != null &&
                  c >= 1 &&
                  c <= 31 &&
                  d != null &&
                  d >= 1 &&
                  d <= 31;
              if (valid) Navigator.pop(ctx, true);
            },
            child: Text(l10n.text('save')),
          ),
        ],
      ),
    );
    if (result == true) {
      final card = await CreditCardService.addCard(
        name: name.text.trim(),
        closingDay: int.parse(closing.text),
        dueDay: int.parse(due.text),
      );
      await CreditCardService.setLastUsedId(card.id);
      await _loadCards();
    }
    Future.delayed(const Duration(milliseconds: 400), () {
      name.dispose();
      closing.dispose();
      due.dispose();
    });
  }

  Future<void> _confirmDeleteCard(
    AppLocaleController l10n,
    CreditCard card,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.text('card_delete_title', {'name': card.name})),
        content: Text(l10n.text('card_delete_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.text('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            child: Text(l10n.text('delete')),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CreditCardService.deleteCard(card.id);
      if (_cardId == card.id) await CreditCardService.setLastUsedId(null);
      await _loadCards();
    }
  }

  Future<void> _pickCustomInstallments(AppLocaleController l10n) async {
    final controller = TextEditingController();
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.text('installments_custom_title')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '2 - ${InstallmentPlan.maxInstallments}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.text('cancel')),
          ),
          TextButton(
            onPressed: () {
              final n = int.tryParse(controller.text);
              if (n != null && n >= 2 && n <= InstallmentPlan.maxInstallments) {
                Navigator.pop(ctx, n);
              }
            },
            child: Text(l10n.text('save')),
          ),
        ],
      ),
    );
    // Se libera después de la animación de cierre del diálogo: liberarlo
    // en seguida hace que el TextField saliente use un controller muerto.
    Future.delayed(const Duration(milliseconds: 400), controller.dispose);
    if (value != null && mounted) {
      HapticFeedback.selectionClick();
      setState(() => _installments = value);
    }
  }

  Widget _sectionLabel(String text) => AppSectionTitle(text);

  Widget _buildInstallmentsSelector(AppLocaleController l10n) {
    const color = AppColors.expenseRed;
    final entered = CurrencyHelper.parseAmount(_amountController.text) ?? 0;
    final n = _installments;
    final isCustom = n != null && !InstallmentPlan.presets.contains(n);

    String? preview;
    if (n != null && Money.toCents(entered) > 0) {
      preview = l10n.text('installments_preview_full', {
        'n': n.toString(),
        'amount': CurrencyHelper.format(_installmentsPer(entered), context),
        'total': CurrencyHelper.format(_installmentsTotal(entered), context),
        'first': DateFormat(
          'd MMM',
          l10n.locale,
        ).format(_installmentsFirstDate()),
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: n != null,
          secondary: const Icon(AppIcons.installments, color: color),
          title: Text(
            l10n.text('installments_toggle').toUpperCase(),
            style: AppTextStyles.subLabel,
          ),
          subtitle: preview != null
              ? Text(preview, style: AppTextStyles.bodySmall)
              : null,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            setState(() => _installments = value ? 3 : null);
          },
        ),
        if (n != null) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in InstallmentPlan.presets)
                SizedBox(
                  width: 58,
                  child: _DateChip(
                    label: '$p',
                    isSelected: n == p,
                    color: color,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _installments = p);
                    },
                  ),
                ),
              SizedBox(
                width: 82,
                child: _DateChip(
                  label: isCustom ? '$n' : l10n.text('other_date'),
                  icon: AppIcons.edit,
                  isSelected: isCustom,
                  color: color,
                  onTap: () => _pickCustomInstallments(l10n),
                ),
              ),
            ],
          ),

          // Recargo / interés: si se conoce el valor de la cuota, se carga
          // ese valor y el total sale de cuota × n.
          _sectionLabel(l10n.text('installments_amount_is')),
          Row(
            children: [
              Expanded(
                child: _DateChip(
                  label: l10n.text('installments_mode_total'),
                  isSelected: !_amountIsPerInstallment,
                  color: color,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _amountIsPerInstallment = false);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DateChip(
                  label: l10n.text('installments_mode_per'),
                  isSelected: _amountIsPerInstallment,
                  color: color,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _amountIsPerInstallment = true);
                  },
                ),
              ),
            ],
          ),

          // Tarjeta: define en qué vencimiento cae la primera cuota.
          _sectionLabel(l10n.text('installments_first_on')),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _CardChip(
                label: l10n.text('installments_on_purchase_date'),
                isSelected: _cardId == null,
                onTap: () => _selectCard(null),
              ),
              for (final card in _cards)
                _CardChip(
                  label: card.name,
                  icon: AppIcons.installments,
                  isSelected: _cardId == card.id,
                  onTap: () => _selectCard(card.id),
                  onLongPress: () => _confirmDeleteCard(l10n, card),
                ),
              _CardChip(
                label: l10n.text('card_add'),
                icon: AppIcons.add,
                isSelected: false,
                onTap: () => _addCard(l10n),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _selectedCard == null
                ? l10n.text('installments_purchase_hint')
                : l10n.text('installments_card_hint', {
                    'closing': _selectedCard!.closingDay.toString(),
                    'due': _selectedCard!.dueDay.toString(),
                  }),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.softText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecurringSelector(AppLocaleController l10n) {
    final color = _tipo == 'gasto'
        ? AppColors.expenseRed
        : AppColors.incomeGreen;
    const frequencies = ['monthly', 'weekly', 'daily'];
    final labels = {
      'monthly': l10n.text('freq_monthly'),
      'weekly': l10n.text('freq_weekly'),
      'daily': l10n.text('freq_daily'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isRecurring,
          secondary: Icon(AppIcons.recurring, color: color),
          title: Text(
            l10n.text('recurring_repeat').toUpperCase(),
            style: AppTextStyles.subLabel,
          ),
          subtitle: _isRecurring
              ? Text(
                  l10n.text('recurring_repeat_hint'),
                  style: AppTextStyles.bodySmall,
                )
              : null,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            setState(() => _isRecurring = value);
          },
        ),
        if (_isRecurring)
          Row(
            children: [
              for (final f in frequencies) ...[
                if (f != frequencies.first)
                  const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _DateChip(
                    label: labels[f]!,
                    isSelected: _frequency == f,
                    color: color,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _frequency = f);
                    },
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movimientoToEdit != null;

    return AppScaffold(
      title: isEditing
          ? context.watch<AppLocaleController>().text('edit_movement')
          : context.watch<AppLocaleController>().text('new_movement'),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.type == null)
              Center(
                child: AppSegmented<String>(
                  selected: _tipo,
                  onChanged: (tipo) => setState(() {
                    _tipo = tipo;
                    _selectedCategory = tipo == 'ingreso'
                        ? _categoriasIngreso.first
                        : _categoriasGasto.first;
                  }),
                  segments: [
                    AppSegment(
                      value: 'ingreso',
                      label: context.watch<AppLocaleController>().text(
                        'income',
                      ),
                      color: AppColors.incomeGreen,
                    ),
                    AppSegment(
                      value: 'gasto',
                      label: context.watch<AppLocaleController>().text(
                        'expense',
                      ),
                      color: AppColors.expenseRed,
                    ),
                  ],
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
              inputFormatters: [CurrencyInputFormatter()],
              textInputAction: TextInputAction.done,
              onSubmitted: _saveMovement,
              label: '',
              style: AppTextStyles.amountInput.copyWith(
                color: _tipo == 'gasto'
                    ? AppColors.expenseRed
                    : AppColors.incomeGreen,
              ),
              hintText: context.watch<AppLocaleController>().text('amount'),
              hintStyle: AppTextStyles.balanceCardAmount.copyWith(
                color: AppColors.softText.withValues(alpha: 0.35),
              ),
              prefix: Baseline(
                baseline: 30,
                baselineType: TextBaseline.alphabetic,
                child: Text(
                  CurrencyHelper.getSymbol(context),
                  style: AppTextStyles.titleMain.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        (_tipo == 'gasto'
                                ? AppColors.expenseRed
                                : AppColors.incomeGreen)
                            .withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            AppSectionTitle(
              context.watch<AppLocaleController>().text(
                'category_section_label',
              ),
              spaceAbove: false,
            ),

            const SizedBox(height: AppSpacing.sm),

            SizedBox(
              height: 85,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tipo == 'gasto'
                    ? _categoriasGasto.length
                    : _categoriasIngreso.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final category = _tipo == 'gasto'
                      ? _categoriasGasto[index]
                      : _categoriasIngreso[index];
                  final isSelected = _selectedCategory == category;
                  final icon = CategoryIcons.of(category);
                  final color = _tipo == 'gasto'
                      ? AppColors.expenseRed
                      : AppColors.incomeGreen;

                  final localizedName = L10nHelper.getLocalizedCategory(
                    context,
                    category,
                  );

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 84,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color
                            : color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : color.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: isSelected
                                ? Colors.white
                                : color.withValues(alpha: 0.7),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              localizedName.toUpperCase(),
                              style: AppTextStyles.badge.copyWith(
                                height: 1.1,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : color.withValues(alpha: 0.85),
                              ),
                              // Dos líneas: "TARJETA DE CRÉDITO" ya no se corta.
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            AppSectionTitle(
              context.watch<AppLocaleController>().text('date'),
              spaceAbove: false,
            ),

            const SizedBox(height: AppSpacing.sm),

            _buildDateSelector(context.watch<AppLocaleController>()),

            // Repetir / cuotas solo al crear: una recurrencia existente se
            // gestiona desde la pantalla "Pagos fijos".
            if (!isEditing) ...[
              const SizedBox(height: AppSpacing.lg),
              if (_installments == null || _tipo != 'gasto')
                _buildRecurringSelector(context.watch<AppLocaleController>()),
              if (_tipo == 'gasto' && !_isRecurring)
                _buildInstallmentsSelector(
                  context.watch<AppLocaleController>(),
                ),
            ],

            const SizedBox(height: AppSpacing.xl),

            GlassInput(
              controller: _noteController,
              label: context
                  .watch<AppLocaleController>()
                  .text('note')
                  .toUpperCase(),
              icon: AppIcons.note,
              hintText: context.watch<AppLocaleController>().text('note_hint'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: context
                    .watch<AppLocaleController>()
                    .text('save')
                    .toUpperCase(),
                onPressed: _saveMovement,
                borderRadius: AppRadius.lg,
                gradientColors: AppGradients.primaryGradient.colors,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CardChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return AppPill(
      label: label,
      icon: icon,
      selected: isSelected,
      activeColor: AppColors.expenseRed,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppPill(
      label: label.toUpperCase(),
      icon: icon,
      selected: isSelected,
      activeColor: color,
      onTap: onTap,
      expand: true,
    );
  }
}
