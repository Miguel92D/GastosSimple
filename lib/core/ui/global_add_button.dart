import 'package:flutter/material.dart';

class GlobalAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GlobalAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      onPressed: onPressed,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
