# Sistema de diseño de $imple

> Chat 07, 2026-10-05. **✅ Aprobado por Miguel (D-032): reglas y tabla de íconos tal cual, margen 24.**
> **✅ Aplicado en el chat 08 (D-033).** La sección "Cómo está hoy" describe el punto de partida; hoy las pantallas usan los módulos y los tests de reglas están prendidos.
> Parte de la skill `diseno-simple` y de lo que el código tiene hoy (`lib/core/ui/`).
> Completa la auditoría anterior (`docs/AUDITORIA-DISENO.md`) y las decisiones D-029, D-030 y D-031.

## La idea en una frase

**Cada cosa que se ve se dibuja en un solo lugar (un "módulo").** Las pantallas solo eligen qué módulos poner y dónde. Si se cambia el módulo, cambia en todas las pantallas a la vez. Nadie copia un botón, una pill o un ícono en una pantalla.

Ejemplo: el botón redondo `+` hoy está escrito 4 veces (inicio, Deudas, Metas y el botón de menú). Con un módulo `AppRoundButton`, cambiar su borde es tocar un archivo y se ve igual en las 4.

## Cómo está hoy

| Qué | Cuánto | Qué significa |
|---|---|---|
| Íconos elegidos en cada pantalla (`Icons.…`) | 117 | Cada pantalla elige su ícono: el mismo concepto tiene íconos distintos (ver tabla de íconos) |
| Decoraciones hechas a mano en pantallas (`BoxDecoration`) | 49 (17 en Deudas) | Cajas, botones y barras dibujados en la pantalla en vez de un módulo |
| Tamaños de letra escritos a mano | 52 | Ya hay estilos con nombre, pero se pisan con números |
| Espacios con números | 147 | Márgenes distintos entre pantallas |
| Radios con números | 34 | |
| Tamaños de ícono distintos | 17 (de 10 a 80) | No hay escala de tamaños |
| Colores sueltos | 1 (`Colors.white10` en Metas) | Casi resuelto (D-029) |

### Cosas que hoy están copiadas (el mismo elemento, varias versiones)

| Elemento | Versiones | Dónde |
|---|---|---|
| Logo `$imple` | 2 | Inicio (24) y menú (28), cada uno arma el brillo dorado por su cuenta |
| Botón redondo 56×56 (`+`, `−`, menú) | 4 | `AppFAB` (privado), `+` de Deudas, `+` de Metas, botón de menú (borde y brillo distintos) |
| Botón chico de acción (editar, borrar, pagar) | 2 copias exactas | Deudas y Metas (radio 8 en una, 12 en la otra) |
| Ícono dentro de una caja | 3 | Movimientos (36, cuadrada), Deudas (44, cuadrada), Pagos fijos (círculo) |
| Título de sección | 5 | Ajustes (violeta), Agregar movimiento, inicio, Deudas, Movimientos (gris, con tamaños y espaciados distintos) |
| Estado vacío ("no hay nada") | 5 | Deudas (círculo + ícono + botón), Pagos fijos (ícono gris), Metas, Estadísticas y Movimientos (solo texto) |
| Barra de progreso | 4 | Deudas (alto 8), Metas (alto 12), Estadísticas y "Podés gastar hoy" (las de Material) |
| Panel de abajo | 10 | Radios 24, 30 y 32; la "rayita" para arrastrar copiada 5 veces |
| Diálogo | 5 | 4 con el aspecto de Material por defecto, 1 (Deudas) con estilo propio |
| Campo de texto | 4 | `GlassInput`, el de Deudas, el de Metas y el monto grande de Agregar |
| Selector de dos opciones | 2 | Día/Mes (inicio) e Ingreso/Gasto (Agregar) |
| Fila de lista | 4 | Movimiento, pago fijo, deuda y fila de Ajustes |
| Monto dentro de una lista | 4 | Movimientos (15), Deudas (16), Pagos fijos (14), Estadísticas (15) |
| Beneficios Pro | 2 | Pantalla Pro (con ícono por beneficio) y aviso Pro (con tilde dorado) |
| Margen a los costados de la pantalla | 2 | 24 en casi todas; **16 en Ajustes** (Deudas ya volvió a 24). Decidido: 24 en todas (D-032) |

### Módulos que existen pero nadie usa

`AppCard`, `NeonShadow`, `AppShadows` (solo lo usa `AppCard`), `AppTheme.lightTheme` y `AppTheme.glassDecoration`. Confunden: parecen parte del sistema y no lo son.

## Las reglas (aprobadas, D-032)

- **R-1 · Una cosa, un módulo.** Todo lo que aparece en más de una pantalla vive en un solo archivo de `lib/core/ui/`. Las pantallas lo usan, no lo copian.
- **R-2 · Se cambia el módulo, nunca la pantalla.** Un retoque de diseño se hace en el módulo. Si una pantalla necesita algo distinto, se agrega una **variante con nombre** al módulo (por ejemplo `AppRoundButton.small`). Nunca una copia con un cambio.
- **R-3 · Un concepto, un ícono.** Los íconos salen de un catálogo, `AppIcons`, con nombres de concepto (`AppIcons.edit`, `AppIcons.debts`, `AppIcons.vault`). Las categorías siguen en `CategoryIcons`. Ninguna pantalla escribe `Icons.…`. Un ícono de categoría no se usa para una acción (hoy "Salario" y "pagar deuda" usan el mismo).
- **R-4 · Tamaño fijo** (D-030). Un módulo mide lo mismo en todas las pantallas y con cualquier contenido.
- **R-5 · Nada de números sueltos en pantallas.** Colores, radios, letras, tamaños de ícono y espacios salen de los tokens (`AppColors`, `AppRadius`, `AppTextStyles`, `AppIconSize`, `AppSpacing`).
- **R-6 · Lo de Material se configura una vez.** Diálogos, switches, barras, divisores, botones de texto y paneles de abajo se arreglan en `AppTheme` y valen para toda la app.
- **R-7 · Los tests vigilan las reglas.** Como ya pasa con los colores (D-029) y las flechas (D-031): un test falla si una pantalla escribe un ícono, un radio, un tamaño de letra o un color a mano.
- **R-8 · Sin flechas de subida o bajada** (D-031) y **dorado solo para Pro** (skill).

## Los módulos (catálogo propuesto)

Todos en `lib/core/ui/`. ✅ = ya existe y se usa.

| Módulo | Qué es | Reemplaza |
|---|---|---|
| Tokens ✅ `AppColors`, `AppRadius`, `AppTextStyles`, `AppGradients`, `AppSpacing` | Colores, radios, letras, degradados, espacios | — |
| **`AppSpacing.screen`** (nuevo) | Margen a los costados de toda pantalla | Los 16/20/24 de cada pantalla |
| **`AppIconSize`** (nuevo) | Escala de íconos: chico 16 · normal 20 · grande 24 · botón 28 · vacío 64 | Los 17 tamaños de hoy |
| **`AppIcons`** (nuevo) | Catálogo de íconos por concepto | Los 117 `Icons.…` de las pantallas |
| ✅ `CategoryIcons` | Ícono de cada categoría (P-10) | — |
| **`AppLogo`** (nuevo) | `$imple`, dorado si es Pro (lo decide solo) | Las 2 copias |
| ✅ `GlassCard` | Tarjeta de vidrio | — |
| ✅ `BalanceCard`, `IncomeExpenseCards` | Tarjetas del inicio (D-030) | — |
| ✅ `AppPill` | Pill (D-029) | — |
| **`AppSegmented`** (nuevo) | Selector de dos o más opciones | Día/Mes e Ingreso/Gasto |
| ✅ `GradientButton` | Botón principal (D-029) | `AppButton` queda como atajo |
| **`AppSecondaryButton`** (nuevo) | Botón con borde, sin relleno | "Restaurar backup", "Agregar primera deuda", botones de texto de los diálogos |
| **`AppRoundButton`** (nuevo) | Botón redondo 56×56 | `+`/`−` del inicio, `+` de Deudas y Metas, botón de menú |
| **`AppActionButton`** (nuevo) | Botón chico 38×38 de editar, borrar, pagar | Las 2 copias de Deudas y Metas |
| **`AppIconBox`** (nuevo) | Ícono dentro de una caja de color | Las 3 versiones |
| **`AppSectionTitle`** (nuevo) | Título de sección en MAYÚSCULAS | Las 5 versiones |
| **`AppListRow`** (nuevo) | Fila: caja de ícono, título, subtítulo, monto | Movimiento, pago fijo, deuda (Ajustes usa una variante sin monto) |
| **`AppAmount`** (nuevo) | Monto con su tamaño fijo según dónde va: balance, tarjeta, lista, destacado | Los montos de cada pantalla |
| **`AppProgressBar`** (nuevo) | Barra de progreso | Las 4 versiones |
| **`AppEmptyState`** (nuevo) | "No hay nada": ícono, texto y botón opcional | Las 5 versiones |
| **`AppSheet`** (nuevo) | Panel de abajo con su rayita | Los 10 paneles |
| **`AppInput`** (el `GlassInput` de hoy) | Campo de texto | Los 4 campos |
| ✅ `ProBadge` | Etiqueta PRO | — |
| **`ProBenefitList`** (nuevo) | Los 4 beneficios Pro | Las 2 versiones (pantalla Pro y aviso) |
| `AppTheme` | Diálogos, switches, barras, divisores, avisos | Estilos sueltos en cada pantalla |

## Íconos: un concepto, un ícono

Propuesta: todos en la versión **redondeada y llena** (`…_rounded`), que es la que más usa la app.

| Concepto | Hoy | Propuesta |
|---|---|---|
| Inicio | `dashboard_rounded` | igual |
| Movimientos | `swap_vert_rounded` | igual |
| Deudas | `account_balance_rounded` (y en Deudas cambia a tarjeta o banco según el **nombre** de la deuda: si dice "bbva") | `account_balance_rounded` siempre |
| Pagos fijos | `autorenew_rounded` | igual |
| Cuotas | `credit_card_rounded` (el mismo que la categoría Tarjeta) | igual (es lo mismo: compra con tarjeta) |
| Ajustes | `settings_rounded` | igual |
| Estadísticas | `analytics_rounded` | igual |
| Metas | `flag_rounded` (menú) · `savings_rounded` (pantalla Pro) | `savings_rounded` |
| Bóveda | `lock_rounded` · `lock_outline_rounded` (Ajustes) | `lock_rounded` |
| PIN | `password_rounded` (Ajustes) · `lock_outline` (pantalla PIN) | `pin_rounded` |
| Huella | `fingerprint_rounded` · `fingerprint` | `fingerprint_rounded` |
| Pro | `workspace_premium_rounded` · `workspace_premium` · `stars_rounded` | `workspace_premium_rounded` |
| Tips de salida | `psychology_rounded` (un cerebro: parece "IA", y la regla dice no presentar nada como IA) | `lightbulb_outline_rounded` (el mismo de los consejos) |
| Avalancha | `bolt_rounded` (tarjeta) · `flash_on_rounded` (etiqueta "prioridad") | `landslide_rounded` (una avalancha) |
| Bola de nieve | `ac_unit_rounded` | igual |
| Carga rápida | `flash_on_rounded` (el mismo rayo que Avalancha) | `flash_on_rounded` (queda solo para esto) |
| Agregar / ingreso | `add_rounded` | igual |
| Gasto | `remove_rounded` | igual |
| Editar | `edit_rounded` · `edit_outlined` | `edit_rounded` |
| Borrar | `delete_rounded` · `delete_outline_rounded` | `delete_outline_rounded` |
| Pagar / poner plata | `payments_rounded` (el mismo que la categoría Salario) | `paid_rounded` |
| Cerrar | `close` · `close_rounded` | `close_rounded` |
| Listo / OK | `check_circle` · `check_circle_rounded` | `check_circle_rounded` |
| Elegir otra fecha | `calendar_month_rounded` (el mismo que "Mes") | `edit_calendar_rounded` |
| Día / Mes | `calendar_today_rounded` / `calendar_month_rounded` | igual |
| Respaldo | `file_present_rounded` (Ajustes) · `cloud_sync` (pantalla) | `backup_rounded` |
| Exportar / importar | `upload` / `download` | `upload_rounded` / `download_rounded` |
| Privacidad | `shield_outlined` · `security` | `shield_rounded` |
| Ver más | `chevron_right_rounded` | igual |
| Información / aviso | `info_outline_rounded` / `warning_amber_rounded` | igual |

## Cómo se vigila

Tests nuevos, como el de colores, que fallan si en `lib/features/` aparece:
1. `Icons.` (tiene que salir de `AppIcons` o `CategoryIcons`);
2. `fontSize:` con número o `TextStyle(`;
3. `BorderRadius.circular(` con número;
4. `BoxDecoration(` (con una lista corta de excepciones que se vaya achicando).

Se prenden de a uno, a medida que cada pantalla queda limpia, para que nunca vuelva a romperse lo que ya se arregló.

## Plan por pasos

1. **Reglas y catálogo de íconos:** `AppIcons`, `AppIconSize`, `AppSpacing.screen`. Cambiar todos los `Icons.…` de las pantallas. Test de íconos.
2. **Módulos chicos:** `AppLogo`, `AppRoundButton`, `AppActionButton`, `AppIconBox`, `AppSectionTitle`, `AppEmptyState`, `AppProgressBar`, `AppSheet`, `AppSegmented`, `AppSecondaryButton`.
3. **`AppTheme`:** diálogos, switches, barras, divisores, botones de texto.
4. **Filas y montos:** `AppListRow`, `AppAmount`.
5. **Pantalla por pantalla:** reemplazar copias por módulos, con captura antes y después. Orden: inicio → Agregar → Movimientos → Pagos fijos → Deudas → Ajustes → Metas → Estadísticas → Pro.
6. **Borrar lo que sobra:** `AppCard`, `NeonShadow`, `lightTheme`, `glassDecoration`.
7. **Catálogo visual** (opcional): una pantalla escondida, solo en modo desarrollo, que muestra todos los módulos juntos para ver un cambio de un vistazo.
8. **Actualizar la skill `diseno-simple`** con estas reglas.

Cada paso deja `flutter analyze` y `flutter test` en verde y se sube aparte.
