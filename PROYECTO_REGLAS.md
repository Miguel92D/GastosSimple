# Reglas de Oro del Proyecto $imple

> **Histórico (2026-10-04).** Todo este contenido fue absorbido por `docs/ESPECIFICACION-PRODUCTO.md`.
> Si algo de acá contradice a `docs/DECISIONES-TECNICAS.md`, `docs/PENDIENTES-A-DEFINIR.md` o la Especificación, gana el otro documento (D-001).

Este documento actúa como la fuente de verdad para el desarrollo asistido por IA, asegurando que las funciones críticas y el diseño premium no se pierdan en futuras iteraciones.

## 1. Identidad Visual Premium
- **Logotipo y Título**: El nombre `$imple` debe usar siempre el widget `GoldShimmerText` con el efecto de brillo animado (`#D4AF37`) cuando el modo Pro esté activo.
- **Header del Menu**: Debe incluir siempre:
    1. Icono de billetera en GlassCard.
    2. Logo dorado `$imple`.
    3. Texto "CONTROL FINANCIERO" en mayúsculas sub-etiquetado.
    4. Estado de cuenta: "CUENTA PREMIUM" (verde) o "CUENTA GRATIS" (gris).

## 2. Configuración de Menú Lateral (Drawer)
El menú debe mantenerse minimalista y contener estrictamente:
1. **Sección General**: Transacciones, Estadísticas, Deudas, Pagos fijos, Configuraciones.
2. **Sección PRO** (Solo si `isPro` es true): Proyección del mes, Bóveda Segura.
   - No presentar funciones como "IA" o "Inteligencia Artificial" salvo que realmente usen un modelo. La proyección es estadística (`MonthlyProjectionService`).
*Nota: No añadir más elementos sin aprobación explícita.*

## 3. Estado PRO (Premium)
- El estado Premium se maneja de forma centralizada por `AppState.instance.isPro`, `AppModeController.instance.isPro` y `PremiumService.isPro`.
- **Fuente real**: `AppState.isPro` se carga de `SharedPreferences` (`is_pro`) y lo activa `PurchaseService` tras una compra/restauración de Google Play. **No** está forzado a `true` en el código; para pruebas usar `SharedPreferences.setMockInitialValues({'is_pro': true})` o `AppState.instance.setPro(true)`.

## 4. Estabilidad del Código
- **Null Safety**: Siempre usar chequeos de nulidad en controladores (`controller?`, `if (mounted)`).
- **Navegación**: Utilizar únicamente `GeneralFlowService` o `TransactionFlowService` para saltar entre pantallas principales.

## 5. Salida de Deudas
- La pantalla de deudas debe mantener siempre la sección superior de "Tips de Salida" (Avalancha, Bola de Nieve) para usuarios Pro.

## 6. Bóveda Segura (Privacidad PRO)
- **Aislamiento de Datos**: Los movimientos realizados dentro de la Bóveda Segura (`isSecret: 1`) **NUNCA** deben mostrarse en el historial normal ni en el balance del Dashboard principal.
- **Contexto del FAB**: El botón de agregar (`AppFAB`) en la Bóveda Segura debe pasar obligatoriamente el parámetro `isVault: true` al servicio de flujo para que el registro se guarde como privado.
- **Navegación Post-Guardado**: Tras guardar un movimiento secreto, el flujo debe retornar obligatoriamente a la `VaultScreen` y no al Dashboard normal para mantener el contexto de privacidad del usuario.
- **Recurrencias**: `recurring_transactions.is_secret` hereda el flag del movimiento original; `processRecurringTransactions` debe usarlo, nunca forzar `0`.
- **Backup**: la Bóveda solo se exporta si el usuario lo confirma (el JSON no está cifrado).
- **Controladores de Dashboard**: El `DashboardWidget` y el `DashboardController` deben filtrar estrictamente por el flag `isVault` para separar los saldos y las listas de movimientos.

## 7. Mecanismos de Protección (Arquitectura Antigravedad)
- **Smoke Tests**: Antes de dar por finalizada una gran actualización, se debe verificar que `test/smoke_test.dart` siga pasando para asegurar que la app inicia correctamente y muestra los elementos Premium.
- **Error Guards**: Toda la app corre bajo `ErrorGuard` en `main.dart` para evitar cierres inesperados (hard crashes) y mostrar una pantalla de recuperación amigable.

## 8. Datos y Respaldo
- **Restaurar nunca pisa datos**: usar `DatabaseHelper.restoreBackupData` (atómico, merge por `BackupMerge`). Prohibido `ConflictAlgorithm.replace` por id con datos de un archivo externo.
- **Fechas recurrentes**: usar siempre `RecurrenceSchedule` (respeta el día ancla y fin de mes). No sumar meses con `DateTime(y, m + 1, d)`.
- **Cuotas**: una compra en cuotas es una recurrencia mensual con `installments_total`/`installments_paid` (`InstallmentPlan`). Nunca crear movimientos con fecha futura; las cuotas las genera `processRecurringTransactions` y la fila se borra al registrar la última. El plan se crea con `installments_paid = 0` y `next_date` = fecha de compra o vencimiento de la tarjeta (`CardSchedule`); la última cuota usa `installments_total_amount` para absorber el redondeo.
- **Dinero**: los montos siguen en REAL, pero toda escritura pasa por `Money.round` (centavos), toda suma acumula con `Money.round` o `Money.sum`, y las comparaciones contra cero usan `Money.isZero`/`toCents`. No comparar montos con `==` ni con porcentajes (`progress >= 0.999`).
- **Migraciones**: cada `ALTER TABLE` en su propio try (`_tryExecute`); subir `version` en `_initDB` y agregar la columna también en `_createDB`.
- **Almacenamiento seguro**: excluido del backup de Android (`res/xml/backup_rules.xml`, `data_extraction_rules.xml`). `SecurityService` debe completar su init aunque la lectura falle.
- **Privacidad**: Crashlytics arranca apagado (meta-data en el Manifest) y solo se activa con el consentimiento (`AppState.setConsent`).

## 9. Mantenimiento y Evolución
- **Git**: no usar `git reset --hard`, `git clean` ni `git checkout` de otra rama con cambios sin commit. El 2 oct 2026 eso borró un día de trabajo; commitear (o `git stash -u`) antes de cambiar de rama.
- **Commits**: Mantener la disciplina de commits atómicos y descriptivos.
- **Consultar este manual**: El manual debe ser leído al inicio de cada nueva sesión de desarrollo para evitar regresiones visuales o funcionales.
