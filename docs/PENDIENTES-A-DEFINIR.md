# Pendientes a definir — $imple

> Preguntas abiertas. Cuando Miguel responde, la respuesta se escribe acá y **pasa a valer más que la Especificación** (ver D-001).
> Formato: pregunta · lo que sabemos · respuesta (vacía hasta que se decida).

Última revisión: 2026-10-05 (chat 09).

---

### P-01 — ¿Qué versión de base de datos tiene la 1.1.8 (14) publicada?
**Lo que sabemos:**
- La 1.1.8 (14) existe en Play: hay un crash de Crashlytics del 27/09/2026 con esa versión.
- En git **nunca** existió "1.1.8" ni `versionCode 14`. Todo lo guardado dice `1.1.4+10`. Se compiló desde cambios sin commit, que se borraron el 2/10 (`git reset/clean`) y se rehicieron después (commit `98ddc0c`).
- En git y en el historial de Codex la DB siempre fue **12** hasta el 2/10. La reconstrucción pasó directo de 12 a **16**.
- Conclusión: la 1.1.8 tiene una versión de DB **entre 12 y 16**, no se puede saber cuál con lo que hay en la compu.

**Por qué no es grave:** las migraciones 13–16 se pueden repetir sin romper nada (agregar una columna que ya existe falla en silencio; redondear dos veces da lo mismo). Si la 1.1.8 tuviera una versión mayor a 16, sqflite no hace nada (no hay `onDowngrade`) y no se pierden datos.

**Cómo confirmarlo (opcional, 10 minutos):** Play Console → Versiones → Explorador de App Bundles → 1.1.8 (14) → descargar. Dentro, buscar en `lib/arm64-v8a/libapp.so` el texto `installments_total_amount` (si está, DB ≥ 15) y `ROUND(amount, 2)` (si está, DB = 16). Si no aparece `installments_total`, era 12 o 13.

**Respuesta (2026-10-05, chat 05):** ✅ Ya no importa cuál era. `test/db_upgrade_test.dart` arma bases con el esquema exacto de la 12, 13, 14, 15 y 16, con datos, y las abre con la app de hoy: no se pierde nada, las migraciones pueden correr dos veces y una base más nueva (17) tampoco pierde datos (D-021).
Queda una prueba a mano, opcional, para el chat 06: en un teléfono instalar la 1.1.8 desde Play (prueba interna), cargar algunos movimientos (uno en la Bóveda), instalar encima el AAB nuevo y ver que todo sigue ahí.

### P-02 — Alcance de pantallas del MVP
**Lo que sabemos:** propuesta en la sección 4 de la Especificación.
**Respuesta (2026-10-04):** ✅ Aprobada tal cual la tabla de la sección 4 de la Especificación. La aplica el chat 01.

### P-03 — Crash de compras en la 1.1.8
`ProxyBillingActivity.onCreate` → `NullPointerException` en `PendingIntent.getIntentSender()` (billing 8.0.0). Pasa cuando se abre la compra Pro y Google Play no devuelve la pantalla de pago.
**Respuesta (2026-10-04, chat 04):** ✅ Revisado. **No es un error de nuestro código y no se puede arreglar desde la app.**
- Se miró el código de la librería (Billing 8.0.0): `ProxyBillingActivity` es una pantalla interna de Google (no exportada) que solo abre la propia librería. Se cae cuando Google Play contesta "OK" pero **sin** la pantalla de pago. Pasa en Play Store rotos o viejos, teléfonos modificados y en los robots de prueba de Google (el "informe previo al lanzamiento"). El crash es de un Android 11 el 27/09, justo después de subir la 1.1.8: muy probablemente fue ese robot.
- Google no lo corrigió en ninguna versión (8.1 a 9.1 no lo nombran). RevenueCat, que vende compras para miles de apps, recomienda ignorarlo en Crashlytics.
- Lo que sí se hizo: Billing fijo en 8 (D-017, igual que la 1.1.8 y obligatorio para publicar), los botones no quedan trabados si Google Play no abre el pago, y no se abren dos compras a la vez.
- Para el chat 06: probar una compra real con una **cuenta de prueba de licencias** en la prueba interna. Si en Crashlytics vuelve a aparecer solo en dispositivos de prueba de Google, cerrarlo como "no se arregla".

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
**Respuesta (2026-10-05, chat 06):** ✅ `main` ahora apunta al mismo commit que `feature/mejoras-sesion`. Los 2 commits viejos de `main` (nunca subidos) se guardaron en la rama `archivo/main-marzo-2026` (D-026).

### P-08 — La pantalla Pro promete cosas que ya no están a la vista
`premium_screen.dart` muestra "Predicción de gastos del mes" (`benefit_predictions`) y el aviso de mejora (`PremiumFlowService`) muestra "Exportación de datos" (`feature_export`), pero la Proyección quedó oculta y el respaldo es gratis (P-05). En el chat 01 solo se sacaron del aviso "Análisis mensual" y "Presupuestos".
**Respuesta (2026-10-04, chat 04):** ✅ Corregido. La pantalla Pro y el aviso muestran los mismos cuatro: Estadísticas, Metas de ahorro, Bóveda Segura y Tips de salida en Deudas (`PremiumFlowService.proBenefitKeys`). Se sacaron "Predicción de gastos", "Insights inteligentes", "Analíticas avanzadas" y "Exportación de datos". El botón del aviso decía "Probar Premium" (sonaba a prueba gratis): ahora dice "Ver $imple PRO". Los Tips de Deudas eran gratis en la práctica: ahora piden Pro (D-019).

### P-09 — 98 textos de traducción que ya no se usaban antes del chat 01
En `app_translations.dart` hay 98 claves (en las dos lenguas) que ningún archivo nombra, por ejemplo `get_pro`, `history_analytics`, `dark_mode`, `privacy_policy_part1`. Ya estaban sin uso antes del chat 01. No se borraron porque algunas podrían usarse de forma indirecta (por ejemplo, nombres de categorías guardados en la base).
**Respuesta (2026-10-05, chat 09):** ✅ Revisadas todas: se borraron **102 claves** (en las dos lenguas) que ningún archivo nombra. Las categorías no usan `AppTranslations` (se guardan con su nombre), así que no había usos indirectos. Las únicas claves armadas con variable son `privacy_s1…s8_title/body` (se usan y quedan). Quedan 332 claves por idioma.

### P-10 — Íconos de categoría distintos entre pantallas
En "Agregar movimiento" las categorías tienen un ícono cada una (Compras, Servicios, Tarjeta de Crédito…), pero en la lista de movimientos (`transaction_tile.dart`) muchas salen con el ícono genérico porque esa lista busca otros nombres (`educación`, `venta`, `regalo`…). No es un error de datos, solo visual.
**Respuesta (2026-10-05, chat 07):** ✅ Resuelto. Las dos pantallas usan el mismo mapa (`CategoryIcons`, D-028), que entiende singular/plural, tildes, inglés y claves `cat_*`.

### P-11 — Movimientos a la Bóveda sin Pro
Desde el chat 02, deslizar un movimiento a la derecha (mandarlo a la Bóveda) solo funciona con Pro; sacarlo de la Bóveda se permite siempre. Antes un usuario gratis podía esconder un movimiento en una Bóveda que no puede abrir.
**Respuesta (2026-10-04, chat 04):** ✅ Confirmado: mandar a la Bóveda solo con Pro; sacar de la Bóveda siempre. Además, cargar un movimiento nuevo en la Bóveda (`/add` con `isVault`) también pide Pro (D-019).

### P-12 — Sumas en SQL que ya no se usan
Desde el chat 03 (D-016) nadie llama a `getTotalIncome`, `getTotalExpenses` ni `getExpensesByCategory` de `DatabaseHelper` (ni a sus copias en `TransactionRepository` y `TransactionController`). Quedaron para no tocar la base en esta tarea.
**Respuesta (2026-10-05, chat 09):** ✅ Borradas `getTotalIncome`, `getTotalExpenses` y `getExpensesByCategory` de `DatabaseHelper`, `TransactionRepository` y `TransactionController`. Queda `DashboardController.getExpensesByCategory`, que suma en Dart (D-016) y sí se usa.

### P-13 — ¿Se quita Pro si Google devuelve el dinero?
Hoy Pro queda guardado en el teléfono (`is_pro`) para siempre. Si alguien pide reembolso, Google Play deja de devolver la compra, pero la app no apaga Pro. Apagarlo al no encontrar la compra tiene un riesgo: sin internet o con Google Play fallando, un cliente que pagó podría perder Pro.
**Respuesta (2026-10-05):** ✅ Sí, con cuidado: se quita solo cuando Google Play contesta bien y la compra pagada no está; con error o sin internet queda PRO. Se revisa también al volver a la app y al abrir la pantalla Pro o Configuración (D-027).

### P-14 — Mensajes de compra solo en español y sin tildes
Los mensajes de `PurchaseService` ("Compra cancelada.", "No se encontro una compra…") están escritos en el código, solo en español y sin tildes. D-008 pide las dos lenguas.
**Respuesta:** _pendiente_ — las tildes ya se corrigieron (D-027); falta pasarlos a `AppTranslations` para que estén en inglés, en una tarea de textos (junto con P-09).

### P-15 — Más textos y código Pro sin uso
Desde el chat 04 ya nadie usa los textos `benefit_predictions`, `benefit_analytics`, `benefit_strategies`, `smart_insights`, `feature_stats`, `feature_export`, `feature_vault` y `feature_goals`. Tampoco se usa `PremiumService` ni `AppModeController.isPro`.
**Respuesta (2026-10-05, chat 09):** ✅ Borrados los textos (con P-09), `PremiumService` y todo `AppModeController` (guardaba un modo que nadie leía). El test de `pro_vault_test.dart` sigue comprobando que esas promesas viejas no vuelvan, ahora con el texto escrito.

### P-16 — Usuarios que ya tienen huella sin PIN
Desde el chat 05 la huella necesita un PIN (D-022). Pero alguien que en una versión anterior activó solo la huella sigue así: entra con la huella o con el bloqueo del teléfono (la app lo permite). Si un día fallan los dos, no hay forma de entrar.
**Respuesta:** _pendiente_ — decidir si al abrir la app se le pide crear un PIN a esos usuarios.

### P-17 — ¿Existe el correo de contacto?
La política web dice `soporte@simpleapp.com`. No sabemos si esa casilla existe y alguien la lee. Google Play pide un contacto que funcione.
**Respuesta (2026-10-05, chat 06):** ✅ Miguel confirma que `soporte@simpleapp.com` existe y se lee. Queda igual; es el correo de contacto de la ficha de Play.

### P-18 — Formulario "Seguridad de los datos" de Play
La política nueva (chat 05) dice: datos solo en el teléfono, reportes de fallos opcionales (Crashlytics, con identificador de instalación) y que la copia de seguridad de Android puede incluir los datos de la app. El formulario de Play tiene que decir lo mismo.
**Respuesta (2026-10-05, chat 06):** ✅ Respuestas para Play Console → Contenido de la app → Seguridad de los datos (sacadas de la política, secciones 1–8):
- ¿Recopila o comparte datos de los tipos requeridos? **Sí** (solo los reportes de fallos, y solo si el usuario acepta).
- ¿Datos cifrados en tránsito? **Sí** (Crashlytics envía por HTTPS).
- ¿Forma de pedir que se borren los datos? **No** hay cuenta ni servidor propio; los datos del teléfono se borran desde la app, los Ajustes de Android o desinstalando.
- Tipos de datos — **recopilados, no compartidos, opcionales** (el usuario elige), procesados de forma efímera: **No**:
  - Información y rendimiento de la app → **Registros de fallos** y **Diagnóstico**. Para qué: Funcionalidad de la app y Análisis.
  - ID del dispositivo u otros → **ID de dispositivo u otros IDs** (identificador de instalación de Firebase). Para qué: Funcionalidad de la app y Análisis.
- **Nada más.** Movimientos, deudas, Bóveda, PIN y huella quedan solo en el teléfono (no cuenta como "recopilar"). La compra PRO la procesa Google Play (no se declara). La copia de seguridad de Android va a la cuenta de Google del usuario, $imple no la ve. No hay Firebase Analytics ni publicidad: en "¿Tu app contiene anuncios?" va **No**.
- URL de la política: la de `privacy.html` en GitHub Pages. Correo: `soporte@simpleapp.com` (P-17).

### P-19 — Más código de restauración sin uso
`DatabaseHelper.restoreGoal` y `restoreDebt` ya no los usa nadie (el respaldo pasa por `restoreBackupData`) y usan `ConflictAlgorithm.replace`, que la Especificación §8 prohíbe para datos de un archivo. `restoreTransaction` sí se usa, pero solo para "Deshacer" un borrado.
**Respuesta (2026-10-05, chat 09):** ✅ Borradas `restoreGoal` y `restoreDebt`. `restoreTransaction` queda (lo usa "Deshacer").


### P-20 — La skill `diseno-simple` nombra un `AppPill` que no existe
La skill dice que toda pill se hace con `AppPill` (`lib/core/ui/widgets/app_pill.dart`), pero ese archivo no está en el código (visto en el chat 07). Las pills hoy se arman a mano en cada pantalla.
**Respuesta (2026-10-05, chat 07):** ✅ Se creó `AppPill` con las medidas de la skill (D-029).
Queda abierto (auditoría del chat 07): la skill dice que el botón de menú va abajo a la izquierda, pero en la app está abajo al centro. Manda el código; hay que corregir la skill (fuera del repo) y sumarle las reglas de D-029 a D-032 (paso 8 del chat 08).
**Respuesta (2026-10-05, chat 08):** ✅ Skill reescrita con el sistema modular (reglas R-1…R-8, `AppIcons`, módulos, letras, tests) y el menú abajo al centro. Está en el repo: `.claude/skills/diseno-simple/SKILL.md` (Claude Code la usa en este proyecto). La copia de la cuenta de claude.ai no se tocó: para que valga también fuera de este repo, Miguel tiene que subir ese archivo a su skill `diseno-simple` en claude.ai.

### P-21 — Los textos mezclan "vos" y "tú"
La app dice "Podés gastar hoy" y "Entrá…", pero también "¿Qué quieres registrar hoy?", "Agrega tu primera deuda", "Puedes exportar…", "Mantén tus datos seguros" y "Elige estrategia" (visto en el chat 07).
**Respuesta:** _pendiente_ — elegir uno (vos o tú) y corregir los textos en español en una tarea de textos (junto con P-14).

### P-22 — Aviso "Floating SnackBar presented off screen"
En el emulador (chat 08) Flutter avisó una vez "Floating SnackBar presented off screen": un aviso flotante quedó tapado o fuera de la pantalla, probablemente por los botones de abajo. Ya pasaba antes de los cambios de diseño. No se investigó (fuera de la tarea).
**Respuesta:** _pendiente_ — ver en qué pantalla aparece y darle margen abajo al aviso.

