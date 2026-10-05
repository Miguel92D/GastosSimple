# Decisiones técnicas — $imple

> Cosas ya decididas. **Este documento manda sobre todos los demás.**
> Una decisión solo se cambia con una nueva entrada (D-0xx) que diga cuál reemplaza.

Última revisión: 2026-10-04 (chat 03).

---

### D-001 — Orden de prioridad de los documentos
Si dos documentos se contradicen, gana el primero de esta lista:
1. `docs/DECISIONES-TECNICAS.md`
2. Las respuestas ya dadas en `docs/PENDIENTES-A-DEFINIR.md`
3. `docs/ESPECIFICACION-PRODUCTO.md`
4. `PROYECTO_REGLAS.md` (histórico, absorbido por la Especificación)

### D-002 — Un chat por tarea
Cada tarea de la tabla de `CLAUDE.md` se hace en su propio chat. Un chat no empieza la tarea siguiente. Al terminar deja: "Tarea terminada", un resumen y el mensaje para abrir el chat siguiente.

### D-003 — Identificadores técnicos fijos
No se cambian: paquete Flutter `gastos_simple`, app id / namespace `com.migueld.gastossimple`, Firebase, producto de compra `simple_pro_lifetime`. El nombre público es `$imple`.

### D-004 — Base de datos local y migraciones
- SQLite con `sqflite`, archivo `simple_wallet.db`. **Versión actual: 16** (`lib/database/database_helper.dart`).
- Historia: 12 = cuotas en deudas · 13 = `is_secret` y `anchor_day` en pagos fijos · 14 = cuotas en pagos fijos · 15 = total del plan · 16 = montos redondeados a centavos.
- Cada paso de migración va en su propio `_tryExecute`, y tiene que poder correr **dos veces sin romper nada** (porque no sabemos con certeza qué versión tiene la 1.1.8 publicada, ver P-01).
- La versión **nunca baja**. Toda columna nueva se agrega también en `_createDB`.
- Nunca se borra la base de datos del usuario.

### D-005 — Dinero
Los montos se guardan como `REAL`, pero: toda escritura pasa por `Money.round` (centavos), toda suma usa `Money.round` o `Money.sum`, y las comparaciones contra cero usan `Money.isZero` / `toCents`. Prohibido comparar montos con `==` o con porcentajes (`progress >= 0.999`).

### D-006 — Números de versión para Play
Play ya tiene **1.1.8 (14)**. El repo dice `1.1.4+10` (`pubspec.yaml` y `android/app/build.gradle`). La próxima publicación tiene que ser **como mínimo 1.1.9 (15)**. Se corrige en el chat 06 (publicación), en los dos archivos a la vez.

### D-007 — Navegación
Solo `GeneralFlowService` y `TransactionFlowService` para ir entre pantallas principales. Rutas en `lib/core/router/app_router.dart`.

### D-008 — Idiomas
Sistema propio `AppTranslations` (`lib/core/i18n/`), español e inglés. **No** se usa el `gen-l10n` de Flutter. Todo texto nuevo va en las dos lenguas.

### D-009 — Estado y dependencias
`provider` para estado; `AppState` es la fuente del modo Pro. No se agregan paquetes nuevos sin anotarlo acá.

### D-010 — Calidad mínima para subir código
Antes de cada push: `flutter analyze` sin problemas y `flutter test` todo en verde. Al 2026-10-04 (chat 03): analyze limpio, 108 tests pasan.

### D-011 — Git seguro
Prohibido `git reset --hard`, `git clean` y cambiar de rama con cambios sin commit (el 2 oct 2026 eso borró trabajo, incluido el código exacto de la 1.1.8). Commits chicos y descriptivos. Rama de trabajo: `feature/mejoras-sesion`; `main` se actualiza en el chat 06.

### D-012 — Cada versión publicada queda marcada
Cuando se publica en Play se crea un tag `vX.Y.Z+N` en el commit exacto que se compiló. Así no vuelve a pasar lo de la 1.1.8 (no se sabe de qué código salió).

### D-013 — Pantallas ocultas
Proyección del mes y Análisis mensual quedan ocultas (Especificación, sección 4): conservan su archivo, su ruta (`/prediction`, `/monthly_analysis`) y su acción en `ActionController` / `GeneralFlowService`, pero ningún menú ni botón las abre. Para volver a mostrarlas alcanza con agregar la entrada en el menú.

### D-014 — Tests con base de datos real
Para probar los flujos del núcleo se agregó `sqflite_common_ffi` **solo en `dev_dependencies`** (no va dentro de la app). Los tests usan una base SQLite en memoria:
`sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; DatabaseHelper.pathOverride = inMemoryDatabasePath;` y `DatabaseHelper.resetForTesting()` antes de cada test.
`pathOverride` y `resetForTesting` están marcados `@visibleForTesting`: la app nunca los usa. Ejemplos: `test/transaction_flows_test.dart` y `test/transaction_screens_test.dart`.

### D-015 — Cambiar el monto de un plan de cuotas
Al cambiar el monto de la cuota en Pagos fijos, el total del plan pasa a ser **cuota nueva × total de cuotas** (`updateRecurringAmount`). Si quedaba el total viejo, la última cuota (que absorbe el redondeo) salía con cualquier monto, hasta negativo.

### D-016 — Una sola forma de sumar los números de las pantallas
Inicio, carga rápida, Movimientos, Estadísticas y "Podés gastar hoy" suman **con el mismo código en Dart** sobre la lista de movimientos de la sección (normal o Bóveda):
- Ingresos, gastos y saldo: `MonthlyFinanceService.calculateIncome / calculateExpenses / calculateBalance` (el saldo también se redondea a centavos).
- Corte de mes: `MonthlyFinanceService.filterTransactionsForMonth` (Estadísticas lo usa igual que el inicio).
- Por categoría y por mes: `StatsService`.
- El saldo de la carga rápida (`DashboardController.getBalance`) ya **no** usa el `SUM` de SQL: ese `SUM` no contaba tipos escritos distinto (por ejemplo `Gasto`) que el resto de la app sí cuenta como gasto.
- Un tipo que no es ingreso cuenta como gasto en todos lados (`Transaction.normalizeType`).
- Deudas: el total pendiente, el orden de Avalancha / Bola de nieve y la deuda prioritaria salen de `DebtMath` (`lib/features/debts/utils/debt_math.dart`). Una deuda pagada de más cuenta 0 (no descuenta de las otras) y "pagada" es siempre `Debt.isPaid` (centavos), nunca `progress >= 0.999`.
- "Podés gastar hoy": límite diario y "te queda hoy" a centavos; la última cuota pendiente usa su monto real (`InstallmentPlan.amountFor`).
Tests: `test/numbers_test.dart` (con base en memoria comprueba que las pantallas den lo mismo).
