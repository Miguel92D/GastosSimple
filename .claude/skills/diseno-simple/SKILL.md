---
name: "diseno-simple"
description: "Sistema de diseño de la app $imple (gastos_simple, Flutter, D:\\mis apps\\Simple) y su landing web. Usala siempre que se cree, retoque o revise cualquier pantalla, widget, color o estilo de Simple."
---

# Diseño $imple

Simple tiene un **sistema de diseño modular** en `lib/core/ui/` (chat 08, D-032; documento completo: `docs/SISTEMA-DISENO.md`). Esta skill no inventa estilo nuevo: sirve para que cada retoque **use los módulos** y no agregue copias. Los valores salen del código (octubre 2026). Si el código cambia, el código manda y esta skill se actualiza.

Solo para Simple. Su estética (violeta, vidrio, brillo, dorado Pro) es distinta de `diseno-miguel`; dentro de Simple no se usa `diseno-miguel`.

## Antes de tocar nada

1. Leer `CLAUDE.md` y los docs en su orden (Decisiones > Pendientes > Especificación). Las reglas de identidad (logo, menú, Pro, Bóveda) están en la Especificación.
2. Abrir el **catálogo visual**: Ajustes → DEV → "Catálogo de diseño" (solo en modo desarrollo; `lib/features/dev/design_catalog_screen.dart`). Muestra todos los módulos juntos.
3. Buscar en `lib/core/ui/` el módulo que ya existe. **Reusar siempre.**
4. **Cualquier cambio que se vea distinto se consulta con Miguel antes** (con un dibujo "hoy / propuesta").

## Las 8 reglas (D-032)

- **R-1 · Una cosa, un módulo.** Lo que aparece en más de una pantalla vive en un solo archivo de `lib/core/ui/`. Las pantallas lo usan, no lo copian.
- **R-2 · Se cambia el módulo, nunca la pantalla.** Si una pantalla necesita algo distinto, se agrega una **variante con nombre** al módulo (`AppListRow.setting`, `AppLogo.drawer`). Nunca una copia con un cambio.
- **R-3 · Un concepto, un ícono.** Los íconos salen de `AppIcons` (o `CategoryIcons.of` para categorías). Ninguna pantalla escribe `Icons.…`. Todos `…_rounded`. Un ícono de categoría no se usa para una acción.
- **R-4 · Tamaño fijo** (D-030). Un módulo mide lo mismo en todas las pantallas y con cualquier contenido. Si un monto no entra, se achica (`FittedBox`), no agranda la tarjeta.
- **R-5 · Nada de números sueltos en pantallas.** Colores, radios, letras, tamaños de ícono y espacios salen de `AppColors`, `AppRadius`, `AppTextStyles`, `AppIconSize`, `AppSpacing`.
- **R-6 · Lo de Material se configura una vez** en `AppTheme.brandTheme`: diálogos, botones de texto, interruptores, checkbox, divisores, indicador de carga, paneles.
- **R-7 · Los tests vigilan las reglas** (ver "Tests" abajo).
- **R-8 · Sin flechas ↑/↓ junto a montos** (D-031) y **dorado solo para Pro**.

## Tokens

### Colores (`AppColors`)

| Token | Valor | Uso |
|---|---|---|
| `primaryPurple` | `#7B5CFF` | Marca, acción principal, ítem activo |
| `primaryDeep` / `primaryLight` | `#6F4DFF` / `#9A7BFF` | Gradiente de marca |
| `incomeGreen` | `#3DDC97` | Ingresos, saldo positivo, éxito |
| `expenseRed` | `#FF5C5C` | Gastos, saldo negativo, borrar, error |
| `darkBackground` | `#0E0E11` | Fondo de la app y de los paneles |
| `surface` | `#16161C` | Diálogos, avisos |
| `glassSurface` | blanco 10% | Vidrio plano (selector, pills inactivas) |
| `cardBorder` | blanco 20% | Borde de 1px, divisores, rayita de paneles |
| `textPrimary` / `softText` / `textMuted` | `#FFF` / `#BFBFD2` / `#636366` | Texto |
| `softTextDim` | `softText` al 60% | Subtítulo de filas, datos secundarios |
| `overlay` | negro 54% | Fondo del "cargando" |
| `gold` / `goldShine` | `#D4AF37` | **Solo Pro** (logo Pro, `ProBadge`, aviso Pro). Botón dorado con texto `darkBackground` |
| Categorías: `orange`, `blue`, `indigo`, `teal`, `pink`, `purple`, `amber`, `sky`, `violet` | | Solo categorías y gráficos. Nunca como acento de UI. Los gráficos no usan verde/rojo |

En pantallas: ningún `Color(0x…)` ni color de Material. Válidos: `Colors.white`/`Colors.black` con alfa y `Colors.transparent`.

### Gradientes (`AppGradients`)
`primaryGradient` (botón principal, balance), `progressGradient`, `glassGradient` (base de `GlassCard`), `softGlassGradient`, `incomeGradient` / `expenseGradient`, `mainBackgroundRadial` (fondo vía `AppScaffold`). No crear gradientes en pantallas.

### Espacios (`AppSpacing`)
`xs 4 · sm 8 · md 16 · lg 24 · xl 32 · xxl 48`. **Margen a los costados de toda pantalla: `AppSpacing.screen` = 24** (D-032).

### Radios (`AppRadius`)

| Token | Valor | Para qué |
|---|---|---|
| `sm` | 8 | Caja de ícono, botón chico, opción del selector, etiqueta |
| `md` | 16 | Contenedor del selector, botón de categoría |
| `lg` | 24 | Botón principal y secundario, filas, tarjetas de lista, diálogos |
| `xl` | 30 | `GlassCard` grande, `GlassInput`, panel de abajo |
| `round` | 18 | Botón redondo 56×56 |
| `bar` | 4 | Barra de progreso, rayita del panel |
| Pills | — | Redondas del todo (`AppPill`) |

### Íconos (`AppIcons`, `AppIconSize`)
Tamaños: `small 16 · normal 20 · large 24 · button 28 · empty 64`.

| Concepto | `AppIcons.` | Ícono |
|---|---|---|
| Inicio / Movimientos / Deudas / Pagos fijos | `home` / `movements` / `debts` / `recurring` | dashboard / swap_vert / account_balance / autorenew |
| Cuotas | `installments` | credit_card |
| Estadísticas / Metas / Bóveda / Pro | `stats` / `goals` / `vault` / `pro` | analytics / **savings** / lock / workspace_premium |
| PIN / Huella / Privacidad | `pin` / `fingerprint` / `privacy` | **pin** / fingerprint / **shield** |
| Tips de salida / Avalancha / Bola de nieve | `exitTips` / `avalanche` / `snowball` | **lightbulb_outline** / **landslide** / ac_unit |
| Carga rápida | `quickEntry` | flash_on (solo esto) |
| Agregar / gasto | `add` / `remove` | add / remove |
| Editar / Borrar / Pagar | `edit` / `delete` / `pay` | edit / delete_outline / **paid** |
| Cerrar / Listo | `close` / `done` | close / check_circle |
| Día / Mes / Elegir fecha | `day` / `month` / `pickDate` | calendar_today / calendar_month / **edit_calendar** |
| Respaldo / Exportar / Importar | `backup` / `exportFile` / `importFile` | **backup** / upload / download |
| Ver más / Info / Aviso | `next` / `info` / `warning` | chevron_right / info_outline / warning_amber |

Lista completa en `lib/core/ui/app_icons.dart`. Si falta un concepto, se agrega ahí (con nombre de concepto, no de dibujo).

### Letra (`AppTextStyles`)
Fuente del sistema (Roboto). La landing usa Outfit; unificarlas está pendiente: no cambiar la fuente sin que Miguel lo pida.

| Estilo | Tamaño / peso | Uso |
|---|---|---|
| `amountInput` | 42 / w900 | Monto que se escribe en "Agregar" |
| `balanceAmount` | 40 / w900 | — |
| `amountHero` | 36 / w900 verde | Total ahorrado (Metas) |
| `titleLarge` | 32 / w900 | Título de pantalla Pro |
| `balanceCardAmount` | 32 / w900 | Monto de la tarjeta de balance (D-030) |
| `price` | 30 / w900 violeta | Precio de Pro |
| `amountHighlight` | 26 / w900 | "Podés gastar hoy", total de Estadísticas |
| `screenTitle` | 24 / w900 | Título en la barra de arriba (`AppScaffold`) |
| `headline` | 24 / w800 | Titular dentro de una pantalla (Respaldo, Consentimiento, aviso Pro) |
| `pinDigit` | 24 / w700 violeta | Teclado del PIN |
| `incomeValue` / `expenseValue` | 22 / w900 | Montos verdes / rojos destacados |
| `titleMain` | 20 / w800 | Títulos de sección grandes |
| `titleSmall` | 18 / w800 | Título de panel, de tarjeta chica, de diálogo |
| `cardTitle` / `buttonLabel` | 16 / w700 | Título de tarjeta / texto del botón principal |
| `amountList` | 15 / w800 | Monto dentro de una fila (`AppAmount.list`) |
| `rowTitle` | 14 / w700 | Título de fila (`AppListRow`) |
| `bodyMain` (= `bodyText`) | 14 / w600 | Cuerpo |
| `secondaryButtonLabel` | 14 / w700 violeta | `AppSecondaryButton` |
| `amountCard` / `segmentLabel` | 13 / w900 · w800 | Ingresos/Gastos del inicio (D-030) / opción del selector |
| `subLabel` | 12 / w700, tracking 1 | Títulos de sección en MAYÚSCULAS |
| `rowSubtitle` | 12 / w500 `softTextDim` | Subtítulo de fila |
| `bodySmall` (= `subtitle`) | 12 / w500 | Texto chico, fechas |
| `labelSmall` | 11 / w700 | Etiqueta chica en MAYÚSCULAS |
| `badge` | 10 / w900 | Nombre en el botón de categoría, "MEJOR VALOR" |
| `emoji` | 24 | Emoji de una meta |

Se parte de un estilo con nombre (`.copyWith(color: …)` está bien). **En pantallas no se escribe `fontSize:` con número ni `TextStyle(`.** Si hace falta un tamaño nuevo, se agrega un estilo con nombre acá y en `app_text_styles.dart`.

**MAYÚSCULAS:** botón principal y secundario (lo hacen solos), títulos de sección (`AppSectionTitle`), opciones del selector. Los botones de texto de los diálogos van **como están escritos** ("Cancelar", "Guardar").

## Módulos (usar estos, no recrearlos)

Todos en `lib/core/ui/` (los widgets en `lib/core/ui/widgets/`).

| Módulo | Qué es | Medidas |
|---|---|---|
| `AppScaffold` | Marco de toda pantalla: fondo con resplandor, barra transparente con `screenTitle`, **botón de menú abajo al centro** y botón(es) abajo a la derecha | — |
| `AppLogo` / `AppLogo.drawer` | `$imple`, dorado con brillo si hay Pro (lo decide solo) | 24 / 28 |
| `GlassCard` | Tarjeta de vidrio: blur 16, `glassGradient`, borde 1px, radio `xl`, padding `lg` | — |
| `BalanceCard`, `IncomeExpenseCards` | Tarjetas del inicio | Alto fijo (D-030) |
| `GradientButton` | Botón principal: gradiente de marca, radio `lg`, MAYÚSCULAS | Alto ≈ 52 |
| `AppButton` | Atajo a `GradientButton` (violeta o dorado con texto oscuro) | — |
| `AppSecondaryButton` | Botón con borde violeta suave, sin degradado, MAYÚSCULAS | Alto 48, radio `lg` |
| `AppRoundButton` | Botón redondo de vidrio: `+`/`−` del inicio (`AppFAB`), `+` de Deudas y Metas, menú | 56×56, radio 18, borde 2, brillo 30%, ícono 28 |
| `AppActionButton` | Botón chico de acción (pagar, editar, borrar) | 38×38, radio `sm`, ícono 20 |
| `AppIconBox` | Ícono en caja de color al principio de una fila | 40×40, radio `sm`, fondo 12%, ícono 20 |
| `AppListRow` | Fila: caja, título 14, subtítulo 12 de un renglón, a la derecha `AppAmount` (máx. 45% del ancho) y nota | En tarjeta radio `lg`, padding 16×12. `framed: false` dentro de otra tarjeta (Deudas). `AppListRow.setting`: Ajustes, caja violeta, sin monto, `›` o interruptor |
| `AppAmount.list` | Monto de fila: formatea, se oculta con el ojo (`••••••`), se achica antes de cortarse | 15 |
| `AppSectionTitle` | Título de sección en MAYÚSCULAS gris; `trailing` para `ProBadge` | 16 arriba, 8 abajo |
| `AppSegmented` | Selector de opciones (Día/Mes, Ingreso/Gasto); color por opción | Opción 20×10, radio `sm`, 13/w800 |
| `AppPill` | Pill: informativa, elegida o sin elegir; con ícono | Alto 32, zona táctil 48 |
| `AppProgressBar` | Barra de progreso, color liso (lo elige la pantalla), animada | Alto 8 |
| `AppEmptyState` | "No hay nada": ícono gris 64, texto, subtítulo y botón opcionales | — |
| `AppSheet.show` | Panel de abajo: fondo `darkBackground`, radio `xl`, rayita, fondo oscurecido 75%, sube con el teclado. `AppSheetTitle` (18) y `AppSheetOption` (ícono + texto) | — |
| `GlassInput` | Campo de texto (vidrio, radio 30, ícono gris); `readOnly` + `onTap` para fechas, `autofocus` | — |
| `ProBadge` | Etiqueta PRO dorada | 10/w900 |
| `ProBenefitList` | Los 4 beneficios Pro (de `PremiumFlowService.proBenefitKeys`), cada uno con su ícono en caja violeta | — |
| `AppTheme.brandTheme` | Diálogos (surface, borde, radio 24, título 18), botones de texto violetas (rojo para borrar con `TextButton.styleFrom`), interruptores violeta con bolita blanca, un divisor | — |

**Cosas de una sola pantalla** (estrategias de Deudas, teclado del PIN, botones de categoría de "Agregar", fondo al deslizar un movimiento…) pueden quedarse en su pantalla, pero con tokens. Si aparecen en una segunda pantalla, pasan a módulo.

## Reglas de identidad

- El nombre se escribe `$imple` y usa `AppLogo` (dorado con Pro).
- Menú: Panel, Movimientos, Deudas, Pagos fijos y Ajustes (+ lo Pro). No agregar ítems sin aprobación.
- Deudas: Tips de salida (Avalancha, Bola de nieve) piden Pro.
- Dorado = Pro. Verde/rojo = ingreso/gasto o éxito/error.

## Tests (R-7)

`test/design_cards_test.dart` y `test/design_modules_test.dart` fallan si en `lib/features/` o `lib/core/flow/`:
- aparece `Icons.` (fuera de `app_icons.dart` / `category_icons.dart`) o una flecha ↑/↓;
- aparece `Color(0x…)` o un color de Material;
- aparece `fontSize:` con número o `TextStyle(`;
- aparece `Radius.circular(` con número;
- aparece `showModalBottomSheet`, `LinearProgressIndicator`, `ElevatedButton` u `OutlinedButton` (usar `AppSheet`, `AppProgressBar`, `GradientButton` / `AppSecondaryButton`);
- crece la lista de `BoxDecoration(` hechas a mano (la lista solo se achica);
- un módulo cambia de tamaño según el contenido.

## Chequeo al terminar un retoque

1. `flutter analyze` limpio y `flutter test` en verde.
2. ¿Se usó un módulo existente? ¿Si hacía falta algo distinto, se agregó una variante con nombre?
3. ¿Ningún número suelto? ¿Margen de pantalla `AppSpacing.screen`?
4. ¿Se consultó con Miguel todo lo que se ve distinto? ¿Captura antes y después en el emulador?
5. ¿El catálogo visual sigue mostrando bien el módulo tocado?

## Web (landing en `SimpleLanding/`, `docs/`, `github_pages_root/`)

Misma paleta como variables CSS: `--primary:#7B5CFF; --primary-deep:#6F4DFF; --primary-light:#9A7BFF; --income:#3DDC97; --expense:#FF5C5C; --bg:#0E0E11; --surface:#16161C; --soft-text:#BFBFD2; --glass:rgba(255,255,255,.10); --border:rgba(255,255,255,.20); --gold:#D4AF37`. Fuente Outfit. Tarjetas con `backdrop-filter: blur(16px)`, radio 30px, borde 1px. Pills: alto 32px, padding 0 16px, radio 999px, 12px/700. Fondo con `radial-gradient` violeta arriba. La landing todavía usa `#1b122c`, `#0c0b1a` y `#09090b` sueltos: al tocarla, pasarlos a variables. Las tres copias de la landing se mantienen iguales (D-024).
