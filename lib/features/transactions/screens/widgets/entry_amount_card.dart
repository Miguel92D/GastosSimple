import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/glass_card.dart';

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
    return GlassCard(
      glowColor: widget.color,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              hintText: "0.00",
              hintStyle: const TextStyle(color: Colors.white24),
              border: InputBorder.none,
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                color: widget.color,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
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
