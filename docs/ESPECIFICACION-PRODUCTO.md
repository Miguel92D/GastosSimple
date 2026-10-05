# Especificación del producto — $imple

> Qué es la app, qué hace y qué reglas no se pueden romper.
> Este documento **absorbe `PROYECTO_REGLAS.md`** (sección 6 en adelante).
> Prioridad si algo se contradice: `DECISIONES-TECNICAS.md` > respuestas en `PENDIENTES-A-DEFINIR.md` > **este documento** > `PROYECTO_REGLAS.md`.

Última revisión: 2026-10-04 (chat 00).

---

## 1. Qué es $imple

Una app para anotar gastos e ingresos **rápido**, ver cuánto podés gastar hoy y ordenar deudas y pagos fijos.
Todo queda **en el teléfono** (no hay cuenta ni servidor). Idiomas: español e inglés.

- Nombre público: **$imple**. Nombres técnicos que **no se cambian**: paquete `gastos_simple`, app id `com.migueld.gastossimple`, producto Pro `simple_pro_lifetime` (ver D-003).
- Publicada en Google Play. Última versión publicada: **1.1.8 (14)**.

## 2. Para quién

Personas que quieren controlar su plata sin planillas ni apps complicadas. Abrir, anotar, cerrar.

## 3. Gratis y Pro

- **Gratis**: carga rápida, inicio con "Podés gastar hoy", movimientos, pagos fijos y cuotas, deudas, respaldo, PIN.
- **Pro** (pago único de por vida, `simple_pro_lifetime`): Estadísticas, Metas de ahorro, Bóveda Segura y Tips de salida en Deudas (P-05).
- El estado Pro vive en `AppState.isPro` (se guarda en `SharedPreferences` con la clave `is_pro`) y lo activa `PurchaseService` después de comprar o restaurar en Google Play. **Nunca** se fuerza a `true` en el código. Para probar: `SharedPreferences.setMockInitialValues({'is_pro': true})` o `AppState.instance.setPro(true)`.

## 4. Pantallas del MVP

> ✅ **Aprobado el 2026-10-04 (P-02).** Esta es la lista oficial del MVP.

| Pantalla | Archivo | Estado propuesto |
|---|---|---|
| Consentimiento (primera vez) | `settings/screens/consent_screen.dart` | Queda |
| PIN / desbloqueo | `settings/screens/pin_screen.dart` | Queda |
| Carga rápida (pantalla de inicio) | `transactions/screens/quick_entry_screen.dart` | Queda |
| Agregar / editar movimiento | `transactions/screens/add_transaction_screen.dart` | Queda |
| Inicio (dashboard) | `dashboard/screens/home_screen.dart` | Queda |
| Movimientos | `transactions/screens/movements_screen.dart` | Queda |
| Pagos fijos y cuotas | `transactions/screens/recurring_screen.dart` | Queda |
| Deudas | `debts/screens/debt_screen.dart` | Queda |
| Configuración | `settings/screens/settings_screen.dart` | Queda |
| Respaldo | `settings/screens/backup_screen.dart` | Queda |
| Política de privacidad | `settings/screens/privacy_policy_screen.dart` | Queda |
| Pro (compra) | `settings/screens/premium_screen.dart` | Queda |
| Estadísticas (Pro) | `analysis/screens/stats_screen.dart` | Queda |
| Bóveda Segura (Pro) | `vault/screens/vault_screen.dart` | Queda |
| Metas de ahorro (Pro) | `goals/screens/savings_goals_screen.dart` | Queda |
| Proyección del mes (Pro) | `analysis/screens/prediction_screen.dart` | Se oculta |
| Análisis mensual (Pro) | `analysis/screens/monthly_analysis_screen.dart` | Se oculta |
| Presupuestos | `budgets/screens/budget_screen.dart` | Se borra |
| Categorías | `transactions/screens/categories_screen.dart` | Se borra |
| Bloqueo PIN viejo | `settings/screens/pin_lock_screen.dart` | Se borra |

"Se oculta" = el código queda, pero no hay botón ni entrada en el menú.
"Se borra" = se elimina el archivo (las tablas de la base de datos **no** se tocan).

## 5. Menú lateral (drawer)

Minimalista. No se agregan entradas sin aprobación.

- **General**: Inicio, Movimientos, Deudas, Pagos fijos, Configuración.
- **Pro** (solo si `isPro`): Estadísticas, Metas de ahorro, Bóveda Segura.
- No se presenta nada como "IA" si no usa un modelo de verdad. La proyección es estadística (`MonthlyProjectionService`).

## 6. Identidad visual

- El logo `$imple` usa `GoldShimmerText` con brillo dorado (`#D4AF37`) cuando Pro está activo. El dorado se usa **solo** para cosas Pro.
- Encabezado del menú: ícono de billetera en `GlassCard`, logo `$imple`, texto "CONTROL FINANCIERO" en mayúsculas, y estado "CUENTA PREMIUM" (verde) o "CUENTA GRATIS".
- Colores, textos y tamaños: siempre con los tokens del sistema de diseño (skill `diseno-simple`). Nada de colores sueltos de Material.

## 7. Bóveda Segura (privacidad Pro)

1. Los movimientos de la Bóveda (`is_secret = 1`) **NUNCA** aparecen en el historial normal ni en el saldo del inicio.
2. El botón de agregar dentro de la Bóveda pasa siempre `isVault: true`.
3. Después de guardar un movimiento secreto se vuelve a la Bóveda, no al inicio.
4. Los pagos fijos heredan el `is_secret` del movimiento original; `processRecurringTransactions` lo respeta y nunca fuerza `0`.
5. El respaldo solo incluye la Bóveda si el usuario lo confirma (el archivo no está cifrado).
6. `DashboardWidget` y `DashboardController` filtran siempre por `isVault`.
7. Al editar un movimiento se conserva su `isSecret` (ya hubo una fuga por esto, corregida 2026-06-10).

## 8. Datos y respaldo

- **Restaurar nunca pisa datos**: se usa `DatabaseHelper.restoreBackupData` (todo o nada, mezcla con `BackupMerge`). Prohibido `ConflictAlgorithm.replace` por id con datos de un archivo externo.
- **Fechas de pagos fijos**: siempre `RecurrenceSchedule` (respeta el día elegido y fin de mes). Nunca `DateTime(y, m + 1, d)`.
- **Cuotas**: una compra en cuotas es un pago fijo mensual con `installments_total` / `installments_paid` (`InstallmentPlan`). Nunca se crean movimientos con fecha futura; las cuotas las genera `processRecurringTransactions` y la fila se borra al registrar la última. El plan arranca con `installments_paid = 0` y `next_date` = fecha de compra o vencimiento de la tarjeta (`CardSchedule`). La última cuota usa `installments_total_amount` para absorber el redondeo.
- **Dinero**: ver D-005.
- **Migraciones**: ver D-004.
- **Almacenamiento seguro**: fuera del backup de Android (`res/xml/backup_rules.xml`, `data_extraction_rules.xml`). `SecurityService` termina de iniciar aunque la lectura falle.

## 9. Privacidad y seguridad

- Crashlytics arranca **apagado** y solo se activa con el consentimiento (`AppState.setConsent`).
- PIN y huella opcionales. Pantalla protegida contra capturas (`FLAG_SECURE`) y bloqueo tras varios PIN fallidos.

## 10. Estabilidad

- Null safety siempre (`controller?`, `if (mounted)`).
- Navegación entre pantallas principales **solo** con `GeneralFlowService` o `TransactionFlowService`.
- Toda la app corre dentro de `ErrorGuard` (`main.dart`) para mostrar una pantalla amable en vez de cerrarse.
- `test/smoke_test.dart` tiene que pasar antes de dar por terminada cualquier tarea grande.

## 11. Deudas

La pantalla de deudas mantiene arriba los "Tips de salida" (Avalancha y Bola de nieve) para usuarios Pro.

## 12. Landing pública

Vive por triplicado: `docs/` (la que sirve GitHub Pages), `github_pages_root/` y `SimpleLanding/`. Si se cambia una, se cambian las tres.
