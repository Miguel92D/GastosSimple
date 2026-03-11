import 'package:flutter/material.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../glass_card.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final Widget? titleWidget;
  final Widget? floatingActionButton;
  final Widget? drawer;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.titleWidget,
    this.floatingActionButton,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Background handled by parent or theme
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Desactivamos el menú de arriba a la izquierda
        title:
            titleWidget ??
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
      ),
      drawer: drawer,
      body: body,
      // Usamos el FAB para posicionar tanto el menú abajo al centro como las acciones a la derecha
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Botón de menú central (solo si hay drawer)
            if (drawer != null)
              Builder(
                builder: (scaffoldContext) => GestureDetector(
                  onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                  child: GlassCard(
                    borderRadius: 50,
                    padding: const EdgeInsets.all(16),
                    glowColor: AppColors.primaryPurple.withOpacity(0.3),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),

            // Acciones a la derecha (Ingreso/Gasto)
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
