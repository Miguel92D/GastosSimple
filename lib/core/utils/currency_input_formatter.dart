import 'package:flutter/services.dart';
import 'dart:math';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final bool isNegative = newValue.text.startsWith('-');
    String text = newValue.text;
    if (isNegative) {
      text = text.substring(1);
    }

    text = text.replaceAll(' ', '');
    text = text.replaceAll('.', '');

    if (','.allMatches(text).length > 1) {
      return oldValue;
    }

    final parts = text.split(',');
    String intPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
    String decPart = parts.length > 1
        ? parts[1].replaceAll(RegExp(r'[^0-9]'), '')
        : '';

    if (decPart.length > 2) {
      return oldValue;
    }

    String formattedText = '';

    if (intPart.isNotEmpty) {
      List<String> chars = intPart.split('');
      String formattedWhole = '';
      int count = 0;
      for (int i = chars.length - 1; i >= 0; i--) {
        formattedWhole = chars[i] + formattedWhole;
        count++;
        if (count == 3 && i != 0) {
          formattedWhole = '.$formattedWhole';
          count = 0;
        }
      }
      formattedText = formattedWhole;
    }

    if (text.contains(',')) {
      formattedText += ',$decPart';
    }

    if (isNegative) {
      formattedText = '-$formattedText';
    }

    int cleanOffset = 0;
    for (
      int i = 0;
      i < newValue.selection.end && i < newValue.text.length;
      i++
    ) {
      if (newValue.text[i] != '.') cleanOffset++;
    }

    int newSelection = 0;
    int currentCleanOffset = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (formattedText[i] != '.') {
        currentCleanOffset++;
      }
      if (currentCleanOffset >= cleanOffset) {
        newSelection = i + 1;
        break;
      }
    }
    if (cleanOffset <= 0) newSelection = 0;

    newSelection = min(newSelection, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelection),
    );
  }
}
