# Pendientes a definir — $imple

> Preguntas abiertas. Cuando Miguel responde, la respuesta se escribe acá y **pasa a valer más que la Especificación** (ver D-001).
> Formato: pregunta · lo que sabemos · respuesta (vacía hasta que se decida).

Última revisión: 2026-10-04 (chat 02).

---

### P-01 — ¿Qué versión de base de datos tiene la 1.1.8 (14) publicada?
**Lo que sabemos:**
- La 1.1.8 (14) existe en Play: hay un crash de Crashlytics del 27/09/2026 con esa versión.
- En git **nunca** existió "1.1.8" ni `versionCode 14`. Todo lo guardado dice `1.1.4+10`. Se compiló desde cambios sin commit, que se borraron el 2/10 (`git reset/clean`) y se rehicieron después (commit `98ddc0c`).
- En git y en el historial de Codex la DB siempre fue **12** hasta el 2/10. La reconstrucción pasó directo de 12 a **16**.
- Conclusión: la 1.1.8 tiene una versión de DB **entre 12 y 16**, no se puede saber cuál con lo que hay en la compu.

**Por qué no es grave:** las migraciones 13–16 se pueden repetir sin romper nada (agregar una columna que ya existe falla en silencio; redondear dos veces da lo mismo). Si la 1.1.8 tuviera una versión mayor a 16, sqflite no hace nada (no hay `onDowngrade`) y no se pierden datos.

**Cómo confirmarlo (opcional, 10 minutos):** Play Console → Versiones → Explorador de App Bundles → 1.1.8 (14) → descargar. Dentro, buscar en `lib/arm64-v8a/libapp.so` el texto `installments_total_amount` (si está, DB ≥ 15) y `ROUND(amount, 2)` (si está, DB = 16). Si no aparece `installments_total`, era 12 o 13.

**Respuesta:** _pendiente_ — se cierra en el chat 05 con una prueba real de actualización desde la 1.1.8.

### P-02 — Alcance de pantallas del MVP
**Lo que sabemos:** propuesta en la sección 4 de la Especificación.
**Respuesta (2026-10-04):** ✅ Aprobada tal cual la tabla de la sección 4 de la Especificación. La aplica el chat 01.

### P-03 — Crash de compras en la 1.1.8
`ProxyBillingActivity.onCreate` → `NullPointerException` en `PendingIntent.getIntentSender()` (billing 8.0.0). Pasa cuando se abre la compra Pro y Google Play no devuelve la pantalla de pago.
**Respuesta:** _pendiente_ — se trabaja en el chat 04.

### P-04 — Los documentos en `docs/` pueden quedar públicos
`docs/` es la carpeta que publica GitHub Pages. Cuando esta rama llegue a `main`, los `.md` se verían en la web.
**Opciones:** (a) agregar `docs/_config.yml` que los excluya, (b) moverlos a otra carpeta, (c) dejarlos públicos.
**Respuesta (2026-10-04):** ✅ (a) No se publican. Se agregó `docs/_config.yml` que los excluye; la landing sigue igual.

### P-05 — ¿Qué es gratis y qué es Pro en el MVP?
Hoy piden Pro: Estadísticas, Metas, Proyección, Presupuestos, Análisis mensual y Bóveda. Si se ocultan pantallas (P-02), Pro queda con menos cosas para vender.
**Respuesta (2026-10-04):** ✅ Con el alcance aprobado, Pro = Estadísticas, Metas de ahorro, Bóveda Segura y los Tips de salida de Deudas. Lo demás es gratis.

### P-06 — Archivos sueltos en la raíz del proyecto
Capturas (`cap *.jpeg/png`), `icon chatgpt..png`, `analyze.txt`, `test.txt` y el `.txt` del crash.
**Respuesta (2026-10-04):** ✅ Movidos a `_archivo/` (ignorada por git). No se borró nada.

### P-07 — `main` está muy atrás
`main` quedó en marzo 2026. Todo el trabajo está en `feature/mejoras-sesion`.
**Respuesta:** _pendiente_ — se decide cómo unir en el chat 06.

### P-08 — La pantalla Pro promete cosas que ya no están a la vista
`premium_screen.dart` muestra "Predicción de gastos del mes" (`benefit_predictions`) y el aviso de mejora (`PremiumFlowService`) muestra "Exportación de datos" (`feature_export`), pero la Proyección quedó oculta y el respaldo es gratis (P-05). En el chat 01 solo se sacaron del aviso "Análisis mensual" y "Presupuestos".
**Respuesta:** _pendiente_ — se ajusta en el chat 04 (Pro y compras).

### P-09 — 98 textos de traducción que ya no se usaban antes del chat 01
En `app_translations.dart` hay 98 claves (en las dos lenguas) que ningún archivo nombra, por ejemplo `get_pro`, `history_analytics`, `dark_mode`, `privacy_policy_part1`. Ya estaban sin uso antes del chat 01. No se borraron porque algunas podrían usarse de forma indirecta (por ejemplo, nombres de categorías guardados en la base).
**Respuesta:** _pendiente_ — revisar una por una y borrar las que sobran en una tarea de limpieza.

### P-10 — Íconos de categoría distintos entre pantallas
En "Agregar movimiento" las categorías tienen un ícono cada una (Compras, Servicios, Tarjeta de Crédito…), pero en la lista de movimientos (`transaction_tile.dart`) muchas salen con el ícono genérico porque esa lista busca otros nombres (`educación`, `venta`, `regalo`…). No es un error de datos, solo visual.
**Respuesta:** _pendiente_ — revisar con el sistema de diseño (skill `diseno-simple`) en una tarea de diseño.

### P-11 — Movimientos a la Bóveda sin Pro
Desde el chat 02, deslizar un movimiento a la derecha (mandarlo a la Bóveda) solo funciona con Pro; sacarlo de la Bóveda se permite siempre. Antes un usuario gratis podía esconder un movimiento en una Bóveda que no puede abrir.
**Respuesta:** _pendiente_ — confirmar en el chat 04 (Pro y Bóveda) que es el comportamiento deseado.
