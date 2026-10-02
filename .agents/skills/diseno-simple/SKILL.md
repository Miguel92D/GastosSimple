---
name: diseno-simple
description: Sistema de diseño de la app $imple (gastos_simple, Flutter, D:\mis apps\Simple) y su landing web. Usala siempre que se cree, retoque o revise cualquier pantalla, widget, color o estilo de Simple.
---

# Diseño $imple

Simple ya tiene un sistema de diseño en el código: `lib/core/ui/`. Esta skill no inventa estilo nuevo. Sirve para que cada retoque **respete ese sistema** y no agregue más inconsistencias. Los valores de abajo salen del código real (octubre 2026). Si el código cambia, el código manda y esta skill se actualiza.

Esta skill es solo para Simple. Su estética (violeta, glass, glow, dorado Pro) es distinta de `diseno-miguel`, que se usa en los demás proyectos. Dentro de Simple no apliques las reglas de `diseno-miguel`.

## Antes de tocar nada

1. Leé `PROYECTO_REGLAS.md` en la raíz. Tiene reglas de identidad que no se negocian (logo, drawer, Pro, Bóveda).
2. Mirá `lib/core/ui/` para ver qué componente existe. Reusar siempre antes que crear.
3. Si hace falta un color, radio o estilo que no existe, **agregalo al archivo de tokens** (`app_colors.dart`, `app_radius.dart`, etc.) y usalo desde ahí. Nunca un literal suelto en una pantalla.

## Carácter

Oscuro, premium, fintech "neón suave": fondo casi negro con un resplandor violeta arriba, tarjetas de vidrio translúcido con borde fino blanco, un violeta de marca, verde/rojo neón para ingresos/gastos y dorado metálico solo para lo Pro. Tipografía pesada (w700–w900) con tracking negativo en títulos y montos.

## Colores (`AppColors`)

| Token | Valor | Uso |
|---|---|---|
| `primaryPurple` | `#7B5CFF` | Marca, acción principal, ítem activo, íconos destacados |
| `primaryDeep` | `#6F4DFF` | Inicio del gradiente de marca |
| `primaryLight` | `#9A7BFF` | Fin del gradiente de marca, `secondary` del tema |
| `incomeGreen` | `#3DDC97` | Ingresos, saldo positivo, "CUENTA PREMIUM" |
| `expenseRed` | `#FF5C5C` | Gastos, saldo negativo, errores |
| `darkBackground` | `#0E0E11` | Fondo de toda la app |
| `surface` | `#16161C` | Superficie sólida (cards de Material, bottom sheets, diálogos) |
| `glassSurface` | `#FFFFFF` al 10% (`0x1AFFFFFF`) | Base de tarjetas planas (`AppCard`), pills inactivas |
| `cardBorder` | `#FFFFFF` al 20% (`0x33FFFFFF`) | Borde de 1px de tarjetas, inputs y pills |
| `shadowPurple` | `#7B5CFF` al 30% | Sombras/glow violeta |
| `textPrimary` | `#FFFFFF` | Títulos, montos |
| `softText` | `#BFBFD2` | Cuerpo, labels, subtítulos |
| `textMuted` | `#636366` | Texto deshabilitado o terciario |
| `gold` | `#D4AF37` | **Solo Pro**: logo, `ProBadge`, shimmer |
| `goldShine` | `#FFFACD` al 90% | **Solo Pro**: brillo del shimmer dorado |

Categorías (solo para identificar categorías y gráficos, nunca como acento de UI):

| Token | Valor |
|---|---|
| `orange` | `#FB923C` |
| `blue` | `#60A5FA` |
| `indigo` | `#818CF8` |
| `teal` | `#2DD4BF` |
| `pink` | `#FB7185` |
| `purple` | `#C084FC` |

`gold`, `goldShine`, `surface`, `primaryDeep` y `primaryLight` se agregaron a `AppColors` en octubre 2026, pero varios archivos todavía los tienen escritos a mano (`Color(0xFFD4AF37)` aparece 11 veces: `GoldShimmerText`, `ProBadge`, etc.; `Color(0xFF16161C)` en `AppTheme`; los extremos del gradiente en `AppGradients`). Cuando toques uno de esos archivos, reemplazá el literal por el token.

Tampoco se usan colores de Material (`Colors.deepPurple`, `Colors.orange`, `Colors.redAccent`, `Colors.green`, etc.). Si aparecen en el archivo que estás tocando, reemplazalos por el token equivalente. Los únicos `Colors.*` válidos son `Colors.white` con alfa, `Colors.black` con alfa para sombras, y `Colors.transparent`.

### Opacidades de blanco habituales

Texto secundario sobre tarjeta de color: `white` al 70%. Íconos secundarios: 50–60%. Fondo de pill sobre tarjeta de color: 15%. Hint de inputs: `softText` al 20%; label de inputs: `softText` al 40%.

## Gradientes (`AppGradients`)

- `primaryGradient`: `#6F4DFF → #9A7BFF`, arriba-izq a abajo-der. Botón principal y tarjeta de balance.
- `progressGradient`: verde → violeta, horizontal. Barras de progreso (metas, presupuestos).
- `glassGradient`: blanco 13% → 7%. Base de todo `GlassCard`.
- `softGlassGradient`: blanco 10% → 4%, vertical.
- `incomeGradient` / `expenseGradient`: verde/rojo 15% → 5%. Fondos de tarjetas de ingreso/gasto.
- `mainBackgroundRadial`: resplandor violeta (25% → 8% → fondo) centrado en `(0.4, -0.7)`. Fondo de todas las pantallas vía `AppScaffold`.

No crear gradientes nuevos en pantallas. Si hace falta uno, se agrega acá.

## Espaciado (`AppSpacing`)

`xs 4 · sm 8 · md 16 · lg 24 · xl 32 · xxl 48`. Margen lateral de pantalla: `md` (16). Padding interno de `GlassCard`: `lg` (24) por defecto. Separación antes del botón final de un formulario: `xxl`.

## Radios (`AppRadius`)

`sm 8 · md 16 · lg 24 · xl 30`. El código todavía tiene 14 radios distintos escritos a mano (2, 4, 6, 8, 10, 12, 16, 18, 20, 22, 24, 30, 32, 40), y por eso las cosas no se ven parejas. Regla por componente:

| Componente | Radio |
|---|---|
| `GlassCard`, tarjetas grandes, balance, inputs (`GlassInput`) | `xl` (30) |
| `AppCard`, botones principales (`GradientButton`) | `lg` (24) |
| Contenedor de toggle/segmentado, tiles de lista | `md` (16) |
| Opción dentro de un toggle, íconos en caja chica | `sm` (8) |
| Pills / chips | totalmente redonda (`AppPill`, `StadiumBorder`) |
| FAB y botón de menú (56×56) | 18. Es la excepción establecida; mantenerla |

Cuando toques un archivo con un radio fuera de esta tabla, pasalo al token que corresponda.

## Tipografía (`AppTextStyles`)

Fuente de la app: la del sistema (Roboto en Android); no hay fuente propia declarada. La landing web usa **Outfit**. Unificarlas está pendiente de decisión: no cambies la fuente de la app sin que Miguel lo pida.

| Estilo | Tamaño | Peso | Tracking | Color | Uso |
|---|---|---|---|---|---|
| `balanceAmount` | 40 | w900 | -1.0 | textPrimary | Monto principal (en `BalanceCard` va a 42) |
| `titleLarge` | 32 | w900 | -1.0 | textPrimary | Títulos grandes, logo (`AppScaffold` lo usa a 24) |
| `incomeValue` / `expenseValue` | 22 | w900 | -0.5 | verde / rojo | Montos de ingreso/gasto |
| `titleMain` | 20 | w800 | -0.5 | textPrimary | Títulos de sección |
| `cardTitle` | 16 | w700 | -0.2 | textPrimary | Títulos de tarjeta |
| `buttonLabel` | 16 | w700 | 0.5 | textPrimary | Texto de botones (en MAYÚSCULAS en los principales) |
| `bodyText` / `bodyMain` | 14 | w600 | 0 | softText | Cuerpo |
| `subLabel` | 12 | w700 | 1.0 | softText | Etiquetas en MAYÚSCULAS ("BALANCE MENSUAL", "CONTROL FINANCIERO") |
| `subtitle` / `bodySmall` | 12 | w500 | 0.5 | softText | Texto chico, fechas |

Se parte siempre de un estilo existente con `.copyWith(...)`. No crear `TextStyle(...)` desde cero en pantallas. Los tamaños 8, 9, 10, 11 y 13 que aparecen sueltos en el código solo se aceptan en badges (`ProBadge` 10), en la etiqueta de estado del drawer (11) y en las opciones de toggle (13).

## Sombras y glow

- `AppShadows.softShadow`: negro 26%, blur 20, offset (0, 8). Tarjetas planas.
- `AppShadows.glassShadow`: negro 38%, blur 30, offset (0, 10).
- Glow de `GlassCard` (`glowColor`): color al 12%, blur 30, spread 2. Violeta en balance y menú, verde/rojo en los FAB.
- `NeonShadow`: glow al 20%, blur 24. Solo para elementos destacados; no más de uno o dos por pantalla.

## Componentes (usar estos, no recrearlos)

- **`AppScaffold`**: estructura de toda pantalla. Fondo `darkBackground` + `mainBackgroundRadial`, AppBar transparente centrado (título `titleLarge` a 24), botón de menú glass 56×56 abajo a la izquierda y FAB abajo a la derecha.
- **`GlassCard`**: tarjeta principal. Blur 16, `glassGradient`, borde `cardBorder` de 1px, radio `xl`, padding `lg`.
- **`AppCard`**: tarjeta plana más liviana (sin blur), radio `lg`, padding 16. Con `isPro` cambia la sombra por un glow violeta al 10%.
- **`BalanceCard`**: gradiente de marca, ola animada, título en mayúsculas al 70%, monto 42/w900 que cambia a verde/rojo según signo, pill del mes abajo, botón de ojo para ocultar saldo.
- **`GradientButton`**: botón principal. `primaryGradient`, padding 24×16 (alto ≈ 52), radio `lg`, sombra del primer color al 30% blur 15 offset (0, 8), texto `buttonLabel` en mayúsculas, ancho completo en formularios.
- **`GlassInput`**: input dentro de `GlassCard`, radio 30, padding 16×8, texto `bodyMain` a 16, ícono 18 en `softText` al 60%, sin bordes de Material.
- **`AppPill`** (`core/ui/widgets/app_pill.dart`): pill oficial. Ver abajo.
- **`AppFAB`**: dos botones glass 56×56 radio 18 apilados con 16 de separación: `+` verde (ingreso) arriba y `−` rojo (gasto) abajo, borde 2px del color al 40%, ícono 28.
- **`GoldShimmerText`**: el nombre `$imple` con brillo dorado animado (4 s) cuando es Pro.
- **`ProBadge`**: "PRO" 10/w900 con borde blanco y shimmer dorado. Hay **dos** versiones (`core/ui/pro_badge.dart` y `core/ui/widgets/pro_badge.dart`); usar la de `widgets/` y no crear una tercera.
- **`AppButton`**: legado. Radio 12 y color libre, fuera del sistema. No usarlo en pantallas nuevas; preferir `GradientButton`.

### Pills y toggles (medidas fijas)

Toda pill o chip se hace con **`AppPill`**. No armar pills a mano con `Container` + `BorderRadius`.

```dart
AppPill(label: 'Octubre 2026', onColoredSurface: true)            // informativa sobre tarjeta de color
AppPill(label: 'Super', selected: cat == 'super', onTap: () => …)  // seleccionable
AppPill(label: 'Ingreso', selected: true, activeColor: AppColors.incomeGreen, onTap: …)
```

| Modo | Alto | Padding | Fondo | Texto |
|---|---|---|---|---|
| Informativa (`selected: null`) | 32 | 16 horizontal | `glassSurface` · blanco 15% con `onColoredSurface` | `subtitle` w700, softText · blanco sobre color |
| Activa (`selected: true`) | 32 | 16 horizontal | `activeColor` (default `primaryPurple`) | `subtitle` w700, textPrimary |
| Inactiva (`selected: false`) | 32 | 16 horizontal | `glassSurface` + borde `cardBorder` | `subtitle` w700, softText |

Con `onTap`, `AppPill` agrega 8px arriba y abajo para llegar a una zona táctil de 48px: en layout ocupa 48 de alto. Para filas de pills usar `Wrap(spacing: AppSpacing.sm)` o un `ListView` horizontal con separadores de 8.

Si hace falta una variante nueva (por ejemplo, con contador), se agrega como parámetro a `AppPill`, no como otro widget.

Toggle segmentado (Ingreso/Gasto en `add_transaction_screen`): contenedor transparente con borde `cardBorder` y radio `md`, opciones con padding 20×10, radio `sm`, texto 13/w800 tracking 0.5, fondo del color del tipo cuando está activa. Mantener ese patrón para cualquier segmentado.

## Reglas de identidad (de `PROYECTO_REGLAS.md`)

- El nombre se escribe `$imple` y usa `GoldShimmerText` cuando Pro está activo.
- Header del drawer: ícono de billetera en `GlassCard`, logo dorado `$imple`, "CONTROL FINANCIERO" en mayúsculas como subetiqueta, y estado "CUENTA PREMIUM" (punto verde con glow) o "CUENTA GRATIS" (punto gris).
- Drawer: solo Transacciones, Estadísticas, Deudas y Configuraciones, más Inteligencia AI y Bóveda Segura si es Pro. No agregar ítems sin aprobación.
- Pantalla de deudas: siempre con la sección de "Tips de Salida" (Avalancha, Bola de Nieve) para Pro.
- Dorado = Pro. No usar dorado para nada que no sea Pro.

## Web (landing en `SimpleLanding/` y `docs/`)

Misma paleta como variables CSS: `--primary:#7B5CFF; --primary-deep:#6F4DFF; --primary-light:#9A7BFF; --income:#3DDC97; --expense:#FF5C5C; --bg:#0E0E11; --surface:#16161C; --soft-text:#BFBFD2; --glass:rgba(255,255,255,.10); --border:rgba(255,255,255,.20); --gold:#D4AF37`. Fuente Outfit. Tarjetas con `backdrop-filter: blur(16px)`, radio 30px, borde 1px `--border`. Pills: alto 32px, padding 0 16px, `border-radius: 999px`, 12px/700. Fondo con un `radial-gradient` violeta arriba, igual que la app. Hoy la landing además usa `#1b122c`, `#0c0b1a` y `#09090b` como fondos sueltos: al tocarla, pasarlos a variables.

## Chequeo al terminar un retoque

Corré esto sobre los archivos que tocaste:

```bash
grep -nE "Color\(0x|Colors\.(deepPurple|orange|redAccent|green|red|blue|blueAccent|purple|pink|teal|grey|yellow)\b|BorderRadius\.circular\([0-9]|TextStyle\(" <archivos>
```

Cada resultado nuevo que hayas agregado vos es un error: cambialo por el token. Los que ya estaban, migralos si el archivo es el que estás editando; no hagas un refactor global sin que te lo pidan. (Los archivos de tokens de `core/ui/` son la excepción: ahí sí se definen colores.)

Además:

1. ¿Se reusaron `GlassCard`, `GradientButton`, `GlassInput`, `AppPill` y `AppScaffold` en vez de recrearlos?
2. ¿Pills hechas con `AppPill`? ¿Zona táctil de 48?
3. ¿Dorado solo en cosas Pro? ¿Verde/rojo solo para ingreso/gasto o éxito/error?
4. ¿Se respetan las reglas de `PROYECTO_REGLAS.md`?
5. ¿Sigue pasando `test/smoke_test.dart`?
