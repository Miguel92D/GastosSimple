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

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;

  Future<void> _exportBackup() async {
    final l10n = context.read<AppLocaleController>();
    setState(() => _isLoading = true);
    try {
      final path = await BackupController.exportBackup();
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
               padding: const EdgeInsets.all(AppSpacing.lg),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_sync,
                    size: 80,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.text('keep_data_safe'),
                    style: AppTextStyles.titleMain,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.text('backup_screen_desc'),
                    style: AppTextStyles.bodyMain,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  GradientButton(
                    text: l10n.text('create_backup').toUpperCase(),
                    icon: Icons.upload_rounded,
                    borderRadius: AppRadius.lg,
                    onPressed: _exportBackup,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Acción secundaria: mismo alto y radio que GradientButton,
                  // fondo transparente con borde cardBorder.
                  OutlinedButton.icon(
                    onPressed: _restoreBackup,
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: Text(
                      l10n.text('restore_backup_action').toUpperCase(),
                      style: AppTextStyles.buttonLabel,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
