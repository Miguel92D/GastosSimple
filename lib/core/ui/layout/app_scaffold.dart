import 'package:flutter/material.dart';
import '../app_text_styles.dart';

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
      floatingActionButton: floatingActionButton,
    );
  }
}
