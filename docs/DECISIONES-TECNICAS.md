# Decisiones técnicas — $imple

> Cosas ya decididas. **Este documento manda sobre todos los demás.**
> Una decisión solo se cambia con una nueva entrada (D-0xx) que diga cuál reemplaza.

Última revisión: 2026-10-05 (chat 06).

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
**Hecho en el chat 06:** los dos archivos dicen `1.1.9+15` (D-025).

### D-007 — Navegación
Solo `GeneralFlowService` y `TransactionFlowService` para ir entre pantallas principales. Rutas en `lib/core/router/app_router.dart`.

### D-008 — Idiomas
Sistema propio `AppTranslations` (`lib/core/i18n/`), español e inglés. **No** se usa el `gen-l10n` de Flutter. Todo texto nuevo va en las dos lenguas.

### D-009 — Estado y dependencias
`provider` para estado; `AppState` es la fuente del modo Pro. No se agregan paquetes nuevos sin anotarlo acá.

### D-010 — Calidad mínima para subir código
Antes de cada push: `flutter analyze` sin problemas y `flutter test` todo en verde. Al 2026-10-05 (chat 06): analyze limpio, 183 tests pasan.

### D-011 — Git seguro
Prohibido `git reset --hard`, `git clean` y cambiar de rama con cambios sin commit (el 2 oct 2026 eso borró trabajo, incluido el código exacto de la 1.1.8). Commits chicos y descriptivos. Rama de trabajo: `feature/mejoras-sesion`; desde el chat 06 `main` sigue a esa rama (D-026).

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

### D-017 — Google Play Billing 8 fijo
- Google Play **rechaza** versiones nuevas compiladas con Billing 7 desde el 31/08/2026 (con prórroga pedida, hasta el 1/11/2026). El `pubspec.lock` del repo había quedado en `in_app_purchase_android 0.4.0+8` = Billing **7.1.1**; la 1.1.8 publicada ya usaba Billing **8.0.0** (lo dice su crash).
- Ahora: `in_app_purchase: ^3.3.1` e `in_app_purchase_android: ^0.5.0` como dependencia **directa** (antes venía de rebote). Así no puede volver a bajar a Billing 7 y además la app usa sus tipos (`GooglePlayPurchaseDetails`) para no activar Pro con compras sin pagar (D-018). Comprobado: el APK lleva `billingclient.version = 8.0.0`.
- Si se sube a una versión mayor del paquete, revisar su CHANGELOG (la 0.5.0 sacó `queryPurchaseHistory`, que la app no usa).

### D-018 — Cómo se activa Pro
- Pro se activa **solo** en `PurchaseService._deliverProduct`, con una compra de `simple_pro_lifetime` **pagada**. Un test (`test/pro_purchase_test.dart`) falla si otro archivo de `lib/` pone Pro en `true`. Se borraron `ProService.activatePro/deactivatePro` y `PremiumService.setPremium`, que no usaba nadie.
- Google Play devuelve al restaurar **todas** las compras de la cuenta con estado "restaurada", también las que esperan pago (efectivo, transferencia). `PurchaseService.isPaid` mira el estado real (`PurchaseStateWrapper.purchased`); si no está pagada queda "pendiente", no se activa Pro y no se confirma (`completePurchase`).
- `PurchaseService` habla con la tienda a través de `PurchaseStore`: en la app es Google Play; en los tests, una tienda falsa (`resetForTesting`, marcado `@visibleForTesting`).
- `restorePurchases()` espera la respuesta de Google Play (máximo `restoreTimeout` = 8 s) y devuelve si Pro quedó activo. Configuración usa ese resultado (antes esperaba 1,2 s a ciegas y leía el texto del mensaje).

### D-019 — Pantallas Pro cerradas en el router y Bóveda tapada
- `AppRouter.proRoutes` (`/stats`, `/goals`, `/prediction`, `/monthly_analysis`) y `/add` con `isVault` abren la pantalla Pro si no hay Pro, venga de donde venga la navegación (antes solo lo controlaba `ActionController`).
- `VaultLockGate` (`lib/features/vault/widgets/vault_lock_gate.dart`) envuelve la Bóveda y sus pagos fijos: sin Pro, o con PIN de Bóveda y la Bóveda cerrada, muestra un candado en vez de los movimientos. Arregla que, al volver de segundo plano, la app cerraba la Bóveda pero la pantalla seguía mostrando lo secreto.
- Los Tips de salida en Deudas (Avalancha / Bola de nieve) piden Pro al tocarlos (P-05). Antes eran gratis aunque la Especificación dice que son Pro.
- Lo que promete Pro está en un solo lugar: `PremiumFlowService.proBenefitKeys` (textos `pro_benefit_*`). La pantalla Pro muestra los mismos cuatro.

### D-020 — Restaurar un respaldo nunca duplica
- Además de lo que ya hacía `BackupMerge` (id libre → se inserta; mismo id y misma entidad → se reemplaza; mismo id y otra cosa → fila nueva), `restoreBackupData` **saltea** una fila si la misma entidad ya está en el teléfono con **otro** id. Antes, restaurar dos veces en un teléfono con datos propios duplicaba lo que la primera vez había entrado como fila nueva.
- Cada fila que ya estaba en el teléfono "absorbe" una sola fila del archivo: si el archivo trae dos movimientos iguales (mismo monto, categoría, tipo y fecha), llegan los dos.
- "Misma entidad" compara el tipo normalizado (`Gasto` = `gasto`, `Transaction.normalizeType`) y las fechas como fechas (`2026-09-01` = `2026-09-01T00:00:00.000`). Antes un tipo viejo escrito distinto se duplicaba al restaurar en el mismo teléfono.
- `BackupController.buildBackupJson` / `restoreBackupJson` arman y leen el contenido; `exportBackup` / `restoreBackup` solo escriben y leen el archivo. Tests: `test/backup_roundtrip_test.dart` (ida y vuelta con y sin Bóveda, dos veces, teléfono con datos propios, archivo roto, formato v1).

### D-021 — Actualizar desde la 1.1.8 está probado (P-01)
- `test/db_upgrade_test.dart` arma una base con el esquema exacto de las versiones **12, 13, 14, 15 y 16** (la 12 sale de git, commit `e1464ef`), con datos, y la abre con la app de hoy: no se pierde nada, los montos quedan a centavos y después se pueden usar cuotas y pagos fijos de la Bóveda. También prueba que las migraciones corren **dos veces** sin cambiar nada y que una base **17** (más nueva) se abre sin borrar nada.
- Al abrir la base (`onOpen`, en cada arranque) se arregla `is_secret` vacío (`NULL` → `0`) en movimientos y pagos fijos: con `NULL` no aparecían ni en la lista normal ni en la Bóveda. Es barato y se puede repetir. **No** cambia la versión de la base (sigue en 16).
- Toda la migración corre dentro de una transacción de sqflite; un `ALTER TABLE` que falla (columna que ya existe) se saltea sin deshacer el resto (`_tryExecute`).

### D-022 — La huella necesita un PIN
- `SecurityService.setBiometricActive(true)` no hace nada (devuelve `false`) si no hay PIN activo. En Configuración, prender la huella sin PIN primero pide crearlo. Apagar el PIN apaga también la huella.
- Motivo: sin PIN, si la huella deja de andar (sensor roto, huellas borradas) el usuario quedaba afuera de la app para siempre.
- Bloqueo tras PIN fallidos: 5 intentos libres, después 30 s, 60 s, 120 s… hasta 15 min; se guarda en el almacenamiento seguro (cerrar la app no lo saca) y lo comparten el PIN de la app y el de la Bóveda. `SecurityService.clock` (`@visibleForTesting`) permite probarlo sin esperar. El aviso muestra los segundos redondeados hacia arriba. Tests: `test/privacy_security_test.dart`.

### D-023 — Consentimiento de Crashlytics
- Crashlytics arranca apagado (`firebase_crashlytics_collection_enabled = false` en el AndroidManifest) y solo se prende si el usuario acepta en la pantalla de consentimiento.
- La respuesta se puede cambiar cuando se quiera en **Configuración → Legal → Enviar reportes de fallos** (`AppState.crashReportsEnabled`).
- Al apagarlo (o mientras no haya permiso) se borran los reportes guardados sin enviar (`deleteUnsentReports`): si no, Crashlytics los mandaría todos juntos al aceptar.
- `AppState.crashlyticsSwitch` (`@visibleForTesting`) se cambia en los tests por uno falso.

### D-024 — Una sola política de privacidad
- La pantalla de la app (`PrivacyPolicyScreen`) usa los textos `privacy_s1…s8_title/body` de `AppTranslations` (antes estaban escritos en el código, solo con `isSpanish`). Son **las mismas palabras** que `privacy.html` de la landing.
- Un test (`test/privacy_security_test.dart`) falla si las tres copias de la landing (`docs/`, `github_pages_root/`, `SimpleLanding/`) no son iguales o si la app y la web dicen cosas distintas.
- Al cambiar la política: cambiar las secciones en `AppTranslations` y en `docs/privacy.html` a la vez, y copiar el HTML a las otras dos carpetas.

### D-025 — Versión 1.1.9 (15) y test que la vigila
- `pubspec.yaml` dice `version: 1.1.9+15` y `android/app/build.gradle` dice `versionCode 15` / `versionName "1.1.9"`.
- `test/version_test.dart` falla si los dos archivos no dicen lo mismo o si el `versionCode` no es mayor que 14 (la 1.1.8 publicada). Al publicar una versión nueva, subir el número en los dos archivos y, si hace falta, el `_lastPublishedCode` del test.
- Tag `v1.1.9+15` en el commit `28fb0ed` (el que se compiló, D-012). AAB firmado con la llave de publicación (`CN=Simple App`), lleva Billing **8.0.0** (`billing.properties`), sha256 `b62e30a1…ef18eaa4`.

### D-026 — Cómo se unió `feature/mejoras-sesion` a `main` (P-07)
- `main` local tenía 2 commits de marzo 2026 ("dashboard ui update", `4041e57` y `07d5650`) que **nunca se subieron** a GitHub. Eran una versión vieja de lo que la rama de trabajo rehízo mejor (Crashlytics sin consentimiento, `group.example` en el widget) y traían 739 archivos de `android/app/build` y logs commiteados por error.
- No se mezclaron. Quedaron guardados en la rama **`archivo/main-marzo-2026`**, solo en esta compu (GitHub rechazó subirla, probablemente por los archivos de compilación pesados). No borrarla.
- `main` pasó a apuntar al mismo commit que `feature/mejoras-sesion` (en GitHub fue un avance directo, sin forzar: `origin/main` era el punto donde nació la rama).
- De acá en más: se trabaja en `feature/mejoras-sesion` y al publicar se adelanta `main` a ese commit.

