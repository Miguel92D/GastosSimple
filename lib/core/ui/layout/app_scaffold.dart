import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final Widget? floatingActionButton;
  final Widget? drawer;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.floatingActionButton,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), elevation: 0),
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
