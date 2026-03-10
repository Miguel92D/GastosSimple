# Reglas de Oro del Proyecto $imple

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
1. **Sección General**: Transacciones, Estadísticas, Deudas, Configuraciones.
2. **Sección PRO** (Solo si `isPro` es true): Inteligencia AI, Bóveda Segura.
*Nota: No añadir más elementos sin aprobación explícita.*

## 3. Estado PRO (Premium)
- El estado Premium se maneja de forma centralizada por `AppState.instance.isPro`, `AppModeController.instance.isPro` y `PremiumService.isPro`.
- **Regla de Desarrollo**: Por ahora, el modo Pro está forzado a `true` en el código para pruebas de diseño.

## 4. Estabilidad del Código
- **Null Safety**: Siempre usar chequeos de nulidad en controladores (`controller?`, `if (mounted)`).
- **Navegación**: Utilizar únicamente `GeneralFlowService` o `TransactionFlowService` para saltar entre pantallas principales.

## 5. Salida de Deudas
- La pantalla de deudas debe mantener siempre la sección superior de "Tips de Salida" (Avalancha, Bola de Nieve) para usuarios Pro.

## 6. Bóveda Segura (Privacidad PRO)
- **Aislamiento de Datos**: Los movimientos realizados dentro de la Bóveda Segura (`isSecret: 1`) **NUNCA** deben mostrarse en el historial normal ni en el balance del Dashboard principal.
- **Contexto del FAB**: El botón de agregar (`AppFAB`) en la Bóveda Segura debe pasar obligatoriamente el parámetro `isVault: true` al servicio de flujo para que el registro se guarde como privado.
- **Navegación Post-Guardado**: Tras guardar un movimiento secreto, el flujo debe retornar obligatoriamente a la `VaultScreen` y no al Dashboard normal para mantener el contexto de privacidad del usuario.
- **Controladores de Dashboard**: El `DashboardWidget` y el `DashboardController` deben filtrar estrictamente por el flag `isVault` para separar los saldos y las listas de movimientos.

## 7. Mecanismos de Protección (Arquitectura Antigravedad)
- **Smoke Tests**: Antes de dar por finalizada una gran actualización, se debe verificar que `test/smoke_test.dart` siga pasando para asegurar que la app inicia correctamente y muestra los elementos Premium.
- **Error Guards**: Toda la app corre bajo `ErrorGuard` en `main.dart` para evitar cierres inesperados (hard crashes) y mostrar una pantalla de recuperación amigable.

## 8. Mantenimiento y Evolución
- **Commits**: Mantener la disciplina de commits atómicos y descriptivos.
- **Consultar este manual**: El manual debe ser leído al inicio de cada nueva sesión de desarrollo para evitar regresiones visuales o funcionales.
