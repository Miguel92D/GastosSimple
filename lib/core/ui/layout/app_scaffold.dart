import 'package:flutter/material.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../app_gradients.dart';
import '../glass_card.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final Widget? titleWidget;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final bool? resizeToAvoidBottomInset;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.titleWidget,
    this.floatingActionButton,
    this.drawer,
    this.resizeToAvoidBottomInset,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      drawer: drawer,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: titleWidget ??
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 24,
                letterSpacing: -1,
              ),
            ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: actions,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppGradients.mainBackgroundRadial,
        ),
        child: Column(
          children: [
            // Reserved space for the transparent AppBar
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            Expanded(
              child: body,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (drawer != null)
              Builder(
                builder: (scaffoldContext) => GestureDetector(
                  onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                  child: GlassCard(
                    width: 56,
                    height: 56,
                    borderRadius: 18,
                    padding: EdgeInsets.zero,
                    glowColor: AppColors.primaryPurple.withValues(alpha: 0.4),
                    border: Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.menu_rounded,
                        color: AppColors.primaryPurple,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            if (floatingActionButton != null)
              Align(
                alignment: Alignment.bottomRight,
                child: floatingActionButton!,
              ),
          ],
        ),
      ),
    );
  }
}
