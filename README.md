# $imple

App de finanzas personales para anotar gastos e ingresos rápido, ver cuánto podés gastar hoy y ordenar deudas, pagos fijos y cuotas. Todo queda guardado en el teléfono. Hecha en Flutter, publicada en Google Play.

## Documentos guía

| Documento | Para qué sirve |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Cómo se trabaja: un chat por tarea y la tabla de chats 00–08 |
| [`docs/DECISIONES-TECNICAS.md`](docs/DECISIONES-TECNICAS.md) | Lo que ya está decidido (D-001…). **Manda sobre todo lo demás** |
| [`docs/PENDIENTES-A-DEFINIR.md`](docs/PENDIENTES-A-DEFINIR.md) | Preguntas abiertas (P-01…) y sus respuestas |
| [`docs/ESPECIFICACION-PRODUCTO.md`](docs/ESPECIFICACION-PRODUCTO.md) | Qué hace la app, pantallas y reglas de oro |
| [`docs/SISTEMA-DISENO.md`](docs/SISTEMA-DISENO.md) | Reglas de diseño: un módulo por cosa, catálogo de íconos (D-032) |
| [`PROYECTO_REGLAS.md`](PROYECTO_REGLAS.md) | Reglas viejas, ya absorbidas por la Especificación |

Prioridad si se contradicen: Decisiones > respuestas de Pendientes > Especificación > `PROYECTO_REGLAS.md`.

## Cómo correrla

```bash
flutter pub get
flutter run
```

Antes de subir cambios:

```bash
flutter analyze
flutter test
```

## Nota técnica

El nombre público es `$imple`. Los identificadores técnicos (paquete `gastos_simple`, app id `com.migueld.gastossimple`, Firebase y el producto de compra) **no se cambian** para no romper la app publicada (D-003).

## Estructura

- `lib/features/` — una carpeta por función (movimientos, inicio, deudas, metas, bóveda, ajustes…).
- `lib/core/` — navegación, estado, idiomas, interfaz común.
- `lib/database/` — base de datos local (SQLite, versión 16).
- `lib/services/` — cálculos y servicios (compras, seguridad, proyección…).
- `docs/`, `github_pages_root/`, `SimpleLanding/` — landing pública y política de privacidad (se mantienen iguales).
