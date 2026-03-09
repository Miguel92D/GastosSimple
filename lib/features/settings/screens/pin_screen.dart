import 'package:flutter/material.dart';
import '../../../services/security_service.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (SecurityService.instance.isBiometricActive) {
      final success = await SecurityService.instance.authenticateBiometric();
      if (success) {
        _handleSuccess();
      }
    }
  }

  void _onKeyPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });
      if (_pin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _submitPin() async {
    setState(() => _isLoading = true);
    final success = await SecurityService.instance.authenticatePin(_pin);
    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      _handleSuccess();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN incorrecto')));
      setState(() {
        _pin = '';
      });
    }
  }

  void _handleSuccess() {
    SecurityService.instance.unlock();
    Navigator.pop(context, true);
  }

  Widget _buildNumpadButton(String digit) {
    return InkWell(
      onTap: () => _onKeyPress(digit),
      customBorder: const CircleBorder(),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        ),
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60), // Space from top
            Icon(
              Icons.lock_outline,
              size: 72,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Ingresa tu PIN',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    color: index < _pin.length
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const Spacer(flex: 2), // Pushes content up
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 24, // Increased spacing between rows
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 1; i <= 9; i++)
                      _buildNumpadButton(i.toString()),
                    IconButton(
                      icon: Icon(
                        Icons.fingerprint,
                        size: 44,
                        color: SecurityService.instance.isBiometricActive
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                      ),
                      onPressed: SecurityService.instance.isBiometricActive
                          ? _tryBiometric
                          : null,
                    ),
                    _buildNumpadButton('0'),
                    IconButton(
                      icon: const Icon(Icons.backspace_outlined, size: 28),
                      onPressed: _onBackspace,
                    ),
                  ],
                ),
              ),
            const Spacer(flex: 1), // Space at bottom to avoid nav bar overlap
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
