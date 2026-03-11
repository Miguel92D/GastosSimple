import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/currency_helper.dart';
import '../controllers/debt_controller.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/glass_card.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  final _controller = DebtController.instance;
  List<Debt> _debts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final debts = await _controller.loadDebts();
    if (mounted) {
      setState(() {
        _debts = debts;
        _isLoading = false;
      });
    }
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: AppTextStyles.cardTitle),
        content: Text(content, style: AppTextStyles.bodyMain),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: AppTextStyles.bodyMain.copyWith(
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDebtForm({Debt? debt}) {
    final nombreController = TextEditingController(text: debt?.nombre);
    final montoTotalController = TextEditingController(
      text: debt?.montoTotal.toString(),
    );
    final pagoMinimoController = TextEditingController(
      text: debt?.pagoMinimo.toString(),
    );
    final tasaInteresController = TextEditingController(
      text: debt?.tasaInteres?.toString() ?? '',
    );
    final fechaVencimientoController = TextEditingController(
      text: debt?.fechaVencimiento ?? '',
    );
    final diaCierreController = TextEditingController(
      text: debt?.diaCierre?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  debt == null ? l10n.new_debt : l10n.edit_debt,
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 24),
                _buildField(l10n.debt_name_label, nombreController),
                _buildField(
                  l10n.total_amount,
                  montoTotalController,
                  keyboard: TextInputType.number,
                ),
                _buildField(
                  l10n.min_payment,
                  pagoMinimoController,
                  keyboard: TextInputType.number,
                ),
                _buildField(
                  l10n.interest_rate_optional,
                  tasaInteresController,
                  keyboard: TextInputType.number,
                  helpTitle: l10n.interest_rate_title,
                  helpDesc: l10n.interest_rate_desc,
                  context: context,
                ),
                _buildField(
                  l10n.card_closing_label,
                  diaCierreController,
                  keyboard: TextInputType.number,
                  helpTitle: l10n.card_closing_title,
                  helpDesc: l10n.card_closing_desc,
                  context: context,
                ),
                _buildField(
                  l10n.due_day_label,
                  fechaVencimientoController,
                  keyboard: TextInputType.number,
                  helpTitle: l10n.due_date_title,
                  helpDesc: l10n.due_date_desc,
                  context: context,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    final newDebt = Debt(
                      id: debt?.id,
                      nombre: nombreController.text,
                      montoTotal:
                          double.tryParse(montoTotalController.text) ?? 0,
                      pagoMinimo:
                          double.tryParse(pagoMinimoController.text) ?? 0,
                      tasaInteres: double.tryParse(tasaInteresController.text),
                      fechaVencimiento: fechaVencimientoController.text,
                      diaCierre: int.tryParse(diaCierreController.text),
                      montoPagado: debt?.montoPagado ?? 0,
                    );

                    if (newDebt.diaCierre != null &&
                        (newDebt.diaCierre! < 1 || newDebt.diaCierre! > 31)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.closing_day_error,
                          ),
                        ),
                      );
                      return;
                    }

                    await _controller.saveDebt(newDebt);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _loadDebts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(l10n.save, style: AppTextStyles.buttonLabel),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    String? helpTitle,
    String? helpDesc,
    BuildContext? context,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: AppTextStyles.bodyMain,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMain.copyWith(color: AppColors.textMuted),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryPurple),
        ),
        suffixIcon: helpTitle != null
            ? IconButton(
                icon: const Icon(
                  Icons.help_outline_rounded,
                  size: 20,
                  color: AppColors.softText,
                ),
                onPressed: () =>
                    _showInfoDialog(context!, helpTitle, helpDesc!),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalRemaining = _debts.fold(0.0, (sum, d) => sum + d.remaining);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          l10n.debts,
          style: AppTextStyles.titleLarge.copyWith(fontSize: 22),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSummary(context, totalRemaining),
                  const SizedBox(height: 24),
                  _buildStrategySection(context),
                  const SizedBox(height: 32),
                  _buildBottomActionButton(context, l10n),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSummary(BuildContext context, double total) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TUS DEUDAS",
                style: AppTextStyles.subLabel.copyWith(
                  letterSpacing: 1.2,
                  color: AppColors.softText.withOpacity(0.6),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "TOTAL: ",
                      style: AppTextStyles.subLabel.copyWith(
                        color: AppColors.softText.withOpacity(0.6),
                      ),
                    ),
                    TextSpan(
                      text: CurrencyHelper.format(total, context),
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._debts.map((debt) => _buildDebtItem(context, debt)),
        ],
      ),
    );
  }

  Widget _buildDebtItem(BuildContext context, Debt debt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.glassSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Center(
                  child: Icon(
                    debt.nombre.toLowerCase().contains('bbva')
                        ? Icons.account_balance_rounded
                        : Icons.credit_card_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.nombre,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    _buildCustomProgressBar(debt.progress, debt.nombre),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyHelper.format(debt.remaining, context),
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${(debt.progress * 100).toInt()}%",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.softText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomProgressBar(double progress, String name) {
    final color = name.toLowerCase().contains('bbva')
        ? AppColors.orange
        : AppColors.primaryPurple;

    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 200 * progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySection(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ELIGE UNA ESTRATEGIA",
            style: AppTextStyles.subLabel.copyWith(
              letterSpacing: 1.2,
              color: AppColors.softText.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          _buildStrategyCard(
            title: "Avalancha",
            desc: "Ahorra intereses",
            icon: Icons.bolt_rounded,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 12),
          _buildStrategyCard(
            title: "Bola de Nieve",
            desc: "Aumenta motivación",
            icon: Icons.ac_unit_rounded,
            color: AppColors.primaryPurple,
          ),
          const SizedBox(height: 24),
          Text(
            "Avalancha: Paga primero la deuda con el mayor interés.\nBola de Nieve: Paga la deuda más pequeña para ganar motivación.",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.softText.withOpacity(0.5),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.02)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                ),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.softText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Text(
                  "Elegir",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showDebtForm(),
      child: GlassCard(
        height: 64,
        borderRadius: 32,
        padding: EdgeInsets.zero,
        glowColor: AppColors.primaryPurple.withOpacity(0.3),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.5)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Agregar pago",
                style: AppTextStyles.buttonLabel.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
