import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/ui/app_spacing.dart';
import 'package:gastos_simple/core/ui/app_colors.dart';
import 'package:gastos_simple/core/ui/app_gradients.dart';
import 'package:gastos_simple/core/ui/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../services/security_service.dart';

class PinScreen extends StatefulWidget {
  final bool isVault;
  final bool isSetup;
  final VoidCallback? onSuccess;

  const PinScreen({
    super.key,
    this.isVault = false,
    this.isSetup = false,
    this.onSuccess,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String _firstPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isSetup) {
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    if (SecurityService.instance.isBiometricActive) {
      final l10n = context.read<AppLocaleController>();
      final success = await SecurityService.instance.authenticateBiometric(
        localizedReason: l10n.text('biometric_subtitle'),
      );
      if (success) {
        _handleSuccess();
      }
    }
  }

  void _onKeyPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });
      if (_pin.length == 4) {
        if (widget.isSetup) {
          _handleSetup();
        } else {
          _submitPin();
        }
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _handleSetup() async {
    if (!_isConfirming) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
    } else {
      if (_pin == _firstPin) {
        if (widget.isVault) {
          await SecurityService.instance.setVaultPin(_pin);
        } else {
          await SecurityService.instance.setPin(_pin);
        }
        _handleSuccess();
      } else {
        final l10n = context.read<AppLocaleController>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.text('pins_not_match'))),
        );
        setState(() {
          _pin = '';
        });
      }
    }
  }

  Future<void> _submitPin() async {
    setState(() => _isLoading = true);
    final bool success;
    if (widget.isVault) {
      success = await SecurityService.instance.authenticateVaultPin(_pin);
    } else {
      success = await SecurityService.instance.authenticatePin(_pin);
    }
    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      _handleSuccess();
    } else {
      if (!mounted) return;
      final l10n = context.read<AppLocaleController>();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.text('wrong_pin'))));
      setState(() {
        _pin = '';
      });
    }
  }

  void _handleSuccess() {
    if (widget.isVault) {
      SecurityService.instance.unlockVault();
    } else {
      SecurityService.instance.unlock();
    }

    if (widget.onSuccess != null) {
      widget.onSuccess!();
    } else {
      // Solo hacemos pop si hay una ruta previa en el Navigator.
      // Esto evita el "pantallazo negro" cuando el PinScreen es el widget raíz (InitialGuard).
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context, true);
      }
    }
  }

  Widget _buildNumpadButton(String digit) {
    return InkWell(
      onTap: () => _onKeyPress(digit),
      customBorder: const CircleBorder(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryPurple.withValues(alpha: 0.1),
        ),
        child: Text(
          digit,
          style: AppTextStyles.titleMain.copyWith(
            fontSize: 24,
            color: AppColors.primaryPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return IconButton(
      icon: Icon(
        Icons.fingerprint,
        size: 32,
        color: SecurityService.instance.isBiometricActive
            ? AppColors.primaryPurple
            : Colors.transparent,
      ),
      onPressed: SecurityService.instance.isBiometricActive ? _tryBiometric : null,
    );
  }

  Widget _buildBackspaceButton() {
    return IconButton(
      icon: const Icon(
        Icons.backspace_outlined,
        size: 24,
        color: AppColors.softText,
      ),
      onPressed: _onBackspace,
    );
  }

  String _getTitle(AppLocaleController l10n) {
    if (widget.isSetup) {
      if (_isConfirming) {
        return l10n.text('confirm_pin');
      }
      return widget.isVault ? l10n.text('set_vault_pin') : l10n.text('set_pin');
    }
    return widget.isVault ? l10n.text('enter_vault_pin') : l10n.text('enter_pin');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();

    // Pantalla modal: mismo fondo que AppScaffold, con AppBar propio
    // (botón cerrar) porque AppScaffold no contempla este caso.
    return Container(
      decoration: BoxDecoration(gradient: AppGradients.mainBackgroundRadial),
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isSetup || widget.isVault
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallHeight = constraints.maxHeight < 500;
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: isLandscape ? AppSpacing.sm : AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isSmallHeight) ...[
                        Icon(
                          widget.isVault
                              ? Icons.enhanced_encryption_rounded
                              : Icons.lock_outline,
                          size: 64,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      Text(
                        _getTitle(l10n),
                        style: AppTextStyles.titleMain,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < _pin.length
                                  ? AppColors.primaryPurple
                                  : AppColors.softText.withValues(alpha: 0.3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.xxl),
                          child: CircularProgressIndicator(),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            mainAxisSpacing: isSmallHeight ? 8 : 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: isSmallHeight ? 1.6 : 1.2,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (var i = 1; i <= 9; i++)
                                _buildNumpadButton(i.toString()),
                              _buildBiometricButton(),
                              _buildNumpadButton('0'),
                              _buildBackspaceButton(),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}
