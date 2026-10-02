import '../models/transaction.dart';

/// Exporta movimientos a CSV pensado para Excel / Google Sheets en
/// español: separador ";", coma decimal y BOM UTF-8 (para que Excel lea
/// bien tildes y ñ).
class TransactionCsv {
  TransactionCsv._();

  static const String bom = '﻿';
  static const String _sep = ';';

  /// [localize] traduce la categoría guardada al idioma de la app.
  /// [headers]: fecha, tipo, categoría, monto, nota (ya traducidos).
  /// [typeLabels]: etiqueta para ingreso y para gasto.
  static String build(
    List<Transaction> items, {
    required List<String> headers,
    required ({String income, String expense}) typeLabels,
    String Function(String category)? localize,
  }) {
    final buffer = StringBuffer(bom)
      ..write(headers.map(_escape).join(_sep))
      ..write('\r\n');
    for (final t in items) {
      final signed = t.isExpense ? -t.amount : t.amount;
      buffer
        ..write([
          _date(t.date),
          _escape(t.isIncome ? typeLabels.income : typeLabels.expense),
          _escape(localize?.call(t.category) ?? t.category),
          _amount(signed),
          _escape(t.note ?? ''),
        ].join(_sep))
        ..write('\r\n');
    }
    return buffer.toString();
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// dd/mm/aaaa hh:mm
  static String _date(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

  /// Monto con signo, 2 decimales y coma decimal, sin separador de miles
  /// (Excel lo toma como número).
  static String _amount(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  /// Comillas si hace falta y protección contra fórmulas: un texto que
  /// empieza con = + - @ se ejecutaría como fórmula al abrirlo en Excel.
  static String _escape(String value) {
    var v = value;
    if (v.isNotEmpty && '=+-@'.contains(v[0])) v = "'$v";
    final needsQuotes = v.contains(_sep) ||
        v.contains('"') ||
        v.contains('\n') ||
        v.contains('\r');
    if (!needsQuotes) return v;
    return '"${v.replaceAll('"', '""')}"';
  }
}
