class Debt {
  final int? id;
  final String nombre;
  final double montoTotal;
  final double montoPagado;
  final double pagoMinimo;
  final double? tasaInteres;
  final String fechaVencimiento;
  final int? diaCierre;

  Debt({
    this.id,
    required this.nombre,
    required this.montoTotal,
    this.montoPagado = 0.0,
    required this.pagoMinimo,
    this.tasaInteres,
    required this.fechaVencimiento,
    this.diaCierre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'monto_total': montoTotal,
      'monto_pagado': montoPagado,
      'pago_minimo': pagoMinimo,
      'tasa_interes': tasaInteres,
      'fecha_vencimiento': fechaVencimiento,
      'dia_cierre': diaCierre,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      nombre: map['nombre'],
      montoTotal: map['monto_total'],
      montoPagado: map['monto_pagado'] ?? 0.0,
      pagoMinimo: map['pago_minimo'],
      tasaInteres: map['tasa_interes'],
      fechaVencimiento: map['fecha_vencimiento'],
      diaCierre: map['dia_cierre'],
    );
  }

  double get progress => montoTotal > 0 ? montoPagado / montoTotal : 0;
  double get remaining => montoTotal - montoPagado;
}
