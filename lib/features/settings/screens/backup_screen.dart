import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/backup_controller.dart';
import '../../../core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_text_styles.dart';
import '../../../core/ui/layout/app_scaffold.dart';
import '../../../core/ui/widgets/gradient_button.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;

  Future<void> _exportBackup() async {
    final l10n = context.read<AppLocaleController>();
    // La Bóveda solo sale del teléfono si el usuario lo confirma: el
    // archivo es un JSON sin cifrar.
    var includeVault = false;
    if (await BackupController.hasVaultData()) {
      if (!mounted) return;
      final answer = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.text('backup_vault_title')),
          content: Text(l10n.text('backup_vault_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.text('backup_vault_exclude')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.text('backup_vault_include')),
            ),
          ],
        ),
      );
      if (answer == null) return; // cerró el diálogo: no exportar
      includeVault = answer;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final path = await BackupController.exportBackup(
        includeVault: includeVault,
      );
      if (!mounted) return;
      await Share.shareXFiles([XFile(path)], text: 'Backup \$imple');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.text('error_prefix')}$e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreBackup() async {
    final l10n = context.read<AppLocaleController>();
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        await BackupController.restoreBackup(result.files.single.path!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.text('data_restored'))));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.text('error_prefix')}$e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocaleController>();
    return AppScaffold(
      title: l10n.text('backup_data_title'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            )
          : Padding(
               padding: const EdgeInsets.all(AppSpacing.lg),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    AppIcons.backup,
                    size: 72,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.text('keep_data_safe'),
                    style: AppTextStyles.titleMain.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.text('backup_screen_desc'),
                    style: AppTextStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  GradientButton(
                    text: l10n.text('create_backup'),
                    icon: AppIcons.exportFile,
                    onPressed: _exportBackup,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: _restoreBackup,
                    icon: const Icon(AppIcons.importFile),
                    label: Text(l10n.text('restore_backup_action')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryPurple,
                      side: BorderSide(
                        color: AppColors.primaryPurple.withValues(alpha: 0.6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      textStyle: AppTextStyles.buttonLabel,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
