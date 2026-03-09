import 'package:flutter/material.dart';

class EntryAmountCard extends StatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Function(double) onSubmit;

  const EntryAmountCard({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.onSubmit,
  });

  @override
  State<EntryAmountCard> createState() => _EntryAmountCardState();
}

class _EntryAmountCardState extends State<EntryAmountCard> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "0",
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              prefixText: '\$',
              prefixStyle: const TextStyle(color: Colors.white, fontSize: 32),
            ),
            onSubmitted: (value) {
              final amount = double.tryParse(value.replaceAll(',', '.')) ?? 0;
              widget.onSubmit(amount);
            },
          ),
        ],
      ),
    );
  }
}
