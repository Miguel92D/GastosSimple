# Auditoría de diseño — $imple

> Chat 07, 2026-10-05. Compara el código y la app (emulador) con las reglas de la skill `diseno-simple`.
> Solo mira **cómo se ve**. No cambia funciones ni cálculos.
> Cada punto tiene un número (A-xx) para poder decir "arreglá A-03".

## Resumen en números

| Regla | Lo que dice | Cuántas veces no se cumple |
|---|---|---|
| Colores solo de `AppColors` | Nada de `Color(0x…)` ni `Colors.*` de Material | 6 |
| Radios solo de `AppRadius` (8, 16, 24, 30; 18 en FAB/menú) | Nada de números sueltos | ~50 (12, 2, 4, 6, 10, 20, 22, 32…) |
| Letra solo de `AppTextStyles` | Nada de `TextStyle(...)` ni `fontSize:` sueltos | 21 `TextStyle(` + ~75 `fontSize:` |
| Espacios solo de `AppSpacing` (4, 8, 16, 24, 32, 48) | Nada de `SizedBox(height: 12)` ni `EdgeInsets` con números | ~190 (la mitad en Deudas) |
| Botón principal = `GradientButton` | `AppButton` es legado | 6 `AppButton` + botones de Material sueltos en 9 pantallas |
| Pills = `AppPill` | No armar pills a mano | **`AppPill` no existe** (P-20); todas las pills están hechas a mano |

Pantallas más desordenadas: **Deudas** (la peor por lejos), Pro, Estadísticas, Configuración, Metas, Agregar movimiento.

## Lo que se ve en la app

- **A-01 · Ingresos y Gastos del inicio no eran iguales** (captura de Miguel). Con un monto largo, una tarjeta quedaba más baja y con la letra más chica. ✅ **Arreglado en este chat:** las dos usan siempre el mismo tamaño de monto (el que hace entrar al más largo) y el borde no cambia de grosor al tocarlas. Test: `test/design_cards_test.dart`.
- **A-02 · Deudas: los botones de abajo tapan el contenido.** El botón de menú y el `+` quedan encima de "Bola de nieve". ✅ Menos aire arriba del aviso "Sin deudas" (80 → 32) y la lista conserva 120 de espacio al final.
- **A-03 · Deudas: cada estrategia tiene otro color.** Avalancha usa azul (`AppColors.blue`, color de categoría) y Bola de nieve violeta. Los colores de categoría no se usan como acento. ✅ Las dos en violeta.
- **A-04 · Selector Día/Mes no sigue el patrón del segmentado.** Radio 12 escrito como `AppRadius.sm + 4`, letra 11 y la palabra cambia de grosor al elegirla (se "mueve"). ✅ Sigue el patrón del segmentado.
- **A-05 · Mayúsculas mezcladas.** "GUARDAR" y "Crear Backup" son los dos botones principales; uno en mayúsculas y otro no. Lo mismo con las etiquetas: "Categoría" y "Repetir" vs "NOTA". ✅ `GradientButton` pone el texto en MAYÚSCULAS; etiquetas de sección en MAYÚSCULAS.
- **A-06 · Ajustes se ve distinto al resto.** Es una lista plana sin tarjetas de vidrio, con títulos de sección violetas; el resto de la app usa `GlassCard`. ✅ Cada sección en una tarjeta.
- **A-07 · Menú rápido usa naranja.** El rayo de "Carga rápida" y el candado de la Bóveda son naranjas (`AppColors.orange`, color de categoría). Tampoco es dorado, pero se confunde con "algo especial". ✅ Violeta.
- **A-08 · Fondo oscuro del "cargando" en Configuración** usa `Colors.black54` (Material). ✅ `AppColors.overlay`.

## Lo que solo se ve en el código

- **A-09 · Estadísticas:** 5 colores escritos a mano (`Color(0xFFC084FC)`…) que ya existen como token (`AppColors.purple`, `violet`, `sky`, `amber`, `pink`). Además el gráfico usa `incomeGreen` y `expenseRed`, que la regla reserva para ingreso/gasto. ✅ Todo con tokens de categoría.
- **A-10 · Radios:** 12 aparece 7 veces, 2 (rayita de arrastre de los paneles de abajo) 5 veces, 4 y 6 en barras, 20/22/32 en Deudas, Política y Carga rápida.
- **A-11 · Letra:** los tamaños 11, 13, 15, 18 y 26 se usan mucho y no tienen estilo propio. La regla dice que solo se aceptan en badges y toggles, pero el código los usa en montos de lista, fechas y títulos de tarjeta.
- **A-12 · Botones:** ✅ `AppButton` ahora usa `GradientButton` por dentro (radio 24, MAYÚSCULAS, texto oscuro sobre dorado). Antes: `AppButton` (legado, radio libre) en Deudas, Metas, aviso Pro y Bóveda bloqueada. `TextButton`/`OutlinedButton` de Material con estilos distintos en cada pantalla.
- **A-13 · Chips de fecha y tarjeta** (Agregar movimiento): hechas a mano con padding 14×10 y radio 16, distintas de la pill de la regla. ✅ Usan `AppPill`.
- **A-14 · Dos `ProBadge`:** ✅ falsa alarma, ya queda uno solo (`core/ui/widgets/pro_badge.dart`). La skill está desactualizada.

## Reglas que la skill no tiene y hacen falta

✅ Decididas por Miguel el 2026-10-05 (D-029):

1. **Tarjetas lado a lado:** mismo alto y mismo tamaño de monto (nació de A-01).
2. **Tamaños de letra que faltan:** se suman `labelSmall` (11), `amountList` (15) y `titleSmall` (18).
3. **Mayúsculas:** botones principales siempre en MAYÚSCULAS; etiquetas de sección siempre en MAYÚSCULAS con `subLabel`.
4. **Espacio al final de cada pantalla** para que los botones flotantes no tapen nada (A-02).
5. **Rayita de arrastre** de los paneles de abajo: un solo componente (hoy está copiada 5 veces).

## Fuera de diseño (anotado aparte)

- Los textos mezclan "vos" y "tú": "Podés gastar hoy", "Entrá" vs "¿Qué **quieres** registrar hoy?", "**Agrega** tu primera deuda", "**Puedes** exportar", "**Elige** estrategia". Es de textos, no de diseño (P-21).
- La skill dice que el botón de menú va abajo a la izquierda; en la app está abajo al centro. Manda el código: hay que corregir la skill (P-20).

## Qué queda

- **A-10 / A-11 (código):** espacios, radios y tamaños de letra sueltos en las pantallas que no se tocaron (sobre todo Pro, Metas, Proyección, Política). Se pasan a tokens cuando se toque cada pantalla.
- **Reglas 4 y 5** (espacio al final de cada pantalla, rayita de arrastre como componente): sin hacer.
- Revisar en el teléfono las pantallas que el emulador no llegó a mostrar con los cambios: Ajustes con tarjetas, Agregar movimiento con pills, Deudas, Estadísticas (Pro).
