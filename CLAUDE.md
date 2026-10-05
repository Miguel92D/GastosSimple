# CLAUDE.md — $imple

## Antes de empezar cualquier chat
1. Leer, en este orden: `docs/DECISIONES-TECNICAS.md`, `docs/PENDIENTES-A-DEFINIR.md`, `docs/ESPECIFICACION-PRODUCTO.md`, `README.md`.
2. Si se contradicen: **Decisiones > respuestas de Pendientes > Especificación > `PROYECTO_REGLAS.md`** (D-001).
3. Hablar siempre en **español y en palabras simples**.

## Regla: un chat por tarea
- Cada chat hace **una sola** tarea de la tabla de abajo. No empieza la siguiente.
- Si aparece algo fuera de la tarea, se anota en `docs/PENDIENTES-A-DEFINIR.md` (nuevo P-xx) y se sigue.
- Si se toma una decisión nueva, se agrega en `docs/DECISIONES-TECNICAS.md` (nuevo D-xxx).
- Antes de cada push: `flutter analyze` limpio y `flutter test` en verde (D-010).
- Nunca `git reset --hard`, `git clean` ni cambiar de rama con cambios sin commit (D-011).
- Al terminar, escribir exactamente: **"Tarea terminada"**, un resumen corto y el mensaje para pegar en el chat siguiente.

## Tabla de chats

| Chat | Tarea | Termina cuando… |
|---|---|---|
| 00 | Base: push, analyze/test en verde, versión de DB de la 1.1.8, documentos guía, alcance de pantallas | analyze y test pasan, docs existen, alcance aprobado |
| 01 | Aplicar el alcance: ocultar y borrar las pantallas aprobadas, limpiar menú, rutas y textos | menú y rutas coinciden con la Especificación; analyze y test en verde |
| 02 | Núcleo: carga rápida, agregar/editar, movimientos, pagos fijos y cuotas | se puede anotar, editar y ver sin errores; tests de esos flujos |
| 03 | Números: inicio, "Podés gastar hoy", deudas, estadísticas | los totales cuadran entre pantallas; tests de cálculos |
| 04 | Pro y compras: pantalla Pro, compra y restauración, crash de billing (P-03), Bóveda | compra y restauración probadas; Bóveda aislada |
| 05 | Datos y privacidad: respaldo, actualización desde la 1.1.8 (P-01), PIN/huella, consentimiento, política y landing | actualizar desde la 1.1.8 no pierde datos; respaldo ida y vuelta OK |
| 06 | Publicación: versión ≥ 1.1.9 (15) (D-006), unir a `main` (P-07), tag (D-012), AAB firmado, ficha de Play | AAB subido a prueba interna |

> Tabla aprobada el 2026-10-04. Solo se reordena con una decisión nueva (D-xxx).
