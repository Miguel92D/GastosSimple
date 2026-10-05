// Números (chat 03): que los totales cuadren entre pantallas y que todas las
// cuentas de dinero sigan D-005. Parte sin base y parte con SQLite en memoria
// (D-014).
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/utils/money.dart';
import 'package:gastos_simple/database/database_helper.dart';
import 'package:gastos_simple/features/dashboard/controllers/dashboard_controller.dart';
import 'package:gastos_simple/features/debts/controllers/debt_controller.dart';
import 'package:gastos_simple/features/debts/models/debt.dart';
import 'package:gastos_simple/features/debts/utils/debt_math.dart';
import 'package:gastos_simple/features/transactions/controllers/transaction_controller.dart';
import 'package:gastos_simple/features/transactions/models/transaction.dart';
import 'package:gastos_simple/features/transactions/utils/transaction_filter.dart';
import 'package:gastos_simple/services/daily_allowance_service.dart';
import 'package:gastos_simple/services/monthly_finance_service.dart';
import 'package:gastos_simple/services/stats_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

Transaction _mov(
  String type,
  double amount,
  DateTime date, {
  String category = 'Comida',
  int isSecret = 0,
}) => Transaction(
  amount: amount,
  category: category,
  type: type,
  date: date,
  isSecret: isSecret,
);

Debt _debt(String nombre, double total, {double pagado = 0, double? tasa}) =>
    Debt(
      nombre: nombre,
      montoTotal: total,
      montoPagado: pagado,
      pagoMinimo: 0,
      tasaInteres: tasa,
      fechaVencimiento: '10/10/2026',
    );

/// Lo que muestra cada pantalla para un mes, calculado igual que ella.
class _Pantallas {
  final double inicioIngresos;
  final double inicioGastos;
  final double inicioSaldo;
  final double movimientosIngresos;
  final double movimientosGastos;
  final double estadisticasPorCategoria;
  final MonthTotals estadisticasMes;

  _Pantallas({
    required this.inicioIngresos,
    required this.inicioGastos,
    required this.inicioSaldo,
    required this.movimientosIngresos,
    required this.movimientosGastos,
    required this.estadisticasPorCategoria,
    required this.estadisticasMes,
  });
}

Future<_Pantallas> _leerPantallas(DateTime month) async {
  final controller = DashboardController();
  final now = DateTime.now();

  // Inicio (DashboardWidget, modo MES).
  final inicio = await controller.loadMovements(false, month: month);

  // Movimientos con el filtro de ese mes (lo que abre Estadísticas).
  final historial = await TransactionController.getNormalHistory();
  final filtrados = TransactionFilter(
    period: PeriodFilter.specificMonth,
    month: month,
  ).apply(historial, now: now);

  // Estadísticas (StatsScreen._loadData).
  final delMes = MonthlyFinanceService.filterTransactionsForMonth(
    historial,
    month,
  );
  final porCategoria = StatsService.expensesByCategory(delMes);
  final tendencia = StatsService.monthlyTrend(historial, endMonth: month);

  return _Pantallas(
    inicioIngresos: controller.calculateIncome(inicio),
    inicioGastos: controller.calculateExpenses(inicio),
    inicioSaldo: controller.calculateBalance(inicio),
    movimientosIngresos: Money.sum(
      filtrados.where((t) => t.isIncome).map((t) => t.amount),
    ),
    movimientosGastos: Money.sum(
      filtrados.where((t) => t.isExpense).map((t) => t.amount),
    ),
    estadisticasPorCategoria: Money.sum(porCategoria.map((e) => e.value)),
    estadisticasMes: tendencia.last,
  );
}

void _expectCuadran(_Pantallas p) {
  expect(p.movimientosIngresos, p.inicioIngresos);
  expect(p.movimientosGastos, p.inicioGastos);
  expect(p.estadisticasPorCategoria, p.inicioGastos);
  expect(p.estadisticasMes.income, p.inicioIngresos);
  expect(p.estadisticasMes.expense, p.inicioGastos);
  expect(p.estadisticasMes.saving, p.inicioSaldo);
}

void main() {
  group('Cuentas sin base (D-005)', () {
    test('el saldo se calcula en centavos: 0,30 − 0,10 = 0,20 exacto', () {
      final items = [
        _mov('ingreso', 0.1, DateTime(2026, 10, 1)),
        _mov('ingreso', 0.2, DateTime(2026, 10, 1)),
        _mov('gasto', 0.1, DateTime(2026, 10, 2)),
      ];
      expect(MonthlyFinanceService.calculateBalance(items), 0.2);
      final mes = StatsService.monthlyTrend(
        items,
        endMonth: DateTime(2026, 10),
      ).last;
      expect(mes.saving, 0.2);
    });

    test('un tipo viejo o desconocido cuenta como gasto en todos lados', () {
      final items = [
        _mov('ingreso', 100, DateTime(2026, 10, 1)),
        _mov('Gasto', 30, DateTime(2026, 10, 2)),
        _mov('expense', 20, DateTime(2026, 10, 3)),
      ];
      expect(MonthlyFinanceService.calculateExpenses(items), 50);
      expect(
        StatsService.monthlyTrend(
          items,
          endMonth: DateTime(2026, 10),
        ).last.expense,
        50,
      );
      expect(StatsService.expensesByCategory(items).single.value, 50);
    });

    group('Podés gastar hoy', () {
      final now = DateTime(2026, 10, 21, 15); // quedan 11 días

      test('el límite diario va redondeado a centavos', () {
        final a = DailyAllowanceService.compute(
          monthTransactions: [
            _mov('ingreso', 100, DateTime(2026, 10, 1)),
            _mov('gasto', 9.09, DateTime(2026, 10, 21, 9)),
          ],
          recurring: const [],
          now: now,
        );
        // 100 / 11 = 9,0909… → 9,09
        expect(a.perDay, 9.09);
        // Gastó justo el límite: queda 0, no 0,0009 ni −0,00.
        expect(a.leftToday, 0);
        expect(a.state, AllowanceState.ok);
      });

      test(
        'la última cuota pendiente usa su monto real (absorbe el redondeo)',
        () {
          final a = DailyAllowanceService.compute(
            monthTransactions: [_mov('ingreso', 1000, DateTime(2026, 10, 1))],
            recurring: [
              {
                'type': 'gasto',
                'amount': 33.33,
                'frequency': 'monthly',
                'next_date': DateTime(2026, 10, 25).toIso8601String(),
                'anchor_day': 25,
                'installments_total': 3,
                'installments_paid': 2,
                'installments_total_amount': 100.0,
              },
            ],
            now: now,
          );
          // 100 − 33,33 × 2 = 33,34 (lo mismo que después genera la cuota).
          expect(a.pendingFixedExpenses, 33.34);
          expect(a.available, 966.66);
        },
      );

      test(
        'gastar todo lo disponible marca exceso sin errores de redondeo',
        () {
          final a = DailyAllowanceService.compute(
            monthTransactions: [
              _mov('ingreso', 0.3, DateTime(2026, 10, 1)),
              _mov('gasto', 0.1, DateTime(2026, 10, 2)),
              _mov('gasto', 0.2, DateTime(2026, 10, 21, 9)), // hoy
            ],
            recurring: const [],
            now: now,
          );
          expect(a.available, 0.2);
          expect(a.state, AllowanceState.overspent);
        },
      );
    });

    group('Deudas', () {
      test('el total pendiente suma en centavos', () {
        final debts = [_debt('A', 0.3, pagado: 0.1), _debt('B', 0.1)];
        expect(DebtMath.totalRemaining(debts), 0.3);
      });

      test('una deuda pagada de más no descuenta de las otras', () {
        final debts = [
          _debt('A', 1000, pagado: 1200),
          _debt('B', 500, pagado: 100),
        ];
        expect(debts.first.isPaid, isTrue);
        expect(DebtMath.totalRemaining(debts), 400);
      });

      test('una deuda casi saldada no es "pagada" (nada de 0,999)', () {
        // Antes: progress >= 0.999 marcaba pagada con 10.000 pendientes.
        final d = _debt('Hipoteca', 10000000, pagado: 9990000);
        expect(d.isPaid, isFalse);
        expect(DebtMath.totalRemaining([d]), 10000);
        expect(DebtMath.priority([d]), d);
      });

      test('Avalancha: mayor interés primero y las saldadas al final', () {
        final saldada = _debt('Saldada', 100, pagado: 100, tasa: 99);
        final baja = _debt('Baja', 1000, tasa: 10);
        final alta = _debt('Alta', 5000, tasa: 80);
        final orden = DebtMath.sortForStrategy([
          saldada,
          baja,
          alta,
        ], DebtMath.avalanche);
        expect(orden.map((d) => d.nombre), ['Alta', 'Baja', 'Saldada']);
        expect(DebtMath.priority(orden), alta);
      });

      test('Bola de nieve: menor saldo primero y las saldadas al final', () {
        final saldada = _debt('Saldada', 100, pagado: 100);
        final grande = _debt('Grande', 5000);
        final chica = _debt('Chica', 1000, pagado: 200);
        final orden = DebtMath.sortForStrategy([
          grande,
          saldada,
          chica,
        ], DebtMath.snowball);
        expect(orden.map((d) => d.nombre), ['Chica', 'Grande', 'Saldada']);
        expect(DebtMath.priority(orden), chica);
      });

      test('sin estrategia se respeta el orden y sin pendientes no hay '
          'prioridad', () {
        final a = _debt('A', 100, pagado: 100);
        final b = _debt('B', 50, pagado: 50);
        expect(DebtMath.sortForStrategy([a, b], 'none'), [a, b]);
        expect(DebtMath.priority([a, b]), isNull);
        expect(DebtMath.totalRemaining([a, b]), 0);
      });
    });
  });

  group('Con base en memoria: los totales cuadran entre pantallas', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      DatabaseHelper.pathOverride = inMemoryDatabasePath;
    });

    setUp(DatabaseHelper.resetForTesting);
    tearDownAll(DatabaseHelper.resetForTesting);

    final now = DateTime.now();
    final esteMes = DateTime(now.year, now.month);
    final mesPasado = DateTime(now.year, now.month - 1);
    final primeroDeEsteMes = DateTime(now.year, now.month, 1);

    Future<void> cargarDatos() async {
      for (final m in [
        _mov('ingreso', 1500.10, primeroDeEsteMes, category: 'Salario'),
        _mov('gasto', 0.1, primeroDeEsteMes),
        _mov('gasto', 0.2, primeroDeEsteMes, category: 'Transporte'),
        _mov('gasto', 333.33, primeroDeEsteMes, category: 'Servicios'),
        _mov('ingreso', 800, DateTime(now.year, now.month - 1, 10)),
        _mov('gasto', 120.45, DateTime(now.year, now.month - 1, 12)),
        // Bóveda: nunca suma en lo normal.
        _mov('ingreso', 99999, primeroDeEsteMes, isSecret: 1),
        _mov('gasto', 5555.55, primeroDeEsteMes, isSecret: 1),
      ]) {
        await TransactionController.addTransaction(m);
      }
    }

    test(
      'inicio, Movimientos y Estadísticas dan lo mismo, mes a mes',
      () async {
        await cargarDatos();

        final hoy = await _leerPantallas(esteMes);
        _expectCuadran(hoy);
        expect(hoy.inicioIngresos, 1500.10);
        expect(hoy.inicioGastos, 333.63);
        expect(hoy.inicioSaldo, 1166.47);

        final antes = await _leerPantallas(mesPasado);
        _expectCuadran(antes);
        expect(antes.inicioSaldo, 679.55);
      },
    );

    test(
      'el saldo de la carga rápida es la suma de todo Movimientos',
      () async {
        await cargarDatos();
        final controller = DashboardController();
        final historial = await TransactionController.getNormalHistory();

        final saldo = await controller.getBalance(false);
        expect(saldo, MonthlyFinanceService.calculateBalance(historial));
        // 1500,10 + 800 − 0,1 − 0,2 − 333,33 − 120,45
        expect(saldo, 1846.02);
        expect(await controller.getIncome(false), 2300.10);
        expect(await controller.getExpenses(false), 454.08);

        final porCategoria = await controller.getExpensesByCategory(false);
        expect(porCategoria['Servicios'], 333.33);
        expect(porCategoria.containsKey('Salario'), isFalse);
      },
    );

    test(
      'la Bóveda nunca suma en lo normal y tiene sus propios totales',
      () async {
        await cargarDatos();
        final controller = DashboardController();
        final antes = await _leerPantallas(esteMes);
        final saldoAntes = await controller.getBalance(false);

        await TransactionController.addTransaction(
          _mov('gasto', 777, primeroDeEsteMes, isSecret: 1),
        );

        final despues = await _leerPantallas(esteMes);
        expect(despues.inicioSaldo, antes.inicioSaldo);
        expect(despues.estadisticasMes.expense, antes.estadisticasMes.expense);
        expect(await controller.getBalance(false), saldoAntes);

        // Dentro de la Bóveda: 99.999 − 5.555,55 − 777.
        expect(await controller.getBalance(true), 93666.45);
        final boveda = await controller.loadMovements(true, month: esteMes);
        expect(controller.calculateBalance(boveda), 93666.45);
      },
    );

    test('un tipo guardado a mano ("Gasto") cuenta igual en todas las '
        'pantallas', () async {
      await cargarDatos();
      final db = await DatabaseHelper.instance.database;
      await db.insert('transactions', {
        'amount': 10.0,
        'category': 'Comida',
        'type': 'Gasto', // como lo podía dejar una versión vieja
        'date': primeroDeEsteMes.toIso8601String(),
        'is_secret': 0,
      });

      final p = await _leerPantallas(esteMes);
      _expectCuadran(p);
      expect(p.inicioGastos, 343.63);
      // Antes el SUM de SQL ignoraba "Gasto" y la carga rápida mostraba
      // 10 más que Movimientos.
      expect(await DashboardController().getBalance(false), 1836.02);
    });

    test(
      'pagar una deuda como gasto baja el pendiente y el saldo lo mismo',
      () async {
        await cargarDatos();
        final debts = DebtController.instance;
        await debts.saveDebt(_debt('Tarjeta Visa', 1000.50, pagado: 0.25));
        final deuda = (await debts.loadDebts()).single;
        final pendienteAntes = DebtMath.totalRemaining(await debts.loadDebts());
        final saldoAntes = await DashboardController().getBalance(false);
        expect(pendienteAntes, 1000.25);

        await debts.makePayment(deuda.id!, 300.10, recordExpenseFor: deuda);

        final pendiente = DebtMath.totalRemaining(await debts.loadDebts());
        final saldo = await DashboardController().getBalance(false);
        expect(pendiente, 700.15);
        expect(saldo, 1545.92);
        expect(
          Money.sum([pendienteAntes, -pendiente]),
          Money.sum([saldoAntes, -saldo]),
        );

        // El pago aparece en el mes actual en todas las pantallas.
        final p = await _leerPantallas(esteMes);
        _expectCuadran(p);
        expect(p.inicioGastos, 633.73);
      },
    );

    test('Podés gastar hoy usa los mismos datos que el inicio y deja afuera '
        'la Bóveda', () async {
      await cargarDatos();
      // Pago fijo secreto: no debe restar del límite diario normal.
      await TransactionController.addRecurringTransaction(
        _mov('gasto', 5000, DateTime(now.year, now.month + 1, 1), isSecret: 1),
        'monthly',
      );

      final mes = await TransactionController.getTransactionsInMonth(
        month: now,
      );
      final recurring = await DatabaseHelper.instance
          .getRecurringTransactions();
      expect(recurring, isEmpty);

      final a = DailyAllowanceService.compute(
        monthTransactions: mes,
        recurring: recurring,
        now: now,
      );
      final inicio = DashboardController().calculateIncome(mes);
      expect(a.base, inicio);
      expect(a.base, 1500.10);
      expect(a.pendingFixedExpenses, 0);
    });
  });
}
