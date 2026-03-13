import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../services/security_service.dart';

import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_text_styles.dart';

class PinLockScreen extends StatefulWidget {
  final Widget nextScreen;
  final String titleKey;
  const PinLockScreen({
    super.key,
    required this.nextScreen,
    this.titleKey = 'app_locked',
  });


  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _input = '';
  String _error = '';

  void _onKeyPress(String key) async {
    if (_input.length < 4) {
      setState(() {
        _input += key;
        _error = '';
      });

      if (_input.length == 4) {
        final success = await SecurityService.instance.authenticatePin(_input);
        if (success) {
          SecurityService.instance.unlock();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => widget.nextScreen),
            );
          }
        } else {
          setState(() {
            _input = '';
            _error = context.watch<AppLocaleController>().text('wrong_pin');
          });
        }
      }
    }
  }

  void _backspace() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
        _error = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (SecurityService.instance.isBiometricActive) {
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final success = await SecurityService.instance.authenticateBiometric();
    if (success) {
      SecurityService.instance.unlock();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.nextScreen),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_outline, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              context.watch<AppLocaleController>().text(widget.titleKey),
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _input.length
                        ? Colors.deepPurple
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error, style: const TextStyle(color: Colors.red)),
              ),
            const Spacer(),
            _buildKeyboard(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) => _buildKey(key)).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80, height: 80),
            _buildKey('0'),
            IconButton(
              onPressed: _backspace,
              icon: const Icon(Icons.backspace_outlined),
              iconSize: 28,
              style: IconButton.styleFrom(minimumSize: const Size(80, 80)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String label) {
    return InkWell(
      onTap: () => _onKeyPress(label),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
