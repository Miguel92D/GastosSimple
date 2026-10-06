import 'package:flutter/material.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../app_gradients.dart';
import '../widgets/app_round_button.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';

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
        // Flecha atrás en pantallas internas (el menú vive abajo, el slot queda libre).
        leading: Navigator.of(context).canPop()
            ? const BackButton(color: AppColors.textPrimary)
            : null,
        title: titleWidget ?? Text(title, style: AppTextStyles.screenTitle),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: actions,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppGradients.mainBackgroundRadial),
        child: Column(
          children: [
            // Reserved space for the transparent AppBar
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // Sin menú ni botón no va nada: un Stack vacío ocupa toda la pantalla y
      // los avisos flotantes quedaban arriba del borde, sin verse (P-22).
      floatingActionButton: drawer == null && floatingActionButton == null
          ? null
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  if (drawer != null)
                    Builder(
                      builder: (scaffoldContext) => AppRoundButton(
                        icon: AppIcons.menu,
                        onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
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
