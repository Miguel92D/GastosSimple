import 'package:flutter/material.dart';
import '../../services/pro_service.dart';

class ProFeature extends StatelessWidget {
  final Widget child;

  const ProFeature({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (ProService.instance.isPro) {
      return child;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.lock, size: 60, color: Colors.amber),

          SizedBox(height: 16),

          Text(
            "Función PRO",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 8),

          Text("Actualiza para desbloquear esta función"),
        ],
      ),
    );
  }
}
